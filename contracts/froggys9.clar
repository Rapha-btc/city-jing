;; Define the whitelist map
(define-map whitelist {frog: principal, sort-id: uint} bool)

;; Define the NFT
(define-non-fungible-token froggy uint)

;; Keep track of the last minted froggy ID
(define-data-var last-froggy-id uint u0)

;; Define the contract owner
(define-constant contract-owner tx-sender)

;; Error constants
(define-constant err-not-authorized (err u100))
(define-constant err-already-whitelisted (err u101))
(define-constant err-mint-failed (err u102))

;; Function to whitelist a principal and mint a froggy NFT
(define-public (whitelist-and-mint (frog principal) (sort-id uint))
  (let
    ((froggy-id (+ (var-get last-froggy-id) u1)))
    (asserts! (is-eq tx-sender contract-owner) err-not-authorized)
    (asserts! (is-none (map-get? whitelist {frog: frog, sort-id: sort-id})) err-already-whitelisted)
    (try! (nft-mint? froggy froggy-id frog))
    (map-set whitelist {frog: frog, sort-id: sort-id} true)
    (var-set last-froggy-id froggy-id)
    (ok froggy-id)))

;; Read-only function to check if a principal is whitelisted for a specific sort-id
(define-read-only (is-whitelisted (frog principal) (sort-id uint))
  (default-to false (map-get? whitelist {frog: frog, sort-id: sort-id})))

;; Read-only function to get the last minted froggy ID
(define-read-only (get-last-froggy-id)
  (ok (var-get last-froggy-id)))