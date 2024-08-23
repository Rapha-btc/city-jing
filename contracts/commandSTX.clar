;; creating offer with u100 ustx and 0 fees: ok true: good
;; attempt to cancel swap with the wrong ft-sender: u12: good
;; cancel swap with correct ft-sender from id, ft or fees: u6, u8 and u11 respectively: good
;; cancelling swap with correct ft-sender and everything correct: ok true: good
;; attempt to cancel swap with incorrect stx-sender: u12: good
;; attempt to submit swap from offerer with fake fees: u11: good
;; attempting to submit swap from offerer with correct everything: u2000 same principal for STX transfer: good
;; attempt to submit with wrong swap id: u6: with wrong FT: u8, with wrong fees: u11: good
;; attempt to submit happy path ok true: good: done false: 0.75% fee-receiver FT and STX transfers: good
;; attempt submit after it's done: u7: good
;; attempt to get swap: good
;; attempt to cancel done swap with wrong ft sender: u12: good
;; attempt to cancel done swap with correct everything: u7: good
;; attempt happy path with fair and not (welsh used above)
;; attempt to create offer without FT u100: good
(contract-call? 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.fair 
    mint-to 
    u100000000000 
    'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5)

(contract-call? 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.not 
    mint-to 
    u100000000000 
    'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG)

(contract-call? 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.stx-ft 
    offer
    u3000000000
    u100000000
    none
    'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.fair
    'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.invalid-fees)

::set_tx_sender ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5
::get_assets_maps
::set_tx_sender ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM
::set_tx_sender ST2REHHS5J3CERCRBEPMGH7921Q6PYKAADT7JP2VB
::set_tx_sender ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG
::advance_chain_tip 1000

(contract-call? 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.stx-ft 
    cancel
    u0
    'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.fair
    'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.fees)

(contract-call? 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.stx-ft
    submit-swap
    u0
    'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.fair
    'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.fees)

(contract-call? 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.stx-ft
    get-swap
    u0)

(contract-call? 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.fair 
    mint-to 
    u100000000000 
    'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5)

(contract-call? 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.fair 
    mint-to 
    u100000000000 
    'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5)

(contract-call? 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.stx-ft 
    offer
    u100000000
    u100000000
    none
    'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.fair
    'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.fees)