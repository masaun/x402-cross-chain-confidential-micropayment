# X402 Facilitator Server

Express server implementing the Cronos X402 Facilitator end-to-end payment flow using the `@crypto.com/facilitator-client` library.

## Features

- ✅ EIP-3009 payment header generation
- ✅ X402 payment requirements creation
- ✅ Payment verification
- ✅ On-chain payment settlement
- ✅ Full end-to-end payment flow
- ✅ Support for Cronos Mainnet and Testnet

## Setup

### 1. Install Dependencies

```bash
npm install
```

### 2. Configure Environment

Copy the example environment file and configure your settings:

```bash
cp .env.example .env
```

Edit `.env` and set:
- `PORT`: Server port (default: 8000)
- `CRONOS_NETWORK`: Either "mainnet" or "testnet"
- `PRIVATE_KEY`: Your wallet private key for signing transactions

### 3. Run the Server

Development mode (with hot reload):
```bash
npm run dev
```

Build and run in production:
```bash
npm run build
npm start
```

## API Endpoints

### Health Check
```http
GET /health
```
Returns server status and configured network.

### Get Supported Networks
```http
GET /supported
```
Returns supported networks, schemes, and capabilities.

### Generate Payment Header
```http
POST /generate-payment-header
Content-Type: application/json

{
  "to": "0xRecipientAddress",
  "value": "1000000",
  "validBefore": 1234567890  // Optional, defaults to 10 minutes
}
```

### Generate Payment Requirements
```http
POST /generate-payment-requirements
Content-Type: application/json

{
  "payTo": "0xRecipientAddress",
  "description": "Premium API access",
  "maxAmountRequired": "1000000"
}
```

### Verify Payment
```http
POST /verify-payment
Content-Type: application/json

{
  "header": "base64_encoded_header",
  "requirements": { ... }
}
```

### Settle Payment
```http
POST /settle-payment
Content-Type: application/json

{
  "header": "base64_encoded_header",
  "requirements": { ... }
}
```

### Complete Payment Flow (E2E)
```http
POST /payment/full-flow
Content-Type: application/json

{
  "receiverAddress": "0xRecipientAddress",
  "amount": "1000000",
  "description": "Premium API access"
}
```

This endpoint executes the complete flow:
1. Generates payment header
2. Creates payment requirements
3. Verifies the payment
4. Settles the payment on-chain

Returns the transaction hash and all intermediate results.

## Example Usage

### Using cURL

```bash
# Complete payment flow
curl -X POST http://localhost:8000/payment/full-flow \
  -H "Content-Type: application/json" \
  -d '{
    "receiverAddress": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
    "amount": "1000000",
    "description": "Payment for Order #123"
  }'
```

### Using JavaScript/TypeScript

```typescript
const response = await fetch('http://localhost:8000/payment/full-flow', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    receiverAddress: '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb',
    amount: '1000000', // 1 USDC (6 decimals)
    description: 'Payment for Order #123',
  }),
});

const result = await response.json();
console.log('Transaction:', result.txHash);
```

## Payment Amount Format

The `amount` field should be in the token's base units:
- For USDC (6 decimals): `1000000` = 1 USDC
- For tokens with 18 decimals: `1000000000000000000` = 1 token

## Network Configuration

### Testnet (Default)
- Network: Cronos Testnet
- RPC URL: https://evm-t3.cronos.org

### Mainnet
- Network: Cronos Mainnet
- RPC URL: https://evm.cronos.org

## Security Notes

⚠️ **Important Security Considerations:**

1. Never commit your `.env` file or private keys to version control
2. Use environment variables or secure key management in production
3. Implement proper authentication and authorization for production use
4. Add rate limiting and request validation
5. Use HTTPS in production environments
6. Consider using a hardware wallet or key management service for production

## License

MIT
