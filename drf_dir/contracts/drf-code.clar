(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INVALID-INPUT (err u101))

(define-data-var contract-owner principal tx-sender)
(define-data-var grant-count uint u0)

(define-map research-grants
  { id: uint }
  { 
    title: (string-utf8 50), 
    funding-target: uint, 
    received-funding: uint
  })

(define-public (submit-research-grant (title (string-utf8 50)) (funding-target uint))
  (let ((grant-id (+ (var-get grant-count) u1)))
    (if (and (> (len title) u0) (> funding-target u0))
        (begin
          (map-set research-grants 
            { id: grant-id }
            { 
              title: title, 
              funding-target: funding-target, 
              received-funding: u0 
            })
          (var-set grant-count grant-id)
          (ok grant-id))
        ERR-INVALID-INPUT)))

(define-public (contribute-funding (grant-id uint) (amount uint))
  (let ((grant (unwrap! (map-get? research-grants { id: grant-id }) ERR-INVALID-INPUT)))
    (map-set research-grants
      { id: grant-id }
      (merge grant { received-funding: (+ (get received-funding grant) amount) })
    )
    (ok true)))

(define-private (initialize-contract)
  (var-set contract-owner tx-sender))

(initialize-contract)