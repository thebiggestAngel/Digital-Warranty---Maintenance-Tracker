(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_DEVICE_NOT_FOUND (err u101))
(define-constant ERR_DEVICE_ALREADY_EXISTS (err u102))
(define-constant ERR_WARRANTY_EXPIRED (err u103))
(define-constant ERR_INVALID_DURATION (err u104))
(define-constant ERR_NOT_OWNER (err u105))

(define-data-var contract-owner principal tx-sender)
(define-data-var device-counter uint u0)
(define-data-var service-counter uint u0)

(define-map devices 
  { device-id: uint }
  {
    owner: principal,
    manufacturer: (string-ascii 100),
    model: (string-ascii 100),
    serial-number: (string-ascii 100),
    purchase-date: uint,
    warranty-start: uint,
    warranty-duration: uint,
    warranty-type: (string-ascii 50),
    purchase-price: uint,
    is-active: bool
  }
)

(define-map device-services
  { service-id: uint }
  {
    device-id: uint,
    service-provider: principal,
    service-type: (string-ascii 100),
    service-date: uint,
    service-cost: uint,
    description: (string-ascii 500),
    parts-replaced: (string-ascii 300),
    next-service-due: (optional uint)
  }
)

(define-map device-ownership-history
  { device-id: uint, transfer-id: uint }
  {
    previous-owner: principal,
    new-owner: principal,
    transfer-date: uint,
    transfer-price: (optional uint)
  }
)

(define-map user-devices
  { owner: principal, device-id: uint }
  { registered: bool }
)

(define-map device-transfer-counter
  { device-id: uint }
  { counter: uint }
)

(define-read-only (get-contract-owner)
  (var-get contract-owner)
)

(define-read-only (get-device-info (device-id uint))
  (map-get? devices { device-id: device-id })
)

(define-read-only (get-device-services (device-id uint))
  (let ((services (list)))
    (fold check-service-for-device (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10) (list))
  )
)

(define-read-only (is-warranty-valid (device-id uint))
  (match (map-get? devices { device-id: device-id })
    device-data 
    (let ((warranty-end (+ (get warranty-start device-data) (get warranty-duration device-data))))
      (and (get is-active device-data) (< burn-block-height warranty-end)))
    false
  )
)

(define-read-only (get-warranty-remaining (device-id uint))
  (match (map-get? devices { device-id: device-id })
    device-data
    (let ((warranty-end (+ (get warranty-start device-data) (get warranty-duration device-data))))
      (if (> warranty-end burn-block-height)
        (ok (- warranty-end burn-block-height))
        (ok u0)))
    ERR_DEVICE_NOT_FOUND
  )
)

(define-read-only (get-ownership-history (device-id uint))
  (let ((transfer-info (default-to { counter: u0 } (map-get? device-transfer-counter { device-id: device-id }))))
    (fold get-transfer-record (list u0 u1 u2 u3 u4) (list))
  )
)

(define-read-only (is-device-owner (device-id uint) (user principal))
  (match (map-get? devices { device-id: device-id })
    device-data (is-eq (get owner device-data) user)
    false
  )
)

(define-public (register-device 
  (manufacturer (string-ascii 100))
  (model (string-ascii 100)) 
  (serial-number (string-ascii 100))
  (warranty-duration uint)
  (warranty-type (string-ascii 50))
  (purchase-price uint))
  (let ((new-device-id (+ (var-get device-counter) u1)))
    (asserts! (> warranty-duration u0) ERR_INVALID_DURATION)
    (map-set devices 
      { device-id: new-device-id }
      {
        owner: tx-sender,
        manufacturer: manufacturer,
        model: model,
        serial-number: serial-number,
        purchase-date: burn-block-height,
        warranty-start: burn-block-height,
        warranty-duration: warranty-duration,
        warranty-type: warranty-type,
        purchase-price: purchase-price,
        is-active: true
      }
    )
    (map-set user-devices
      { owner: tx-sender, device-id: new-device-id }
      { registered: true }
    )
    (var-set device-counter new-device-id)
    (ok new-device-id)
  )
)

