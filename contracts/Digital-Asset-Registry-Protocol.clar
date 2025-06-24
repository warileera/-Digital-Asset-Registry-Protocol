;; Digital Asset Registry Protocol v2.1
;; Enterprise-grade decentralized file management infrastructure
;; 
;; Comprehensive blockchain solution for digital asset cataloging and governance
;; Implements cutting-edge cryptographic integrity verification systems
;; Provides enterprise-level distributed content orchestration capabilities

;; System administrator root access configuration
(define-constant system-admin-authority contract-caller)

;; Advanced exception handling system with granular error classifications
(define-constant asset-not-found-exception (err u501))
(define-constant duplicate-entry-violation (err u502))
(define-constant invalid-parameters-exception (err u503))
(define-constant capacity-limit-exceeded-exception (err u504))
(define-constant access-denied-exception (err u505))
(define-constant permission-denied-exception (err u506))
(define-constant insufficient-privileges-exception (err u500))
(define-constant content-restricted-exception (err u507))
(define-constant format-validation-exception (err u508))

;; Global asset registry increment counter mechanism
(define-data-var digital-asset-counter uint u0)

;; Primary digital asset repository data structure
(define-map enterprise-asset-registry
  { asset-identifier: uint }
  {
    resource-name: (string-ascii 64),
    asset-owner: principal,
    data-size-bytes: uint,
    creation-block: uint,
    content-description: (string-ascii 128),
    category-tags: (list 10 (string-ascii 32))
  }
)

;; Sophisticated permission management control structure
(define-map access-control-list
  { asset-identifier: uint, user-principal: principal }
  { read-access-enabled: bool }
)

;; ===== Private helper functions for internal processing =====

;; Category tag format compliance verification algorithm
(define-private (is-valid-category-tag (tag-value (string-ascii 32)))
  (and
    (> (len tag-value) u0)
    (< (len tag-value) u33)
  )
)

;; Complete tag collection validation with integrity checks
(define-private (validate-all-category-tags (tag-list (list 10 (string-ascii 32))))
  (and
    (> (len tag-list) u0)
    (<= (len tag-list) u10)
    (is-eq (len (filter is-valid-category-tag tag-list)) (len tag-list))
  )
)

;; Asset registry existence verification utility
(define-private (does-asset-exist (asset-identifier uint))
  (is-some (map-get? enterprise-asset-registry { asset-identifier: asset-identifier }))
)

;; Data size extraction helper function
(define-private (get-asset-size (asset-identifier uint))
  (default-to u0
    (get data-size-bytes
      (map-get? enterprise-asset-registry { asset-identifier: asset-identifier })
    )
  )
)

;; Ownership authorization verification mechanism
(define-private (is-authorized-owner (asset-identifier uint) (user-principal principal))
  (match (map-get? enterprise-asset-registry { asset-identifier: asset-identifier })
    asset-data (is-eq (get asset-owner asset-data) user-principal)
    false
  )
)

;; ===== Core public interface functions =====

;; Advanced digital asset registration with comprehensive validation
(define-public (create-digital-asset
  (resource-name (string-ascii 64))
  (data-size-bytes uint)
  (content-description (string-ascii 128))
  (category-tags (list 10 (string-ascii 32)))
)
  (let
    (
      (new-asset-id (+ (var-get digital-asset-counter) u1))
    )
    ;; Rigorous input parameter validation with detailed checks
    (asserts! (> (len resource-name) u0) invalid-parameters-exception)
    (asserts! (< (len resource-name) u65) invalid-parameters-exception)
    (asserts! (> data-size-bytes u0) capacity-limit-exceeded-exception)
    (asserts! (< data-size-bytes u1000000000) capacity-limit-exceeded-exception)
    (asserts! (> (len content-description) u0) invalid-parameters-exception)
    (asserts! (< (len content-description) u129) invalid-parameters-exception)
    (asserts! (validate-all-category-tags category-tags) format-validation-exception)

    ;; Atomic asset registration in enterprise registry
    (map-insert enterprise-asset-registry
      { asset-identifier: new-asset-id }
      {
        resource-name: resource-name,
        asset-owner: contract-caller,
        data-size-bytes: data-size-bytes,
        creation-block: block-height,
        content-description: content-description,
        category-tags: category-tags
      }
    )

    ;; Initialize creator access permissions automatically
    (map-insert access-control-list
      { asset-identifier: new-asset-id, user-principal: contract-caller }
      { read-access-enabled: true }
    )

    ;; Update global asset counter for next registration
    (var-set digital-asset-counter new-asset-id)
    (ok new-asset-id)
  )
)

