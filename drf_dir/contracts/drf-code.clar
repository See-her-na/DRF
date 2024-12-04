(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INVALID-INPUT (err u101))

(define-constant ROLE-ADMIN u1)
(define-constant ROLE-RESEARCHER u2)

(define-data-var contract-owner principal tx-sender)
(define-data-var grant-count uint u0)

(define-map roles { user: principal } { role: uint })
(define-map research-grants
  { id: uint }
  { 
    title: (string-utf8 50), 
    funding-target: uint, 
    received-funding: uint,
    status: (string-ascii 20)
  })

(define-private (is-authorized (user principal) (required-role uint))
  (let ((role-data (default-to { role: u0 } (map-get? roles { user: user }))))
    (>= (get role role-data) required-role)))

(define-public (assign-role (user principal) (role uint))
  (if (is-eq tx-sender (var-get contract-owner))
      (ok (map-set roles { user: user } { role: role }))
      ERR-NOT-AUTHORIZED))

(define-public (submit-research-grant (title (string-utf8 50)) (funding-target uint))
  (let ((grant-id (+ (var-get grant-count) u1)))
    (if (and 
          (is-authorized tx-sender ROLE-ADMIN)
          (> (len title) u0) 
          (> funding-target u0))
        (begin
          (map-set research-grants 
            { id: grant-id }
            { 
              title: title, 
              funding-target: funding-target, 
              received-funding: u0,
              status: "pending"
            })
          (var-set grant-count grant-id)
          (ok grant-id))
        ERR-INVALID-INPUT)))

(define-public (contribute-funding (grant-id uint) (amount uint))
  (let ((grant (unwrap! (map-get? research-grants { id: grant-id }) ERR-INVALID-INPUT)))
    (if (is-authorized tx-sender ROLE-RESEARCHER)
        (begin
          (map-set research-grants
            { id: grant-id }
            (merge grant { 
              received-funding: (+ (get received-funding grant) amount),
              status: (if (>= (+ (get received-funding grant) amount) (get funding-target grant)) 
                          "funded" 
                          "pending")
            }))
        (ok true))
        ERR-NOT-AUTHORIZED)))

(define-private (initialize-contract)
  (begin
    (var-set contract-owner tx-sender)
    (map-set roles { user: tx-sender } { role: ROLE-ADMIN })))

(initialize-contract)