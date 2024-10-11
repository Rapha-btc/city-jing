(use-trait fungible-token .sip-010-trait-ft-standard.sip-010-trait) 
;; This contract is admin-less and immutable

(define-constant stx-contract 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.dmg);;  'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token)
(define-constant ft-contract 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.cha);; 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token)

;; Define the two allowed fee contracts
(define-constant YANG-FEES 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.swater)

;; the fee structure is defined by the calling client
(define-trait fees-trait
  ((get-fees (uint) (response uint uint))
  (hold-fees (uint) (response bool uint))
  (release-fees (uint) (response bool uint))
  (pay-fees (uint) (response bool uint))))

(define-map swaps uint {amount: uint, ft-sender: principal, ustx: uint, stx-sender: (optional principal), open: bool, fees: principal})
(define-data-var next-id uint u0)

;; read-only function to get swap details by id
(define-read-only (get-swap (id uint))
  (match (map-get? swaps id)
    swap (ok swap)
    (err ERR_INVALID_ID)))

(define-private (ft-transfer-to (amount uint) (to principal) (memo (buff 34)))
  (begin
    (try! (contract-call? .cha transfer amount tx-sender to (some memo)))
    (ok true)))

(define-private (stx-transfer-to (ustx uint) (to principal) (memo (buff 34)))
   (contract-call? stx-contract transfer ustx tx-sender to (some memo)))

(define-private (is-valid-fees (fees <fees-trait>))
    (is-eq (contract-of fees) YANG-FEES))

(define-public (offer (amount uint) (ustx uint) (stx-sender (optional principal)) (fees <fees-trait>))
  (let ((id (var-get next-id)))
    (asserts! (is-valid-fees fees) ERR_INVALID_FEES)
    (asserts! (map-insert swaps id
      {amount: amount, ft-sender: tx-sender, ustx: ustx, stx-sender: stx-sender,
         open: true, fees: (contract-of fees)}) ERR_INVALID_ID)
        (print 
      {
        type: "offer",
        swap_type: "FT-STX",
        swap-id: id, 
        creator: tx-sender,
        counterparty: stx-sender,
        open: true,
        fees: (contract-of fees),
        in_contract: ft-contract, 
        in_amount: amount,
        in_decimals: (unwrap! (contract-call? .cha get-decimals) ERR_FT_FAILURE),
        out_contract: .dmg,
        out-amount: ustx,
        out-decimals: (unwrap! (contract-call? .dmg get-decimals) ERR_FT_FAILURE),
      }
    )
    (var-set next-id (+ id u1))
    (try! (contract-call? fees hold-fees ustx))
    (match (ft-transfer-to amount (as-contract tx-sender) 0x696E74656772617465)
      success (ok id)
      error (err (* error u100)))))

;; only ft-sender can cancel the swap and get the fees back
(define-public (cancel (id uint) (fees <fees-trait>))
  (let ((swap (unwrap! (map-get? swaps id) ERR_INVALID_ID))
    (amount (get amount swap))
    (ustx (get ustx swap)))
      (asserts! (is-eq (contract-of fees) (get fees swap)) ERR_INVALID_FEES_TRAIT)
      (asserts! (is-eq tx-sender (get ft-sender swap)) ERR_NOT_FT_SENDER)
      (asserts! (get open swap) ERR_ALREADY_DONE) 
      (asserts! (map-set swaps id (merge swap {open: false})) ERR_NATIVE_FAILURE)
      (try! (contract-call? fees release-fees ustx)) 
    (print 
      {
        type: "cancel",
        swap_type: "FT-STX",
        swap-id: id, 
        creator: tx-sender,
        counterparty: (get stx-sender swap),
        open: false,
        fees: (contract-of fees),
        in_contract: .cha,
        in_amount: amount,
        in_decimals: (unwrap! (contract-call? .cha get-decimals) ERR_FT_FAILURE),
        out_contract: stx-contract,
        out-amount: ustx,
        out-decimals: (unwrap! (contract-call? stx-contract get-decimals) ERR_FT_FAILURE),
      }
    )
    (match (as-contract (ft-transfer-to 
                amount (get ft-sender swap)
                0x7365706172617465))
      success (ok success)
      error (err (* error u100)))))

;; any user can submit a tx that contains the swap
(define-public (submit-swap
    (id uint)
    (ft <fungible-token>)
    (fees <fees-trait>))
  (let ((swap (unwrap! (map-get? swaps id) ERR_INVALID_ID))
    (ustx (get ustx swap))
    (ft-receiver (default-to tx-sender (get stx-sender swap)))
    (amount (get amount swap)))
      (asserts! (get open swap) ERR_ALREADY_DONE)
      (asserts! (is-eq (contract-of fees) (get fees swap)) ERR_INVALID_FEES_TRAIT)
      (asserts! (map-set swaps id (merge swap {open: false})) ERR_NATIVE_FAILURE)
      (asserts! (is-eq tx-sender ft-receiver) ERR_INVALID_FT_RECEIVER) ;; ft-receiver is tx-sender  / assert out if the receiver is predetermined 
      (try! (contract-call? fees pay-fees ustx))
      (print 
        {
            type: "swap",
            swap_type: "FT-STX",
            swap-id: id, 
            creator: (get ft-sender swap),
            counterparty: tx-sender,
            open: false,
            fees: (contract-of fees),
            in_contract: ft-contract,
            in_amount: amount,
            in_decimals: (unwrap! (contract-call? ft-contract get-decimals) ERR_FT_FAILURE),
            out_contract: stx-contract,
            out-amount: ustx,
            out-decimals: (unwrap! (contract-call? stx-contract get-decimals) ERR_FT_FAILURE),
        }
      )
      (match (stx-transfer-to ustx (get ft-sender swap) 0x696E74656772617465)
        success-stx (begin
            (asserts! success-stx ERR_NATIVE_FAILURE)
            (match (as-contract (ft-transfer-to amount
                ft-receiver 0x696E74656772617465))
              success-ft (ok success-ft)
              error-ft (err (* error-ft u100))))
        error-stx (err (* error-stx u1000)))))

(define-constant ERR_INVALID_ID (err u6))
(define-constant ERR_ALREADY_DONE (err u7))
(define-constant ERR_INVALID_FUNGIBLE_TOKEN (err u8))
(define-constant ERR_INVALID_FT_RECEIVER (err u9))
(define-constant ERR_INVALID_FEES (err u10))
(define-constant ERR_INVALID_FEES_TRAIT (err u11))
(define-constant ERR_NOT_FT_SENDER (err u12))
(define-constant ERR_FT_FAILURE (err u13))
(define-constant ERR_TOKEN_NOT_B1 (err u14))
(define-constant ERR_NATIVE_FAILURE (err u99))
;; (err u1) -- sender does not have enough balance to transfer 
;; (err u2) -- sender and recipient are the same principal 
;; (err u3) -- amount to send is non-positive

;; The road to prosperity is often a roundabout journey, where detours and indirect routes reveal the most valuable insights and innovations.
