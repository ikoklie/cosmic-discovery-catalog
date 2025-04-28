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

(define-private (get-entry-size (entry-id uint))
  (default-to u0 
    (get entry-size 
      (map-get? celestial-entries { entry-id: entry-id })
    )
  )
)

;; Core Registration Function
(define-public (register-discovery (title (string-ascii 80)) (size uint) (abstract (string-ascii 256)) (categories (list 8 (string-ascii 40))))
  (let
    (
      (new-id (+ (var-get entry-sequence) u1))
    )
    ;; Validate input parameters
    (asserts! (> (len title) u0) ERROR_INVALID_ENTRY_TITLE)
    (asserts! (< (len title) u81) ERROR_INVALID_ENTRY_TITLE)
    (asserts! (> size u0) ERROR_INVALID_ENTRY_SIZE)
    (asserts! (< size u2000000000) ERROR_INVALID_ENTRY_SIZE)
    (asserts! (> (len abstract) u0) ERROR_INVALID_ENTRY_TITLE)
    (asserts! (< (len abstract) u257) ERROR_INVALID_ENTRY_TITLE)
    (asserts! (are-categories-valid categories) ERROR_INVALID_ENTRY_TITLE)

    ;; Record the celestial discovery in catalog
    (map-insert celestial-entries
      { entry-id: new-id }
      {
        entry-title: title,
        entry-owner: tx-sender,
        entry-size: size,
        registration-height: block-height,
        entry-abstract: abstract,
        entry-categories: categories
      }
    )

    ;; Establish initial access rights for discoverer
    (map-insert entry-access-rights
      { entry-id: new-id, observer: tx-sender }
      { can-view: true }
    )

    ;; Update sequence counter
    (var-set entry-sequence new-id)
    (ok new-id)
  )
)

;; Secondary Registration Implementation
(define-public (log-cosmic-finding (title (string-ascii 80)) (size uint) (abstract (string-ascii 256)) (categories (list 8 (string-ascii 40))))
  (let
    (
      (new-id (+ (var-get entry-sequence) u1))
    )
    ;; Validate submission parameters
    (asserts! (> (len title) u0) ERROR_INVALID_ENTRY_TITLE)
    (asserts! (< (len title) u81) ERROR_INVALID_ENTRY_TITLE)
    (asserts! (> size u0) ERROR_INVALID_ENTRY_SIZE)
    (asserts! (< size u2000000000) ERROR_INVALID_ENTRY_SIZE)
    (asserts! (> (len abstract) u0) ERROR_INVALID_ENTRY_TITLE)
    (asserts! (< (len abstract) u257) ERROR_INVALID_ENTRY_TITLE)
    (asserts! (are-categories-valid categories) ERROR_INVALID_ENTRY_TITLE)

    ;; Store metadata in the central catalog
    (map-insert celestial-entries
      { entry-id: new-id }
      {
        entry-title: title,
        entry-owner: tx-sender,
        entry-size: size,
        registration-height: block-height,
        entry-abstract: abstract,
        entry-categories: categories
      }
    )

    ;; Configure initial access permissions
    (map-insert entry-access-rights
      { entry-id: new-id, observer: tx-sender }
      { can-view: true }
    )
    (var-set entry-sequence new-id)
    (ok new-id)
  )
)

;; Entry Update Function
(define-public (update-discovery (entry-id uint) (new-title (string-ascii 80)) (new-size uint) (new-abstract (string-ascii 256)) (new-categories (list 8 (string-ascii 40))))
  (let
    (
      (entry-data (unwrap! (map-get? celestial-entries { entry-id: entry-id }) ERROR_ENTRY_NONEXISTENT))
    )
    ;; Verify entry existence and ownership
    (asserts! (entry-registered entry-id) ERROR_ENTRY_NONEXISTENT)
    (asserts! (is-eq (get entry-owner entry-data) tx-sender) ERROR_ACCESS_RESTRICTED)

    ;; Validate updated parameters
    (asserts! (> (len new-title) u0) ERROR_INVALID_ENTRY_TITLE)
    (asserts! (< (len new-title) u81) ERROR_INVALID_ENTRY_TITLE)
    (asserts! (> new-size u0) ERROR_INVALID_ENTRY_SIZE)
    (asserts! (< new-size u2000000000) ERROR_INVALID_ENTRY_SIZE)
    (asserts! (> (len new-abstract) u0) ERROR_INVALID_ENTRY_TITLE)
    (asserts! (< (len new-abstract) u257) ERROR_INVALID_ENTRY_TITLE)
    (asserts! (are-categories-valid new-categories) ERROR_INVALID_ENTRY_TITLE)

    ;; Update entry with new data
    (map-set celestial-entries
      { entry-id: entry-id }
      (merge entry-data { 
        entry-title: new-title, 
        entry-size: new-size, 
        entry-abstract: new-abstract, 
        entry-categories: new-categories 
      })
    )
    (ok true)
  )
)

