(use-trait fungible-token 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant THIS-CONTRACT (as-contract tx-sender))

(define-trait fees-trait
  ((get-fees (uint) (response uint uint))
  (hold-fees (uint principal) (response bool uint))
  (release-fees (uint principal) (response bool uint))
  (pay-fees (uint principal) (response bool uint))))

(define-map swaps uint {ft-amount: uint, ft-sender: principal, ustx: uint, stx-receiver: (optional principal), open: bool, ft: principal, fees: principal})
(define-data-var next-id uint u0)

(define-read-only (get-swap (id uint))
  (match (map-get? swaps id)
    swap (ok swap)
    (err ERR_INVALID_ID)))

(define-public (offer (ft-amount uint) (ustx uint) (stx-receiver (optional principal)) (ft <fungible-token>) (fees <fees-trait>))
  (let ((id (var-get next-id)))
    (asserts! (map-insert swaps id
      {ft-amount: ft-amount, ft-sender: tx-sender, ustx: ustx, stx-receiver: stx-receiver,
         open: true, ft: (contract-of ft), fees: (contract-of fees)}) ERR_INVALID_ID)
    (print 
      {
        type: "offer",
        swap_type: "FT-STX",
        contract_address: THIS-CONTRACT,
        swap-id: id, 
        creator: tx-sender,
        counterparty: stx-receiver,
        open: true,
        fees: (contract-of fees),
        in_contract: (contract-of ft),
        in_amount: ft-amount,
        in_decimals: (unwrap! (contract-call? ft get-decimals) ERR_FT_FAILURE),
        out_contract: "STX",
        out-amount: ustx,
        out-decimals: u6,
      }
    )
    (var-set next-id (+ id u1))
    (try! (contract-call? fees hold-fees ft-amount (contract-of ft)))
    (match (contract-call? ft transfer ft-amount tx-sender THIS-CONTRACT (some 0x636174616d6172616e2073776170))
      success (ok id)
      error (err (* error u100)))))

(define-public (cancel (id uint) (ft <fungible-token>) (fees <fees-trait>))
  (let ((swap (unwrap! (map-get? swaps id) ERR_INVALID_ID))
    (ft-amount (get ft-amount swap)))
      (asserts! (is-eq (contract-of ft) (get ft swap)) ERR_INVALID_FUNGIBLE_TOKEN)
      (asserts! (is-eq (contract-of fees) (get fees swap)) ERR_INVALID_FEES_TRAIT)
      (asserts! (is-eq tx-sender (get ft-sender swap)) ERR_NOT_FT_SENDER)
      (asserts! (get open swap) ERR_ALREADY_DONE) 
      (asserts! (map-set swaps id (merge swap {open: false})) ERR_NATIVE_FAILURE)
      (try! (contract-call? fees release-fees ft-amount (contract-of ft))) 
    (print 
      {
        type: "cancel",
        swap_type: "FT-STX",
        contract_address: THIS-CONTRACT,
        swap-id: id, 
        creator: tx-sender,
        counterparty: (get stx-receiver swap),
        open: false,
        fees: (contract-of fees),
        in_contract: (contract-of ft),
        in_amount: ft-amount,
        in_decimals: (unwrap! (contract-call? ft get-decimals) ERR_FT_FAILURE),
        out_contract: "STX",
        out-amount: (get ustx swap),
        out-decimals: u6,
      }
    )
      (match (as-contract (contract-call? ft transfer
                ft-amount THIS-CONTRACT (get ft-sender swap)
                (some 0x72657665727420636174616d6172616e2073776170)))
        success (ok success)
        error (err (* error u100)))))

(define-public (submit-swap
    (id uint)
    (ft <fungible-token>)
    (fees <fees-trait>))
  (let ((swap (unwrap! (map-get? swaps id) ERR_INVALID_ID))
    (ft-amount (get ft-amount swap))
    (ustx (get ustx swap))
    (stx-sender (default-to tx-sender (get stx-receiver swap))))
      (asserts! (get open swap) ERR_ALREADY_DONE)
      (asserts! (is-eq (contract-of ft) (get ft swap)) ERR_INVALID_FUNGIBLE_TOKEN)
      (asserts! (is-eq (contract-of fees) (get fees swap)) ERR_INVALID_FEES_TRAIT)
      (asserts! (map-set swaps id (merge swap {open: false})) ERR_NATIVE_FAILURE)
      (asserts! (is-eq tx-sender stx-sender) ERR_INVALID_STX_SENDER)
      (try! (contract-call? fees pay-fees ft-amount (contract-of ft)))
      (print 
        {
            type: "swap",
            swap_type: "FT-STX",
            contract_address: THIS-CONTRACT,
            swap-id: id, 
            creator: (get ft-sender swap),
            counterparty: tx-sender,
            open: false,
            fees: (contract-of fees),
            in_contract: (contract-of ft),
            in_amount: ft-amount,
            in_decimals: (unwrap! (contract-call? ft get-decimals) ERR_FT_FAILURE),
            out_contract: "STX",
            out-amount: ustx,
            out-decimals: u6,
        }
      )
      (match (stx-transfer? ustx tx-sender (get ft-sender swap))
        success-stx (begin
            (asserts! success-stx ERR_NATIVE_FAILURE)
            (match (as-contract (contract-call? ft transfer
                ft-amount THIS-CONTRACT stx-sender
                (some 0x636174616d6172616e2073776170)))
              success-ft (ok success-ft)
              error-ft (err (* error-ft u1000))))
        error-stx (err (* error-stx u100)))))

(define-constant ERR_INVALID_ID (err u6))
(define-constant ERR_ALREADY_DONE (err u7))
(define-constant ERR_INVALID_FUNGIBLE_TOKEN (err u8))
(define-constant ERR_INVALID_STX_SENDER (err u9))
(define-constant ERR_INVALID_FEES (err u10))
(define-constant ERR_INVALID_FEES_TRAIT (err u11))
(define-constant ERR_NOT_FT_SENDER (err u12))
(define-constant ERR_FT_FAILURE (err u13))
(define-constant ERR_NATIVE_FAILURE (err u99))