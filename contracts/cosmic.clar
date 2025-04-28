;; Cosmic Discovery Catalog Smart Contract
;; Facilitates categorization, registration and controlled sharing of celestial observations


;; Error Code Constants
(define-constant CONTRACT_ADMINISTRATOR tx-sender)
(define-constant ERROR_UNAUTHORIZED_ACCESS (err u300))
(define-constant ERROR_ENTRY_NONEXISTENT (err u301))
(define-constant ERROR_ENTRY_DUPLICATE (err u302))
(define-constant ERROR_INVALID_ENTRY_SIZE (err u304))
(define-constant ERROR_ACCESS_RESTRICTED (err u305))
(define-constant ERROR_INVALID_ENTRY_TITLE (err u303))



;; Primary Storage Structure
(define-map celestial-entries
  { entry-id: uint }
  {
    entry-title: (string-ascii 80),
    entry-owner: principal,
    entry-size: uint,
    registration-height: uint,
    entry-abstract: (string-ascii 256),
    entry-categories: (list 8 (string-ascii 40))
  }
)

;; Access Control Mechanism
(define-map entry-access-rights
  { entry-id: uint, observer: principal }
  { can-view: bool }
)

;; Global Counter
(define-data-var entry-sequence uint u0)

;; Helper Functions
(define-private (entry-registered (entry-id uint))
  (is-some (map-get? celestial-entries { entry-id: entry-id }))
)

(define-private (is-entry-owner (entry-id uint) (owner principal))
  (match (map-get? celestial-entries { entry-id: entry-id })
    entry-data (is-eq (get entry-owner entry-data) owner)
    false
  )
)

(define-private (are-categories-valid (categories (list 8 (string-ascii 40))))
  (and
    (> (len categories) u0)
    (<= (len categories) u8)
    (is-eq (len (filter is-valid-category categories)) (len categories))
  )
)

(define-private (is-valid-category (category (string-ascii 40)))
  (and 
    (> (len category) u0)
    (< (len category) u41)
  )
)