;; Entry Removal Function
(define-public (purge-discovery (entry-id uint))
  (let
    (
      (entry-data (unwrap! (map-get? celestial-entries { entry-id: entry-id }) ERROR_ENTRY_NONEXISTENT))
    )
    ;; Verify entry existence and ownership
    (asserts! (entry-registered entry-id) ERROR_ENTRY_NONEXISTENT)
    (asserts! (is-eq (get entry-owner entry-data) tx-sender) ERROR_ACCESS_RESTRICTED)

    ;; Remove entry from catalog
    (map-delete celestial-entries { entry-id: entry-id })
    (ok true)
  )
)

;; Visualization Functions

;; Generate display format for entry details
(define-public (display-entry-card (entry-id uint))
  (let
    (
      (entry-data (unwrap! (map-get? celestial-entries { entry-id: entry-id }) ERROR_ENTRY_NONEXISTENT))
    )
    ;; Format entry data for display interface
    (ok {
      page-name: "Discovery Information",
      entry-title: (get entry-title entry-data),
      entry-owner: (get entry-owner entry-data),
      entry-abstract: (get entry-abstract entry-data),
      entry-categories: (get entry-categories entry-data)
    })
  )
)

;; Retrieve comprehensive entry details
(define-public (retrieve-full-entry (entry-id uint))
  (let
    (
      (entry-data (unwrap! (map-get? celestial-entries { entry-id: entry-id }) ERROR_ENTRY_NONEXISTENT))
    )
    ;; Structure complete entry information for presentation
    (ok {
      name: (get entry-title entry-data),
      creator: (get entry-owner entry-data),
      bytes: (get entry-size entry-data),
      summary: (get entry-abstract entry-data),
      tags: (get entry-categories entry-data)
    })
  )
)

;; Low-overhead data retrieval functions

;; Efficient minimal entry data retrieval
(define-public (retrieve-entry-basic (entry-id uint))
  (let
    (
      (entry-data (unwrap! (map-get? celestial-entries { entry-id: entry-id }) ERROR_ENTRY_NONEXISTENT))
    )
    ;; Return core entry details with reduced resource usage
    (ok {
      entry-title: (get entry-title entry-data),
      entry-owner: (get entry-owner entry-data),
      entry-size: (get entry-size entry-data)
    })
  )
)
;; This function provides essential entry information with optimized gas consumption

;; Ultra-efficient entry identification retrieval
(define-public (retrieve-entry-identifier (entry-id uint))
  (let
    (
      (entry-data (unwrap! (map-get? celestial-entries { entry-id: entry-id }) ERROR_ENTRY_NONEXISTENT))
    )
    ;; Return minimum identifying information for maximum efficiency
    (ok {
      entry-title: (get entry-title entry-data),
      entry-owner: (get entry-owner entry-data)
    })
  )
)
;; This optimized function returns only the most basic identification details

;; Extract entry abstract only
(define-public (retrieve-entry-abstract (entry-id uint))
  (let
    (
      (entry-data (unwrap! (map-get? celestial-entries { entry-id: entry-id }) ERROR_ENTRY_NONEXISTENT))
    )
    (ok (get entry-abstract entry-data))
  )
)

;; Validation function for entry submissions
(define-public (validate-entry-parameters (title (string-ascii 80)) (size uint) (abstract (string-ascii 256)) (categories (list 8 (string-ascii 40))))
  (begin
    ;; Validate title constraints
    (asserts! (> (len title) u0) ERROR_INVALID_ENTRY_TITLE)
    (asserts! (< (len title) u81) ERROR_INVALID_ENTRY_TITLE)
    ;; Validate size constraints
    (asserts! (> size u0) ERROR_INVALID_ENTRY_SIZE)
    (asserts! (< size u2000000000) ERROR_INVALID_ENTRY_SIZE)
    ;; Validate abstract constraints
    (asserts! (> (len abstract) u0) ERROR_INVALID_ENTRY_TITLE)
    (asserts! (< (len abstract) u257) ERROR_INVALID_ENTRY_TITLE)
    ;; Validate category constraints
    (asserts! (are-categories-valid categories) ERROR_INVALID_ENTRY_TITLE)
    (ok true)
  )
)

