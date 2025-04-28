;; StyleTokens - Tokenized fashion marketplace
(define-non-fungible-token style-token uint)

;; Storage
(define-map token-listings uint {
  seller: principal,
  name: (string-utf8 64),
  description: (string-utf8 256),
  image-uri: (string-utf8 256),
  category: (string-utf8 32),
  size: (string-utf8 16),
  price: uint,
  available: bool
})

(define-map seller-tokens principal (list 100 uint))
(define-map buyer-tokens principal (list 100 uint))
(define-data-var token-id-nonce uint u0)

;; Error codes
(define-constant err-not-authorized (err u100))
(define-constant err-token-not-found (err u101))
(define-constant err-token-not-available (err u102))
(define-constant err-insufficient-funds (err u103))
(define-constant err-list-full (err u104))
(define-constant err-invalid-name (err u105))
(define-constant err-invalid-description (err u106))
(define-constant err-invalid-image-uri (err u107))
(define-constant err-invalid-category (err u108))
(define-constant err-invalid-size (err u109))
(define-constant err-invalid-price (err u110))

;; List a fashion item
(define-public (list-item 
  (name (string-utf8 64)) 
  (description (string-utf8 256)) 
  (image-uri (string-utf8 256))
  (category (string-utf8 32))
  (size (string-utf8 16))
  (price uint))
  (begin
    ;; Validate inputs
    (asserts! (> (len name) u0) err-invalid-name)
    (asserts! (> (len description) u0) err-invalid-description)
    (asserts! (> (len image-uri) u0) err-invalid-image-uri)
    (asserts! (> (len category) u0) err-invalid-category)
    (asserts! (> (len size) u0) err-invalid-size)
    (asserts! (> price u0) err-invalid-price)
    
    (let
      ((token-id (var-get token-id-nonce))
       (seller tx-sender)
       (seller-current-tokens (default-to (list) (map-get? seller-tokens seller)))
       (new-seller-tokens (unwrap! (as-max-len? (append seller-current-tokens token-id) u100) err-list-full)))
      
      ;; Mint the token
      (try! (nft-mint? style-token token-id seller))
      
      ;; Store the listing
      (map-set token-listings token-id {
        seller: seller,
        name: name,
        description: description,
        image-uri: image-uri,
        category: category,
        size: size,
        price: price,
        available: true
      })
      
      ;; Update seller's token list with length check
      (map-set seller-tokens seller new-seller-tokens)
      
      ;; Increment the token ID counter
      (var-set token-id-nonce (+ token-id u1))
      
      (ok token-id))))

;; Purchase a fashion item
(define-public (purchase-item (token-id uint))
  (let
    ((listing (unwrap! (map-get? token-listings token-id) err-token-not-found))
     (buyer tx-sender)
     (seller (get seller listing))
     (price (get price listing))
     (available (get available listing))
     (buyer-current-tokens (default-to (list) (map-get? buyer-tokens buyer)))
     (new-buyer-tokens (unwrap! (as-max-len? (append buyer-current-tokens token-id) u100) err-list-full)))
    
    ;; Check if item is available
    (asserts! available err-token-not-available)
    
    ;; Check if buyer has enough funds
    (asserts! (>= (stx-get-balance buyer) price) err-insufficient-funds)
    
    ;; Transfer STX to seller
    (try! (stx-transfer? price buyer seller))
    
    ;; Transfer NFT to buyer
    (try! (nft-transfer? style-token token-id seller buyer))
    
    ;; Update listing availability
    (map-set token-listings token-id (merge listing {available: false}))
    
    ;; Update buyer's token list with length check
    (map-set buyer-tokens buyer new-buyer-tokens)
    
    (ok true)))

;; Get listing details
(define-read-only (get-listing (token-id uint))
  (map-get? token-listings token-id))

;; Get seller's listings
(define-read-only (get-seller-listings (seller principal))
  (default-to (list) (map-get? seller-tokens seller)))

;; Get buyer's purchases
(define-read-only (get-buyer-purchases (buyer principal))
  (default-to (list) (map-get? buyer-tokens buyer)))

;; Search listings by category
(define-read-only (get-listings-by-category (category (string-utf8 32)) (start uint) (end uint))
  (let
    ((result (list)))
    ;; Note: In a real implementation, this would use a more efficient indexing mechanism
    ;; This is a simplified version for demonstration
    result))