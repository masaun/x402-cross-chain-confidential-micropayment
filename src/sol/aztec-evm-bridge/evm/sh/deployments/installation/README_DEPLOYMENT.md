# Cronos EVM Testnet - Contract Deployment Summary

## 📁 Files Created

All deployment-related files are in the `./src/sol/aztec-evm-bridge/evm/` directory:

### Configuration Files
- **`.env`** - Environment variables for deployment (gitignored, needs to be configured)
- **`.env.example`** - Template showing all required environment variables

### Deployment Scripts
- **`deploy-cronos.sh`** - Main deployment script using Foundry's deployment script
- **`deploy-cronos-individual.sh`** - Interactive script for deploying contracts individually
- **`install-deps.sh`** - Script to install all required Foundry dependencies

### Documentation
- **`DEPLOYMENT_GUIDE.md`** - Comprehensive deployment guide with all details
- **`QUICKSTART.md`** - Quick reference for deployment
- **`README_DEPLOYMENT.md`** - This file

## 🚀 Quick Start

### Step 1: Install Dependencies

```bash
cd src/sol/aztec-evm-bridge/evm
./install-deps.sh
```

Or manually install dependencies:

```bash
forge install foundry-rs/forge-std \
  openzeppelin/openzeppelin-contracts \
  uniswap/permit2 \
  hyperlane-xyz/hyperlane-monorepo \
  ethereum-optimism/optimism \
  AztecProtocol/aztec-packages
```

### Step 2: Build Contracts

```bash
forge build
```

### Step 3: Configure Environment

Edit `.env` file and fill in:

```bash
PRIVATE_KEY=your_actual_private_key        # Get from MetaMask
AZTEC_INBOX=0x...                          # Your Aztec Inbox address
AZTEC_OUTBOX=0x...                         # Your Aztec Outbox address
ANCHOR_STATE_REGISTRY=0x...                # Your Anchor State Registry
AZTEC_GATEWAY_7683=0x...                   # Your Aztec Gateway (bytes32)
```

### Step 4: Get Test CRO

Get testnet CRO from: https://cronos.org/faucet

### Step 5: Deploy

```bash
./deploy-cronos.sh
```

Or use the interactive script:

```bash
./deploy-cronos-individual.sh
```

## 📋 Contracts to Deploy

### 1. L2Gateway7683
- **Purpose**: Gateway contract for cross-chain messaging between Cronos EVM and Aztec
- **Constructor Params**:
  - `permit2`: Address of Permit2 contract (default: `0x000000000022D473030F116dDEE9F6B43aC78BA3`)

### 2. Forwarder
- **Purpose**: Forwards messages from L2Gateway to Aztec network
- **Constructor Params**:
  - `l2Gateway`: Address of deployed L2Gateway7683
  - `aztecInbox`: Aztec Inbox contract address
  - `aztecOutbox`: Aztec Outbox contract address
  - `anchorStateRegistry`: Anchor State Registry address

## 🔧 Post-Deployment Configuration

After deployment, configure the contracts:

```bash
# Set forwarder address in L2Gateway
cast send $L2_GATEWAY_ADDRESS \
  "setForwarder(address)" $FORWARDER_ADDRESS \
  --private-key $PRIVATE_KEY \
  --rpc-url $RPC_URL

# Set Aztec Gateway in L2Gateway
cast send $L2_GATEWAY_ADDRESS \
  "setAztecGateway7683(bytes32)" $AZTEC_GATEWAY_7683 \
  --private-key $PRIVATE_KEY \
  --rpc-url $RPC_URL

# Set Aztec Gateway in Forwarder
cast send $FORWARDER_ADDRESS \
  "setAztecGateway7683(bytes32)" $AZTEC_GATEWAY_7683 \
  --private-key $PRIVATE_KEY \
  --rpc-url $RPC_URL
```

## 📍 Network Information

### Cronos Testnet
- **Chain ID**: 338
- **RPC URL**: https://evm-t3.cronos.org
- **Explorer**: https://explorer.cronos.org/testnet
- **Faucet**: https://cronos.org/faucet
- **Currency**: TCRO (Test CRO)

## 📝 Deployment Output

Deployment addresses will be saved to:
```
./deployments/deployment.json
```

Example output:
```json
{
  "L2Gateway7683": "0x...",
  "Forwarder": "0x..."
}
```

## ⚠️ Important Notes

1. **Never commit `.env`** - It contains your private key
2. **Test with small amounts first** - Verify everything works before mainnet
3. **Save deployment addresses** - Keep a record of all deployed contracts
4. **Verify contracts** - Always verify on the block explorer

## 🔗 References

- [Deployment Guide](./DEPLOYMENT_GUIDE.md) - Full documentation
- [Quick Start](./QUICKSTART.md) - Quick reference
- [Aztec-EVM Bridge Repo](https://github.com/substance-labs/aztec-evm-bridge)
- [Cronos Docs](https://docs.cronos.org/)

## 📞 Troubleshooting

### Dependencies Not Installing
```bash
# Remove lib directory and reinstall
rm -rf lib
./install-deps.sh
```

### Build Failures
```bash
# Clean and rebuild
forge clean
forge build
```

### Transaction Failures
- Check you have enough test CRO
- Verify all addresses in .env are correct
- Check RPC URL is accessible
- Review gas settings

### Need More Help?
See [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) for detailed troubleshooting steps.

---

## ✅ Deployment Checklist

Before deploying, ensure:

- [ ] Foundry is installed (`forge --version`)
- [ ] Dependencies are installed (`./install-deps.sh`)
- [ ] Contracts compile (`forge build`)
- [ ] `.env` file is configured
- [ ] Test CRO is in wallet
- [ ] Aztec network addresses are available
- [ ] Private key is set (without 0x prefix)

After deploying:

- [ ] Deployment successful
- [ ] Addresses saved to deployment.json
- [ ] Forwarder set in L2Gateway
- [ ] Aztec Gateway set in both contracts
- [ ] Contracts verified on explorer
- [ ] Test transactions completed
- [ ] Addresses documented for team

---

**Last Updated**: January 20, 2026