(define-public (add-service-record
  (device-id uint)
  (service-type (string-ascii 100))
  (service-cost uint)
  (description (string-ascii 500))
  (parts-replaced (string-ascii 300))
  (next-service-due (optional uint)))
  (let ((device-info (unwrap! (map-get? devices { device-id: device-id }) ERR_DEVICE_NOT_FOUND))
        (new-service-id (+ (var-get service-counter) u1)))
    (asserts! (or (is-eq tx-sender (get owner device-info)) 
                  (is-eq tx-sender (var-get contract-owner))) ERR_NOT_AUTHORIZED)
    (map-set device-services
      { service-id: new-service-id }
      {
        device-id: device-id,
        service-provider: tx-sender,
        service-type: service-type,
        service-date: burn-block-height,
        service-cost: service-cost,
        description: description,
        parts-replaced: parts-replaced,
        next-service-due: next-service-due
      }
    )
    (var-set service-counter new-service-id)
    (ok new-service-id)
  )
)

(define-public (transfer-ownership (device-id uint) (new-owner principal) (transfer-price (optional uint)))
  (let ((device-info (unwrap! (map-get? devices { device-id: device-id }) ERR_DEVICE_NOT_FOUND))
        (current-counter (default-to { counter: u0 } (map-get? device-transfer-counter { device-id: device-id })))
        (new-transfer-id (+ (get counter current-counter) u1)))
    (asserts! (is-eq tx-sender (get owner device-info)) ERR_NOT_OWNER)
    (map-set devices
      { device-id: device-id }
      (merge device-info { owner: new-owner })
    )
    (map-delete user-devices { owner: tx-sender, device-id: device-id })
    (map-set user-devices
      { owner: new-owner, device-id: device-id }
      { registered: true }
    )
    (map-set device-ownership-history
      { device-id: device-id, transfer-id: new-transfer-id }
      {
        previous-owner: tx-sender,
        new-owner: new-owner,
        transfer-date: burn-block-height,
        transfer-price: transfer-price
      }
    )
    (map-set device-transfer-counter
      { device-id: device-id }
      { counter: new-transfer-id }
    )
    (ok true)
  )
)

(define-public (deactivate-device (device-id uint))
  (let ((device-info (unwrap! (map-get? devices { device-id: device-id }) ERR_DEVICE_NOT_FOUND)))
    (asserts! (is-eq tx-sender (get owner device-info)) ERR_NOT_OWNER)
    (map-set devices
      { device-id: device-id }
      (merge device-info { is-active: false })
    )
    (ok true)
  )
)

(define-public (extend-warranty (device-id uint) (additional-duration uint))
  (let ((device-info (unwrap! (map-get? devices { device-id: device-id }) ERR_DEVICE_NOT_FOUND)))
    (asserts! (or (is-eq tx-sender (get owner device-info))
                  (is-eq tx-sender (var-get contract-owner))) ERR_NOT_AUTHORIZED)
    (asserts! (> additional-duration u0) ERR_INVALID_DURATION)
    (map-set devices
      { device-id: device-id }
      (merge device-info { 
        warranty-duration: (+ (get warranty-duration device-info) additional-duration) 
      })
    )
    (ok true)
  )
)

(define-private (check-service-for-device (service-id uint) (acc (list 10 uint)))
  (match (map-get? device-services { service-id: service-id })
    service-data (if (is-some (index-of acc service-id))
                   acc
                   (unwrap-panic (as-max-len? (append acc service-id) u10)))
    acc
  )
)

(define-private (get-transfer-record (transfer-id uint) (acc (list 5 { device-id: uint, transfer-id: uint, previous-owner: principal, new-owner: principal, transfer-date: uint, transfer-price: (optional uint) })))
  acc
)