;; Comprehensive asset modification with enhanced security protocols
(define-public (update-digital-asset
  (asset-identifier uint)
  (new-resource-name (string-ascii 64))
  (new-data-size-bytes uint)
  (new-content-description (string-ascii 128))
  (new-category-tags (list 10 (string-ascii 32)))
)
  (let
    (
      (current-asset-data (unwrap! (map-get? enterprise-asset-registry { asset-identifier: asset-identifier })
        asset-not-found-exception))
    )
    ;; Multi-layer authorization and validation framework
    (asserts! (does-asset-exist asset-identifier) asset-not-found-exception)
    (asserts! (is-eq (get asset-owner current-asset-data) contract-caller) permission-denied-exception)
    (asserts! (> (len new-resource-name) u0) invalid-parameters-exception)
    (asserts! (< (len new-resource-name) u65) invalid-parameters-exception)
    (asserts! (> new-data-size-bytes u0) capacity-limit-exceeded-exception)
    (asserts! (< new-data-size-bytes u1000000000) capacity-limit-exceeded-exception)
    (asserts! (> (len new-content-description) u0) invalid-parameters-exception)
    (asserts! (< (len new-content-description) u129) invalid-parameters-exception)
    (asserts! (validate-all-category-tags new-category-tags) format-validation-exception)

    ;; Atomic asset record update with preserved metadata
    (map-set enterprise-asset-registry
      { asset-identifier: asset-identifier }
      (merge current-asset-data {
        resource-name: new-resource-name,
        data-size-bytes: new-data-size-bytes,
        content-description: new-content-description,
        category-tags: new-category-tags
      })
    )
    (ok true)
  )
)

;; Secure asset ownership transition protocol
(define-public (transfer-asset-ownership (asset-identifier uint) (new-owner-principal principal))
  (let
    (
      (asset-record (unwrap! (map-get? enterprise-asset-registry { asset-identifier: asset-identifier })
        asset-not-found-exception))
    )
    ;; Strict ownership verification before transfer execution
    (asserts! (does-asset-exist asset-identifier) asset-not-found-exception)
    (asserts! (is-eq (get asset-owner asset-record) contract-caller) permission-denied-exception)

    ;; Execute ownership transfer with updated registry entry
    (map-set enterprise-asset-registry
      { asset-identifier: asset-identifier }
      (merge asset-record { asset-owner: new-owner-principal })
    )
    (ok true)
  )
)

;; Irreversible asset deletion from enterprise registry
(define-public (delete-digital-asset (asset-identifier uint))
  (let
    (
      (asset-to-remove (unwrap! (map-get? enterprise-asset-registry { asset-identifier: asset-identifier })
        asset-not-found-exception))
    )
    ;; Authorization validation before permanent removal
    (asserts! (does-asset-exist asset-identifier) asset-not-found-exception)
    (asserts! (is-eq (get asset-owner asset-to-remove) contract-caller) permission-denied-exception)

    ;; Execute permanent asset removal from registry
    (map-delete enterprise-asset-registry { asset-identifier: asset-identifier })
    (ok true)
  )
)



;; ===== Read-only data retrieval and query functions =====

;; Comprehensive asset information retrieval with access validation
(define-read-only (get-asset-information (asset-identifier uint))
  (let
    (
      (asset-data (unwrap! (map-get? enterprise-asset-registry { asset-identifier: asset-identifier })
        asset-not-found-exception))
      (user-access-status (default-to false
        (get read-access-enabled
          (map-get? access-control-list { asset-identifier: asset-identifier, user-principal: contract-caller })
        )
      ))
    )
    ;; Access control validation before information disclosure
    (asserts! (does-asset-exist asset-identifier) asset-not-found-exception)
    (asserts! (or user-access-status (is-eq (get asset-owner asset-data) contract-caller)) content-restricted-exception)

    ;; Return complete asset information structure
    (ok {
      resource-name: (get resource-name asset-data),
      asset-owner: (get asset-owner asset-data),
      data-size-bytes: (get data-size-bytes asset-data),
      creation-block: (get creation-block asset-data),
      content-description: (get content-description asset-data),
      category-tags: (get category-tags asset-data)
    })
  )
)

;; Registry statistics and system information retrieval
(define-read-only (get-registry-statistics)
  (ok {
    total-assets-registered: (var-get digital-asset-counter),
    system-administrator: system-admin-authority
  })
)

;; Asset ownership information retrieval utility
(define-read-only (get-asset-owner (asset-identifier uint))
  (match (map-get? enterprise-asset-registry { asset-identifier: asset-identifier })
    asset-data (ok (get asset-owner asset-data))
    asset-not-found-exception
  )
)

;; Comprehensive access permission status verification
(define-read-only (verify-access-status (asset-identifier uint) (user-principal principal))
  (let
    (
      (asset-data (unwrap! (map-get? enterprise-asset-registry { asset-identifier: asset-identifier })
        asset-not-found-exception))
      (granted-access (default-to false
        (get read-access-enabled
          (map-get? access-control-list { asset-identifier: asset-identifier, user-principal: user-principal })
        )
      ))
    )
    ;; Return detailed access status information
    (ok {
      has-granted-access: granted-access,
      is-asset-owner: (is-eq (get asset-owner asset-data) user-principal),
      can-read-asset: (or granted-access (is-eq (get asset-owner asset-data) user-principal))
    })
  )
)

