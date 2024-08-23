(define-constant fee-receiver tx-sender)
(define-constant charging-ctr-bid .stx-ft)
(define-constant charging-ctr-ask .ft-stx)

;; For information only.
(define-public (get-fees (ustx uint))
  (ok (jing-cash ustx)))

(define-private (jing-cash (ustx uint))
  (if (> ustx u10000000000) 
    (/ ustx u400)           ;; ustx> 10,000 then 0.25% 
    (if (> ustx u5000000000) 
      (/ ustx u200)            ;; ustx > 5,000  then 0.50% 
      (/ ustx u133))))         ;; 0.75%

;; Hold fees for the given amount in escrow.
(define-public (hold-fees (ustx uint))
  (begin
    (asserts! (or (is-eq contract-caller charging-ctr-bid) 
                  (is-eq contract-caller charging-ctr-ask))  ERR_NOT_AUTH)
    (stx-transfer? (jing-cash ustx) tx-sender (as-contract tx-sender))))

;; Release fees for the given amount if swap was canceled by its creator
(define-public (release-fees (ustx uint))
  (let ((user tx-sender))
    (asserts! (or (is-eq contract-caller charging-ctr-bid) 
                  (is-eq contract-caller charging-ctr-ask))  ERR_NOT_AUTH)
    (as-contract (stx-transfer? (jing-cash ustx) tx-sender user)))) 

;; Pay fee for the given amount if swap was executed.
(define-public (pay-fees (ustx uint))
  (let ((fee (jing-cash ustx)))
    (asserts! (or (is-eq contract-caller charging-ctr-bid) 
                  (is-eq contract-caller charging-ctr-ask))  ERR_NOT_AUTH)
    (if (> fee u0)
      (as-contract (stx-transfer? fee tx-sender fee-receiver))
      (ok true))))

(define-constant ERR_NOT_AUTH (err u404))
;; "The man who views the world at 50 the same as he did at 20 has wasted 30 years of his life."