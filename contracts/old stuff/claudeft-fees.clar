(define-constant fee-receiver tx-sender)
(define-constant charging-ctr .ft-stx-swap)

(define-public (get-fees (amount uint))
  (ok (neon-fee amount)))

(define-private (neon-fee (amount uint))
  (if (> amount u10000000000) 
    (/ amount u400)           ;; amount > 10,000 then 0.25% 
    (if (> amount u5000000000) 
      (/ amount u200)            ;; amount > 5,000  then 0.50% 
      (/ amount u133))))         ;; 0.75%

(define-public (hold-fees (amount uint) (ft-contract principal))
  (begin
    (asserts! (is-eq contract-caller charging-ctr) ERR_NOT_AUTH)
    (contract-call? ft-contract transfer (neon-fee amount) tx-sender (as-contract tx-sender) none)))

(define-public (release-fees (amount uint) (ft-contract principal))
  (let ((user tx-sender))
    (asserts! (is-eq contract-caller charging-ctr) ERR_NOT_AUTH)
    (as-contract (contract-call? ft-contract transfer (neon-fee amount) tx-sender user none))))

(define-public (pay-fees (amount uint) (ft-contract principal))
  (let ((fee (neon-fee amount)))
    (asserts! (is-eq contract-caller charging-ctr) ERR_NOT_AUTH)
    (if (> fee u0)
      (as-contract (contract-call? ft-contract transfer fee tx-sender fee-receiver none))
      (ok true))))

(define-constant ERR_NOT_AUTH (err u404))