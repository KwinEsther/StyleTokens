# StyleTokens

A tokenized marketplace for fashion items built on the Stacks blockchain.

## Overview

StyleTokens enables fashion designers and brands to tokenize physical fashion items, creating a secure and transparent marketplace for buying and selling clothing, accessories, and other fashion goods.

## Features

- Tokenize fashion items with detailed metadata
- List items for sale with customizable pricing
- Purchase items directly with STX tokens
- Track ownership history and provenance
- Categorize and search fashion items

## Smart Contract Functions

### List Item
Allows sellers to tokenize and list fashion items with detailed information including name, description, image, category, size, and price.

### Purchase Item
Enables buyers to purchase listed fashion items directly with STX tokens.

### Read-only Functions
- `get-listing`: Retrieve details for a specific listing
- `get-seller-listings`: Get all items listed by a specific seller
- `get-buyer-purchases`: Get all items purchased by a specific buyer
- `get-listings-by-category`: Search listings by category

## Getting Started

1. Clone this repository
2. Install [Clarinet](https://github.com/hirosystems/clarinet)
3. Run `clarinet check` to verify the contract
4. Deploy using Clarinet or the Stacks CLI