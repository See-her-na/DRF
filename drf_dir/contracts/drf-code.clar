(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INVALID-INPUT (err u101))
(define-constant ERR-MILESTONE-NOT-FOUND (err u102))

(define-constant ROLE-ADMIN u1)
(define-constant ROLE-RESEARCHER u2)
(define-constant ROLE-REVIEWER u3)

(define-data-var contract-owner principal tx-sender)
(define-data-var grant-count uint u0)
(define-data-var milestone-count uint u0)

(define-map roles { user: principal } { role: uint })
(define-map research-grants
  { id: uint }
  { 
    title: (string-utf8 50), 
    funding-target: uint, 
    received-funding: uint,
    status: (string-ascii 20)
  })

(define-map research-milestones
  { id: uint }
  { 
    grant-id: uint,
    description: (string-utf8 255),
    required-funding: uint,
    status: (string-ascii 20)
  })

(define-private (is-authorized (user principal) (required-role uint))
  (let ((role-data (default-to { role: u0 } (map-get? roles { user: user }))))
    (>= (get role role-data) required-role)))

(define-public (submit-research-grant (title (string-utf8 50)) (funding-target uint))
  (let ((grant-id (+ (var-get grant-count) u1)))
    (if (and 
          (is-authorized tx-sender ROLE-REVIEWER)
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

(define-public (add-milestone (grant-id uint) (description (string-utf8 255)) (required-funding uint))
  (let ((grant (unwrap! (map-get? research-grants { id: grant-id }) ERR-INVALID-INPUT)))
    (if (and 
          (is-authorized tx-sender ROLE-RESEARCHER)
          (> (len description) u0))
        (let ((milestone-id (+ (var-get milestone-count) u1)))
          (begin
            (map-set research-milestones
              { id: milestone-id }
              { 
                grant-id: grant-id,
                description: description,
                required-funding: required-funding,
                status: "pending"
              })
            (var-set milestone-count milestone-id)
            (ok milestone-id)))
        ERR-INVALID-INPUT)))

(define-public (approve-milestone (milestone-id uint))
  (let ((milestone (unwrap! (map-get? research-milestones { id: milestone-id }) ERR-MILESTONE-NOT-FOUND)))
    (if (is-authorized tx-sender ROLE-ADMIN)
        (begin
          (map-set research-milestones
            { id: milestone-id }
            (merge milestone { status: "approved" }))
          (ok true))
        ERR-NOT-AUTHORIZED)))

(define-private (initialize-contract)
  (begin
    (var-set contract-owner tx-sender)
    (map-set roles { user: tx-sender } { role: ROLE-ADMIN })))

(initialize-contract)