;; Title: PredictaSTX - Advanced Bitcoin Price Speculation Platform
;;
;; Summary:
;;   A sophisticated decentralized prediction marketplace enabling STX holders to
;;   speculate on Bitcoin's future price movements with competitive rewards and
;;   transparent oracle-based settlements.
;;
;; Description:
;;   PredictaSTX revolutionizes cryptocurrency prediction markets by offering a
;;   trustless platform where participants can leverage their market insights to
;;   earn rewards. Users stake STX tokens on their Bitcoin price predictions within
;;   defined time windows. Smart contract automation ensures fair distribution of
;;   winnings based on actual market outcomes, with built-in fee mechanisms to
;;   sustain platform operations. The system employs robust oracle integration
;;   for reliable price feeds and implements comprehensive security measures to
;;   protect participant funds while maintaining market integrity.
;;
;; Key Features:
;;   - Binary prediction markets with up/down price speculation
;;   - Proportional reward distribution among winning participants  
;;   - Reliable oracle-based price resolution system
;;   - Flexible stake requirements and fee structures
;;   - Fully automated market lifecycle management
;;   - Enhanced security protocols for fund protection
;;

;; TRAITS & DEPENDENCIES

;; TOKEN DEFINITIONS

;; ERROR CONSTANTS

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-invalid-prediction (err u102))
(define-constant err-market-closed (err u103))
(define-constant err-market-not-started (err u107))
(define-constant err-market-ended (err u108))
(define-constant err-market-already-resolved (err u109))
(define-constant err-already-claimed (err u104))
(define-constant err-insufficient-balance (err u105))
(define-constant err-invalid-parameter (err u106))

;; DATA VARIABLES

;; Oracle responsible for providing accurate Bitcoin price data feeds
(define-data-var oracle-address principal 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)

;; Minimum STX stake required for market participation (1 STX default)
(define-data-var minimum-stake uint u1000000)

;; Platform fee percentage collected from winnings (2% default)
(define-data-var fee-percentage uint u2)

;; Sequential counter for unique market identification
(define-data-var market-counter uint u0)

;; DATA MAPS

;; Market registry containing all prediction market data
(define-map markets
  uint ;; market-id
  {
    start-price: uint,
    end-price: uint,
    total-up-stake: uint,
    total-down-stake: uint,
    start-block: uint,
    end-block: uint,
    resolved: bool,
  }
)

;; User prediction tracking for stake management and claim processing
(define-map user-predictions
  {
    market-id: uint,
    user: principal,
  }
  {
    prediction: (string-ascii 4),
    stake: uint,
    claimed: bool,
  }
)

;; PUBLIC FUNCTIONS - CORE MARKET OPERATIONS

;; Creates a new Bitcoin price prediction market with specified parameters
(define-public (create-market
    (start-price uint)
    (start-block uint)
    (end-block uint)
  )
  (let ((market-id (var-get market-counter)))
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> end-block start-block) err-invalid-parameter)
    (asserts! (> start-price u0) err-invalid-parameter)

    (map-set markets market-id {
      start-price: start-price,
      end-price: u0,
      total-up-stake: u0,
      total-down-stake: u0,
      start-block: start-block,
      end-block: end-block,
      resolved: false,
    })
    (var-set market-counter (+ market-id u1))
    (ok market-id)
  )
)

;; Submits a price prediction with STX stake to an active market
(define-public (make-prediction
    (market-id uint)
    (prediction (string-ascii 4))
    (stake uint)
  )
  (let (
      (market (unwrap! (map-get? markets market-id) err-not-found))
      (current-block-height stacks-block-height)
    )
    (asserts!
      (and
        (>= current-block-height (get start-block market))
        (< current-block-height (get end-block market))
      )
      err-market-ended
    )
    (asserts! (or (is-eq prediction "up") (is-eq prediction "down"))
      err-invalid-prediction
    )
    (asserts! (>= stake (var-get minimum-stake)) err-invalid-prediction)
    (asserts! (<= stake (stx-get-balance tx-sender)) err-insufficient-balance)

    ;; Transfer stake to contract escrow
    (try! (stx-transfer? stake tx-sender (as-contract tx-sender)))

    ;; Record user prediction
    (map-set user-predictions {
      market-id: market-id,
      user: tx-sender,
    } {
      prediction: prediction,
      stake: stake,
      claimed: false,
    })

    ;; Update market totals
    (map-set markets market-id
      (merge market {
        total-up-stake: (if (is-eq prediction "up")
          (+ (get total-up-stake market) stake)
          (get total-up-stake market)
        ),
        total-down-stake: (if (is-eq prediction "down")
          (+ (get total-down-stake market) stake)
          (get total-down-stake market)
        ),
      })
    )
    (ok true)
  )
)

;; Finalizes market with official Bitcoin price for settlement
(define-public (resolve-market
    (market-id uint)
    (end-price uint)
  )
  (let ((market (unwrap! (map-get? markets market-id) err-not-found)))
    (asserts! (is-eq tx-sender (var-get oracle-address)) err-owner-only)
    (asserts! (>= stacks-block-height (get end-block market)) err-market-ended)
    (asserts! (not (get resolved market)) err-market-already-resolved)
    (asserts! (> end-price u0) err-invalid-parameter)

    (map-set markets market-id
      (merge market {
        end-price: end-price,
        resolved: true,
      })
    )
    (ok true)
  )
)

;; Processes winning payout for successful predictions
(define-public (claim-winnings (market-id uint))
  (let (
      (market (unwrap! (map-get? markets market-id) err-not-found))
      (prediction (unwrap!
        (map-get? user-predictions {
          market-id: market-id,
          user: tx-sender,
        })
        err-not-found
      ))
    )