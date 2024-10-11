(use-trait fungible-token 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
;; This contract is admin-less and immutable

(define-constant stx-contract 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token)
(define-constant ft-contract 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token)
;; Define the two allowed fee contracts
(define-constant YIN-FEES .fire)

;; the fee structure is defined by the calling client
(define-trait fees-trait
  ((get-fees (uint) (response uint uint))
  (hold-fees (uint) (response bool uint))
  (release-fees (uint) (response bool uint))
  (pay-fees (uint) (response bool uint))))

(define-map swaps uint {ustx: uint, stx-sender: principal, amount: uint, ft-sender: (optional principal), open: bool, fees: principal})
(define-data-var next-id uint u0)

;; read-only function to get swap details by id
(define-read-only (get-swap (id uint))
  (match (map-get? swaps id)
    swap (ok swap)
    (err ERR_INVALID_ID)))

;; helper function to transfer stx to a principal with memo
(define-private (stx-transfer-to (ustx uint) (to principal) (memo (optional (buff 34))))
  (contract-call? stx-contract transfer ustx tx-sender to memo))

(define-private (is-valid-fees (fees <fees-trait>))
  (is-eq (contract-of fees) YIN-FEES))

;; create a swap between btc and fungible token
(define-public (offer (ustx uint) (amount uint) (ft-sender (optional principal)) (fees <fees-trait>))
  (let ((id (var-get next-id)))
    (asserts! (is-valid-fees fees) ERR_INVALID_FEES)
    (asserts! (map-insert swaps id
      {ustx: ustx, stx-sender: tx-sender, amount: amount, ft-sender: ft-sender,
         open: true, fees: (contract-of fees)}) ERR_INVALID_ID)
        (print 
      {
        type: "offer",
        swap_type: "STX-FT",
        swap-id: id, 
        creator: tx-sender,
        counterparty: ft-sender,
        open: true,
        fees: (contract-of fees),
        in_contract: stx-contract,
        in_amount: ustx,
        in_decimals: (unwrap! (contract-call? stx-contract get-decimals) ERR_FT_FAILURE),
        out_contract: ft-contract, 
        out-amount: amount,
        out-decimals: (unwrap! (contract-call? ft-contract get-decimals) ERR_FT_FAILURE),
      }
    )
    (var-set next-id (+ id u1))
    (try! (contract-call? fees hold-fees ustx))
    (match (stx-transfer-to ustx (as-contract tx-sender) (some 0x696E74656772617465))
      success (ok id)
      error (err (* error u100)))))

;; only stx-sender can cancel the swap after and get the fees back
(define-public (cancel (id uint) (fees <fees-trait>))
  (let ((swap (unwrap! (map-get? swaps id) ERR_INVALID_ID))
    (ustx (get ustx swap)))
      (asserts! (is-eq (contract-of fees) (get fees swap)) ERR_INVALID_FEES_TRAIT)
      (asserts! (is-eq tx-sender (get stx-sender swap)) ERR_NOT_STX_SENDER)
      (asserts! (get open swap) ERR_ALREADY_DONE) 
      (asserts! (map-set swaps id (merge swap {open: false})) ERR_NATIVE_FAILURE)
      (try! (contract-call? fees release-fees ustx)) 
    (print 
      {
        type: "cancel",
        swap_type: "STX-FT",
        swap-id: id, 
        creator: tx-sender,
        counterparty: (get ft-sender swap),
        open: false,
        fees: (contract-of fees),
        in_contract: stx-contract,
        in_amount: ustx,
        in_decimals: (unwrap! (contract-call? stx-contract get-decimals) ERR_FT_FAILURE),
        out_contract: ft-contract,  
        out-amount: (get amount swap),
        out-decimals: (unwrap! (contract-call? ft-contract get-decimals) ERR_FT_FAILURE),
      }
    )
      (match (as-contract (stx-transfer-to
                ustx (get stx-sender swap)
                (some 0x7365706172617465)))
        success (ok success)
        error (err (* error u100)))))

;; any user can submit a tx that contains the swap
(define-public (submit-swap
    (id uint)
    (fees <fees-trait>))
  (let ((swap (unwrap! (map-get? swaps id) ERR_INVALID_ID))
    (ustx (get ustx swap))
    (stx-receiver (default-to tx-sender (get ft-sender swap)))
    (ft-amount (get amount swap)))
      (asserts! (get open swap) ERR_ALREADY_DONE)
      (asserts! (is-eq (contract-of fees) (get fees swap)) ERR_INVALID_FEES_TRAIT)
      (asserts! (map-set swaps id (merge swap {open: false})) ERR_NATIVE_FAILURE)
      (asserts! (is-eq tx-sender stx-receiver) ERR_INVALID_STX_RECEIVER) ;; assert out if the receiver is predetermined 
      (try! (contract-call? fees pay-fees ustx))
      (print 
        {
            type: "swap",
            swap_type: "STX-FT",
            swap-id: id, 
            creator: (get stx-sender swap),
            counterparty: tx-sender,
            open: false,
            fees: (contract-of fees),
            in_contract: stx-contract,
            in_amount: ustx,
            in_decimals: (unwrap! (contract-call? stx-contract get-decimals) ERR_FT_FAILURE),
            out_contract: ft-contract,
            out-amount: ft-amount,
            out-decimals: (unwrap! (contract-call? ft-contract get-decimals) ERR_FT_FAILURE),
        }
      )
      (match (contract-call? ft-contract transfer
          ft-amount stx-receiver (get stx-sender swap)
          (some 0x696E74656772617465))
        success-ft (begin
            (asserts! success-ft ERR_NATIVE_FAILURE)
            (match (as-contract (stx-transfer-to
                (get ustx swap) stx-receiver
                (some 0x696E74656772617465)))
              success-stx (ok success-stx)
              error-stx (err (* error-stx u100))))
        error-ft (err (* error-ft u1000)))))

(define-constant ERR_INVALID_ID (err u6))
(define-constant ERR_ALREADY_DONE (err u7))
(define-constant ERR_INVALID_FUNGIBLE_TOKEN (err u8))
(define-constant ERR_INVALID_STX_RECEIVER (err u9))
(define-constant ERR_INVALID_FEES (err u10))
(define-constant ERR_INVALID_FEES_TRAIT (err u11))
(define-constant ERR_NOT_STX_SENDER (err u12))
(define-constant ERR_FT_FAILURE (err u13))
(define-constant ERR_TOKEN_NOT_B1 (err u14))
(define-constant ERR_NATIVE_FAILURE (err u99))
;; (err u1) -- sender does not have enough balance to transfer 
;; (err u2) -- sender and recipient are the same principal 
;; (err u3) -- amount to send is non-positive

;; The road to prosperity is often a roundabout journey, where detours and indirect routes reveal the most valuable insights and innovations.
