# Quick Start - Cronos EVM Testnet Deployment

## Files Created

1. **.env** - Environment configuration (needs to be filled in)
2. **.env.example** - Template for environment variables
3. **deploy-cronos.sh** - Main deployment script using Foundry script
4. **deploy-cronos-individual.sh** - Interactive script for individual contract deployment
5. **DEPLOYMENT_GUIDE.md** - Comprehensive deployment documentation

## Before You Deploy

### Step 1: Configure .env File

Edit the `.env` file and fill in the following required values:

```bash
# 1. Your wallet private key (get from MetaMask - Settings > Security & Privacy > Show private key)
PRIVATE_KEY=your_actual_private_key_without_0x

# 2. Aztec network addresses (from your Aztec deployment)
AZTEC_INBOX=0x... # Your Aztec Inbox contract address
AZTEC_OUTBOX=0x... # Your Aztec Outbox contract address  
ANCHOR_STATE_REGISTRY=0x... # Your Anchor State Registry address
AZTEC_GATEWAY_7683=0x0000... # Your Aztec Gateway bytes32 address
```

### Step 2: Get Testnet CRO

Get testnet CRO from the Cronos Faucet:
https://cronos.org/faucet

### Step 3: Run Deployment

Choose one of these methods:

**Option A - Deploy Both Contracts Together:**
```bash
./deploy-cronos.sh
```

**Option B - Deploy Individually:**
```bash
./deploy-cronos-individual.sh
```

**Option C - Manual Deployment:**
See the DEPLOYMENT_GUIDE.md for manual `forge create` commands.

## After Deployment

1. **Save the deployed addresses** from the output
2. **Configure the contracts** by calling:
   - `L2Gateway7683.setForwarder(forwarderAddress)`
   - `L2Gateway7683.setAztecGateway7683(aztecGatewayBytes32)`
   - `Forwarder.setAztecGateway7683(aztecGatewayBytes32)`

3. **Verify on Cronos Explorer:**
   https://explorer.cronos.org/testnet

## Need Help?

- See [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) for detailed instructions
- Check [README.md](./README.md) for more information
- Visit the [Aztec-EVM Bridge repository](https://github.com/substance-labs/aztec-evm-bridge)

## Network Info

- **Network**: Cronos Testnet
- **Chain ID**: 338
- **RPC**: https://evm-t3.cronos.org
- **Explorer**: https://explorer.cronos.org/testnet
- **Faucet**: https://cronos.org/faucet
