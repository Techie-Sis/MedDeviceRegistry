;; MedDeviceRegistry - Medical device tracking and certification system
(define-map medical-devices uint {
  manufacturer: principal,
  device-name: (string-utf8 64),
  specifications: (string-utf8 256),
  production-date: uint,
  facility-location: (string-utf8 64),
  fda-approved: bool
})

(define-map manufacturer-devices principal (list 100 uint))
(define-map regulatory-authorities principal bool)
(define-data-var device-id-sequence uint u0)

;; Error codes
(define-constant err-not-manufacturer (err u200))
(define-constant err-not-regulator (err u201))
(define-constant err-device-not-found (err u202))
(define-constant err-access-denied (err u403))
(define-constant err-device-limit-exceeded (err u204))
(define-constant err-invalid-address (err u205))
(define-constant err-invalid-device-name (err u206))
(define-constant err-invalid-specifications (err u207))
(define-constant err-invalid-production-date (err u208))
(define-constant err-invalid-facility (err u209))
(define-constant err-invalid-device-id (err u210))

;; Contract administrator for regulatory functions
(define-constant contract-administrator tx-sender)

;; Register regulatory authority
(define-public (register-regulatory-authority (authority principal))
  (begin
    ;; Check if sender is contract administrator
    (asserts! (is-eq tx-sender contract-administrator) err-access-denied)
    
    ;; Validate authority principal
    (asserts! (not (is-eq authority 'SP000000000000000000002Q6VF78)) err-invalid-address)
    
    ;; Add authority to registry
    (ok (map-set regulatory-authorities authority true))
  )
)

;; Register medical device
(define-public (register-medical-device 
  (device-name (string-utf8 64)) 
  (specifications (string-utf8 256)) 
  (production-date uint) 
  (facility-location (string-utf8 64)))
  (let
    ((device-id (var-get device-id-sequence))
     (manufacturer tx-sender)
     (current-devices (default-to (list) (map-get? manufacturer-devices manufacturer))))
    
    ;; Validate inputs
    (asserts! (> (len device-name) u0) err-invalid-device-name)
    (asserts! (> (len specifications) u0) err-invalid-specifications)
    (asserts! (> production-date u0) err-invalid-production-date)
    (asserts! (> (len facility-location) u0) err-invalid-facility)
    
    ;; Check device registration limit
    (asserts! (< (len current-devices) u100) err-device-limit-exceeded)
    
    ;; Store device information
    (map-set medical-devices device-id {
      manufacturer: manufacturer,
      device-name: device-name,
      specifications: specifications,
      production-date: production-date,
      facility-location: facility-location,
      fda-approved: false
    })
    
    ;; Update manufacturer's device list
    (let 
      ((updated-device-list (unwrap-panic (as-max-len? (concat (list device-id) current-devices) u100))))
      (map-set manufacturer-devices manufacturer updated-device-list)
    )
    
    ;; Increment device ID sequence
    (var-set device-id-sequence (+ device-id u1))
    
    (ok device-id)))

;; Approve medical device
(define-public (approve-device (device-id uint))
  (begin
    ;; Validate device ID
    (asserts! (< device-id (var-get device-id-sequence)) err-invalid-device-id)
    
    (let
      ((device (unwrap! (map-get? medical-devices device-id) err-device-not-found)))
      
      ;; Check if sender is regulatory authority
      (asserts! (default-to false (map-get? regulatory-authorities tx-sender)) err-not-regulator)
      
      ;; Update device approval status
      (ok (map-set medical-devices device-id (merge device {fda-approved: true})))
    )
  )
)

;; Get device information
(define-read-only (get-device (device-id uint))
  (map-get? medical-devices device-id))

;; Get manufacturer's devices
(define-read-only (get-manufacturer-devices (manufacturer principal))
  (default-to (list) (map-get? manufacturer-devices manufacturer)))

;; Check regulatory authority status
(define-read-only (is-regulatory-authority (address principal))
  (default-to false (map-get? regulatory-authorities address)))