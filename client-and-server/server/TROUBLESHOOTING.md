# Troubleshooting Payment Failures

## Common Error: "ERC20: transfer amount exceeds balance"

This error occurs when the sender account doesn't have enough tokens to complete the transfer.

### Root Causes

1. **Insufficient token balance** - The sender account has less tokens than the requested transfer amount
2. **Incorrect decimal handling** - Amount is interpreted as wei instead of human-readable units
3. **Wrong token contract** - Trying to use a token that the sender doesn't own

### Diagnostic Steps

#### 1. Check Token Balance Using CLI Script

```bash
cd /path/to/server
npx tsx scripts/check-balance.ts <TOKEN_ADDRESS> <SENDER_ADDRESS> [SPENDER_ADDRESS]
```

**Example from your error:**
```bash
npx tsx scripts/check-balance.ts \
  0xc01efAaF7C5C61bEbFAeb358E1161b537b8bC0e0 \
  0xad14B261c7B9D282AdC1410633266F0AE37468AA
```

#### 2. Check Balance Using API Endpoint

Start your server and call:

```bash
curl "http://localhost:8000/token-info/0xc01efAaF7C5C61bEbFAeb358E1161b537b8bC0e0/0xad14B261c7B9D282AdC1410633266F0AE37468AA"
```

Response example:
```json
{
  "token": {
    "address": "0xc01efAaF7C5C61bEbFAeb358E1161b537b8bC0e0",
    "name": "USD Coin",
    "symbol": "USDC",
    "decimals": 6
  },
  "account": {
    "address": "0xad14B261c7B9D282AdC1410633266F0AE37468AA",
    "balanceRaw": "0",
    "balanceFormatted": "0.0"
  }
}
```

### Solutions

#### Solution 1: Fund the Sender Account

If balance is 0 or insufficient, you need to acquire tokens:

**For Testnet:**
- Use a faucet (if available for your token)
- Mint tokens if you control the token contract
- Transfer from another account that has tokens

**Example transfer command (if you have tokens elsewhere):**
```bash
# Using cast (Foundry)
cast send <TOKEN_ADDRESS> \
  "transfer(address,uint256)" \
  <RECIPIENT_ADDRESS> \
  <AMOUNT_IN_WEI> \
  --private-key <PRIVATE_KEY> \
  --rpc-url https://evm-t3.cronos.org
```

#### Solution 2: Reduce the Payment Amount

If you have some tokens but not enough, reduce the amount in your request:

```bash
curl -X POST http://localhost:8000/payment/full-flow \
  -H "Content-Type: application/json" \
  -d '{
    "receiverAddress": "0x652579C23f87CE1F36676804BFdc40F99c5A9009",
    "amount": "0.1",
    "description": "Smaller test payment"
  }'
```

#### Solution 3: Fix Decimal Conversion (If Applicable)

If the facilitator expects amounts in wei but you're passing human-readable amounts, ensure proper conversion:

```typescript
import { ethers } from 'ethers';

// If token has 6 decimals (like USDC)
const humanAmount = "1"; // 1 USDC
const decimals = 6;
const weiAmount = ethers.parseUnits(humanAmount, decimals);
// Result: "1000000" (1 million)

// For 18 decimals (like most ERC20s)
const weiAmount18 = ethers.parseUnits("1", 18);
// Result: "1000000000000000000"
```

### Understanding Your Error

From your error message:
- **Token Contract**: `0xc01efAaF7C5C61bEbFAeb358E1161b537b8bC0e0`
- **Sender (from)**: `0xad14B261c7B9D282AdC1410633266F0AE37468AA`
- **Receiver (to in data)**: `0x652579c23f87ce1f36676804bfdc40f99c5a9009`
- **Amount in transaction**: `0x0000000000000000000000000000000000000000000000000000000000000001` (which is `1` in wei)

**Key Issue**: You passed `"amount": "1"` which was interpreted as `1 wei`. If the token has 6 decimals (like USDC), you'd need `1000000` wei to represent 1 token. If it has 18 decimals, you'd need `1000000000000000000` wei.

### Quick Fix Commands

**Check what you actually have:**
```bash
# Restart server first if needed
curl "http://localhost:8000/token-info/0xc01efAaF7C5C61bEbFAeb358E1161b537b8bC0e0/0xad14B261c7B9D282AdC1410633266F0AE37468AA"
```

**If balance shows 0**, you need to fund the account first.

**If balance is > 0 but small**, try a tiny amount like `"0.000001"`.

### Environment Check

Verify your `.env` has the correct settings:

```bash
PRIVATE_KEY=0x...  # Private key for 0xad14B261c7B9D282AdC1410633266F0AE37468AA
CRONOS_NETWORK=testnet
PORT=8000
```

Make sure the `PRIVATE_KEY` corresponds to the sender address `0xad14B261c7B9D282AdC1410633266F0AE37468AA`.

### Next Steps

1. Run the balance check to see actual token balance
2. If balance is 0, acquire test tokens
3. Retry the payment with a realistic amount based on your balance
4. If still failing, check if allowance is needed (for `transferFrom` operations)
