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

;; List a fashion item
(define-public (list-item 
  (name (string-utf8 64)) 
  (description (string-utf8 256)) 
  (image-uri (string-utf8 256))
  (category (string-utf8 32))
  (size (string-utf8 16))
  (price uint))
  (let
    ((token-id (var-get token-id-nonce))
     (seller tx-sender)
     (seller-current-tokens (default-to (list) (map-get? seller-tokens seller))))
    
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
    
    ;; Update seller's token list - Fixed: using concat with a list containing the token-id
    (map-set seller-tokens seller (concat seller-current-tokens (list token-id)))
    
    ;; Increment the token ID counter
    (var-set token-id-nonce (+ token-id u1))
    
    (ok token-id)))

;; Purchase a fashion item
(define-public (purchase-item (token-id uint))
  (let
    ((listing (unwrap! (map-get? token-listings token-id) err-token-not-found))
     (buyer tx-sender)
     (seller (get seller listing))
     (price (get price listing))
     (available (get available listing))
     (buyer-current-tokens (default-to (list) (map-get? buyer-tokens buyer))))
    
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
    
    ;; Update buyer's token list - Fixed: using concat with a list containing the token-id
    (map-set buyer-tokens buyer (concat buyer-current-tokens (list token-id)))
    
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