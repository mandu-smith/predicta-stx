# PredictaSTX 🚀

[![Clarity](https://img.shields.io/badge/Clarity-3.0-blue.svg)](https://clarity-lang.org/)
[![Stacks](https://img.shields.io/badge/Stacks-Blockchain-orange.svg)](https://www.stacks.co/)
[![License](https://img.shields.io/badge/license-ISC-green.svg)](LICENSE)

> Advanced Bitcoin Price Speculation Platform on Stacks Blockchain

PredictaSTX is a sophisticated decentralized prediction marketplace that enables STX holders to speculate on Bitcoin's future price movements with competitive rewards and transparent oracle-based settlements.

## 🌟 Key Features

- **Binary Prediction Markets**: Up/down Bitcoin price speculation with defined time windows
- **Proportional Rewards**: Fair distribution of winnings among successful participants
- **Oracle Integration**: Reliable price feeds for transparent market resolution
- **Flexible Staking**: Customizable stake requirements and fee structures
- **Automated Lifecycle**: Fully automated market creation, execution, and settlement
- **Enhanced Security**: Robust fund protection and market integrity mechanisms

## 📋 Table of Contents

- [Architecture](#architecture)
- [Smart Contract Overview](#smart-contract-overview)
- [Installation](#installation)
- [Usage](#usage)
  - [Creating Markets](#creating-markets)
  - [Making Predictions](#making-predictions)
  - [Claiming Winnings](#claiming-winnings)
- [Testing](#testing)
- [Deployment](#deployment)
- [API Reference](#api-reference)
- [Security](#security)
- [Contributing](#contributing)
- [License](#license)

## 🏗️ Architecture

PredictaSTX is built on the Stacks blockchain using Clarity smart contracts, providing:

- **Trustless Execution**: No intermediaries required for market operations
- **Transparent Settlement**: Oracle-based price resolution with verifiable outcomes
- **Escrow Management**: Secure fund holding during active prediction periods
- **Fee Distribution**: Automated platform fee collection and distribution

```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│   Users     │───▶│  PredictaSTX │───▶│   Oracle    │
│             │    │   Contract   │    │             │
└─────────────┘    └──────────────┘    └─────────────┘
                           │
                           ▼
                   ┌──────────────┐
                   │  STX Escrow  │
                   │   & Rewards  │
                   └──────────────┘
```

## 📝 Smart Contract Overview

### Core Components

#### Data Structures

- **Markets**: Track prediction market state, stakes, and resolution data
- **User Predictions**: Store individual prediction details and claim status
- **Oracle Integration**: Manage authorized price feed sources

#### Key Functions

##### Public Functions

- `create-market`: Initialize new prediction markets with time parameters
- `make-prediction`: Submit Bitcoin price predictions with STX stakes
- `resolve-market`: Finalize markets with official price data (Oracle only)
- `claim-winnings`: Process payouts for successful predictions

##### Administrative Functions

- `set-oracle-address`: Update authorized oracle for price feeds
- `set-minimum-stake`: Adjust minimum participation requirements
- `set-fee-percentage`: Modify platform fee structure
- `withdraw-fees`: Extract accumulated platform revenues

##### Read-Only Functions

- `get-market`: Retrieve market information by ID
- `get-user-prediction`: Fetch user prediction details
- `get-contract-balance`: Check contract STX holdings

### Error Handling

```clarity
err-owner-only (u100)           ;; Unauthorized access attempt
err-not-found (u101)            ;; Market/prediction not found
err-invalid-prediction (u102)    ;; Invalid prediction parameters
err-market-closed (u103)         ;; Market not accepting predictions
err-already-claimed (u104)       ;; Winnings already claimed
err-insufficient-balance (u105)  ;; Insufficient STX balance
err-invalid-parameter (u106)     ;; Invalid function parameters
```

## ⚙️ Installation

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) v2.0+
- [Node.js](https://nodejs.org/) v18+
- [npm](https://www.npmjs.com/) or [yarn](https://yarnpkg.com/)

### Setup

```bash
# Clone the repository
git clone https://github.com/mandu-smith/predicta-stx.git
cd predicta-stx

# Install dependencies
npm install

# Verify Clarinet installation
clarinet --version
```

### Configuration

The project includes pre-configured network settings:

- **Devnet**: `settings/Devnet.toml`
- **Testnet**: `settings/Testnet.toml`
- **Mainnet**: `settings/Mainnet.toml`

## 🚀 Usage

### Creating Markets

Markets can only be created by the contract owner (oracle address):

```clarity
(contract-call? .predicta-stx create-market 
  u45000 ;; start-price (Bitcoin price in satoshis)
  u1000  ;; start-block
  u2000  ;; end-block
)
```

### Making Predictions

Users stake STX tokens on their Bitcoin price predictions:

```clarity
(contract-call? .predicta-stx make-prediction 
  u0           ;; market-id
  "up"         ;; prediction ("up" or "down")
  u1000000     ;; stake amount (1 STX in microSTX)
)
```

### Claiming Winnings

Successful predictors claim their proportional rewards:

```clarity
(contract-call? .predicta-stx claim-winnings u0) ;; market-id
```

## 🧪 Testing

The project includes comprehensive test suites using Vitest and Clarinet SDK.

```bash
# Run all tests
npm test

# Run tests with coverage and cost analysis
npm run test:report

# Watch mode for development
npm run test:watch
```

### Test Structure

```
tests/
├── predicta-stx.test.ts    # Main contract test suite
├── market-creation.test.ts  # Market creation scenarios
├── predictions.test.ts      # Prediction mechanics
└── settlements.test.ts      # Payout and settlement logic
```

## 📊 Deployment

### Local Development

```bash
# Start Clarinet console
clarinet console

# Deploy to devnet
clarinet integrate
```

### Testnet Deployment

```bash
# Check deployment plan
clarinet deployments generate --testnet

# Deploy to testnet
clarinet deployments apply --testnet
```

### Mainnet Deployment

```bash
# Generate mainnet deployment plan
clarinet deployments generate --mainnet

# Apply deployment (requires funded deployer account)
clarinet deployments apply --mainnet
```

## 📚 API Reference

### Market Management

#### `create-market`

Creates a new Bitcoin price prediction market.

**Parameters:**

- `start-price` (uint): Initial Bitcoin price in satoshis
- `start-block` (uint): Block height when predictions begin
- `end-block` (uint): Block height when market closes

**Returns:** `(response uint uint)` - Market ID or error

#### `resolve-market`

Finalizes market with official Bitcoin price (Oracle only).

**Parameters:**

- `market-id` (uint): Target market identifier
- `end-price` (uint): Final Bitcoin price in satoshis

**Returns:** `(response bool uint)` - Success or error

### Prediction Operations

#### `make-prediction`

Submits a Bitcoin price prediction with STX stake.

**Parameters:**

- `market-id` (uint): Target market identifier
- `prediction` (string-ascii 4): "up" or "down"
- `stake` (uint): STX amount in microSTX

**Returns:** `(response bool uint)` - Success or error

#### `claim-winnings`

Processes payout for successful predictions.

**Parameters:**

- `market-id` (uint): Target market identifier

**Returns:** `(response uint uint)` - Payout amount or error

### Query Functions

#### `get-market`

Retrieves complete market information.

**Parameters:**

- `market-id` (uint): Market identifier

**Returns:**

```clarity
(optional {
  start-price: uint,
  end-price: uint,
  total-up-stake: uint,
  total-down-stake: uint,
  start-block: uint,
  end-block: uint,
  resolved: bool
})
```

#### `get-user-prediction`

Fetches user's prediction details for specific market.

**Parameters:**

- `market-id` (uint): Market identifier
- `user` (principal): User address

**Returns:**

```clarity
(optional {
  prediction: (string-ascii 4),
  stake: uint,
  claimed: bool
})
```

## 🔒 Security

### Audit Status

- [ ] Internal security review completed
- [ ] External audit pending
- [ ] Bug bounty program active

### Security Features

- **Access Controls**: Owner-only functions with proper validation
- **Input Validation**: Comprehensive parameter checking
- **Reentrancy Protection**: State updates before external calls
- **Overflow Protection**: Safe arithmetic operations
- **Escrow Security**: Funds held in contract-controlled addresses

### Best Practices

1. **Oracle Security**: Verify oracle address before deployment
2. **Stake Limits**: Set appropriate minimum stakes to prevent spam
3. **Fee Management**: Monitor fee percentages to ensure sustainability
4. **Market Timing**: Ensure adequate time windows for predictions

## 🤝 Contributing

We welcome contributions to PredictaSTX! Please follow these guidelines:

### Development Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes with comprehensive tests
4. Ensure all tests pass (`npm run test`)
5. Format code (`clarinet fmt --in-place`)
6. Commit changes (`git commit -m 'Add amazing feature'`)
7. Push to branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

### Code Standards

- Follow Clarity best practices and conventions
- Add comprehensive test coverage for new features
- Include documentation for public functions
- Maintain consistent code formatting

### Reporting Issues

- Use GitHub Issues for bug reports and feature requests
- Include detailed reproduction steps
- Provide relevant error messages and logs

## 📄 License

This project is licensed under the ISC License - see the [LICENSE](LICENSE) file for details.
