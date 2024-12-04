;; Full implementation from previous version
(define-data-var contract-owner principal tx-sender)

;; Define constants for errors
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-ALREADY-REGISTERED (err u101))
(define-constant ERR-NOT-FOUND (err u102))
(define-constant ERR-INSUFFICIENT-FUNDS (err u103))
(define-constant ERR-RESEARCHER-NOT-FOUND (err u104))
(define-constant ERR-MILESTONE-NOT-FOUND (err u105))
(define-constant ERR-INVALID-INPUT (err u106))

;; Define constants for roles
(define-constant ROLE-PROGRAM-DIRECTOR u1)
(define-constant ROLE-REVIEWER u2)
(define-constant ROLE-RESEARCHER u3)

;; Define data maps
(define-map roles { user: principal } { role: uint })

(define-map research-grants
  { id: uint }
  { 
    title: (string-utf8 50), 
    abstract: (string-utf8 255), 
    funding-target: uint, 
    received-funding: uint, 
    status: (string-ascii 20)
  })

(define-map funding-contributions
  { id: uint }
  { funder: principal, grant-id: uint, amount: uint, timestamp: uint })

(define-map research-milestones
  { id: uint }
  { 
    grant-id: uint, 
    milestone-number: uint, 
    description: (string-utf8 255), 
    required-funding: uint, 
    status: (string-ascii 20)
  })

;; Define data variables
(define-data-var grant-count uint u0)
(define-data-var contribution-count uint u0)
(define-data-var milestone-count uint u0)
(define-data-var current-timestamp uint u0)

;; Helper functions
(define-private (is-authorized (user principal) (required-role uint))
  (let ((role-data (default-to { role: u0 } (map-get? roles { user: user }))))
    (>= (get role role-data) required-role)))

(define-private (get-last-milestone (grant-id uint))
  (var-get milestone-count))

;; Update timestamp function
(define-public (update-timestamp)
  (begin
    (var-set current-timestamp (+ (var-get current-timestamp) u1))
    (ok (var-get current-timestamp))))

;; Role management functions
(define-public (assign-role (user principal) (new-role uint))
  (let ((existing-role (default-to u0 (get role (map-get? roles { user: user })))))
    (if (and 
          (is-eq tx-sender (var-get contract-owner))
          (<= new-role ROLE-RESEARCHER)
          (not (is-eq user tx-sender))
          (or (is-eq new-role ROLE-PROGRAM-DIRECTOR)
              (is-eq new-role ROLE-REVIEWER)
              (is-eq new-role ROLE-RESEARCHER)))
        (ok (map-set roles { user: user } { role: new-role }))
        ERR-NOT-AUTHORIZED)))

(define-public (revoke-role (user principal))
  (if (and 
        (is-eq tx-sender (var-get contract-owner))
        (is-some (map-get? roles { user: user }))
        (not (is-eq user tx-sender)))
      (ok (map-delete roles { user: user }))
      ERR-NOT-AUTHORIZED))

;; Main functions
(define-public (submit-research-grant (title (string-utf8 50)) (abstract (string-utf8 255)) (funding-target uint))
  (let 
    ((grant-id (+ (var-get grant-count) u1)))
    (if (and (is-authorized tx-sender ROLE-REVIEWER)
             (> (len title) u0)
             (> (len abstract) u0)
             (> funding-target u0))
        (begin
          (map-set research-grants
            { id: grant-id }
            { 
              title: title, 
              abstract: abstract, 
              funding-target: funding-target, 
              received-funding: u0, 
              status: "under-review" 
            })
          (var-set grant-count grant-id)
          (ok grant-id))
        ERR-INVALID-INPUT)))

(define-read-only (get-research-grant (id uint))
  (match (map-get? research-grants { id: id })
    grant (ok grant)
    ERR-RESEARCHER-NOT-FOUND))

(define-public (contribute-funding (grant-id uint) (amount uint))
  (let 
    ((grant (unwrap! (get-research-grant grant-id) ERR-RESEARCHER-NOT-FOUND))
     (current-time (unwrap! (update-timestamp) ERR-INVALID-INPUT)))
    (if (and (> amount u0)
             (< grant-id (var-get grant-count))
             (is-some (map-get? research-grants { id: grant-id })))
        (match (stx-transfer? amount tx-sender (as-contract tx-sender))
          success (begin
            (map-set research-grants
              { id: grant-id }
              (merge grant { received-funding: (+ (get received-funding grant) amount) }))
            (map-set funding-contributions
              { id: (+ (var-get contribution-count) u1) }
              { funder: tx-sender, grant-id: grant-id, amount: amount, timestamp: current-time })
            (var-set contribution-count (+ (var-get contribution-count) u1))
            (ok true))
          error ERR-INSUFFICIENT-FUNDS)
        ERR-INVALID-INPUT)))

(define-public (add-research-milestone (grant-id uint) (description (string-utf8 255)) (required-funding uint))
  (let 
    ((grant (unwrap! (get-research-grant grant-id) ERR-RESEARCHER-NOT-FOUND)))
    (if (and (is-authorized tx-sender ROLE-PROGRAM-DIRECTOR)
             (> (len description) u0)
             (> required-funding u0)
             (< grant-id (var-get grant-count)))
        (let
          ((milestone-number (+ (get-last-milestone grant-id) u1))
           (milestone-id (+ (var-get milestone-count) u1)))
          (begin
            (map-set research-milestones
              { id: milestone-id }
              { 
                grant-id: grant-id, 
                milestone-number: milestone-number, 
                description: description, 
                required-funding: required-funding, 
                status: "pending" 
              })
            (var-set milestone-count milestone-