# Cronos EVM Testnet Deployment Guide

This guide explains how to deploy the L2Gateway7683 and Forwarder contracts to Cronos EVM Testnet.

## Prerequisites

1. **Foundry** installed on your system
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

2. **Cronos Testnet CRO** for gas fees
   - Get testnet CRO from the [Cronos Testnet Faucet](https://cronos.org/faucet)

3. **Private Key** from your wallet (e.g., MetaMask)

4. **Required Contract Addresses**:
   - Permit2 contract address (Universal: `0x000000000022D473030F116dDEE9F6B43aC78BA3`)
   - Aztec Inbox contract address
   - Aztec Outbox contract address
   - Anchor State Registry contract address
   - Aztec Gateway 7683 contract address (bytes32 format)

## Setup

### 1. Configure Environment Variables

Copy the example environment file and fill in your values:

```bash
cp .env.example .env
```

Edit `.env` and fill in the required values:

```bash
# Your deployment wallet private key (without 0x prefix)
PRIVATE_KEY=your_private_key_here

# Cronos Testnet RPC URL
RPC_URL=https://evm-t3.cronos.org

# Permit2 contract address
PERMIT2=0x000000000022D473030F116dDEE9F6B43aC78BA3

# Aztec network addresses
AZTEC_INBOX=your_aztec_inbox_address_here
AZTEC_OUTBOX=your_aztec_outbox_address_here
ANCHOR_STATE_REGISTRY=your_anchor_state_registry_address_here
AZTEC_GATEWAY_7683=0x0000000000000000000000000000000000000000000000000000000000000000

# Deployment options
DEPLOY_L2_GATEWAY=true
DEPLOY_FORWARDER=true
```

### 2. Install Dependencies

```bash
forge install
```

### 3. Build Contracts

```bash
forge build
```

## Deployment Methods

You can deploy the contracts using either the Foundry script or individual forge create commands.

### Method 1: Using Foundry Script (Recommended)

Deploy both contracts together:

```bash
./deploy-cronos.sh
```

This script will:
- Deploy L2Gateway7683 with the Permit2 address
- Deploy Forwarder with the L2Gateway address and Aztec network addresses
- Automatically set the forwarder address in the gateway
- Save deployment addresses to `deployments/deployment.json`

### Method 2: Using Individual Deployment Script

For more control over the deployment process:

```bash
./deploy-cronos-individual.sh
```

This interactive script allows you to:
1. Deploy L2Gateway7683 only
2. Deploy Forwarder only (requires L2Gateway address)
3. Deploy both contracts with a prompt for the gateway address

### Method 3: Manual Deployment with Forge Create

#### Deploy L2Gateway7683

```bash
forge create --broadcast \
  --private-key $PRIVATE_KEY \
  --rpc-url $RPC_URL \
  --verify \
  src/L2Gateway7683.sol:L2Gateway7683 \
  --constructor-args $PERMIT2
```

#### Deploy Forwarder

After deploying L2Gateway7683, update `L2_GATEWAY_ADDRESS` in `.env`, then:

```bash
forge create --broadcast \
  --private-key $PRIVATE_KEY \
  --rpc-url $RPC_URL \
  --verify \
  src/Forwarder.sol:Forwarder \
  --constructor-args \
    $L2_GATEWAY_ADDRESS \
    $AZTEC_INBOX \
    $AZTEC_OUTBOX \
    $ANCHOR_STATE_REGISTRY
```

## Post-Deployment Configuration

After deploying both contracts, you need to configure them:

### 1. Set Forwarder in L2Gateway7683

```bash
cast send $L2_GATEWAY_ADDRESS \
  "setForwarder(address)" \
  $FORWARDER_ADDRESS \
  --private-key $PRIVATE_KEY \
  --rpc-url $RPC_URL
```

### 2. Set Aztec Gateway in L2Gateway7683

```bash
cast send $L2_GATEWAY_ADDRESS \
  "setAztecGateway7683(bytes32)" \
  $AZTEC_GATEWAY_7683 \
  --private-key $PRIVATE_KEY \
  --rpc-url $RPC_URL
```

### 3. Set Aztec Gateway in Forwarder

```bash
cast send $FORWARDER_ADDRESS \
  "setAztecGateway7683(bytes32)" \
  $AZTEC_GATEWAY_7683 \
  --private-key $PRIVATE_KEY \
  --rpc-url $RPC_URL
```

## Verify Deployment

Check the deployed contracts on Cronos Testnet Explorer:

```bash
# Verify L2Gateway7683
cast call $L2_GATEWAY_ADDRESS "forwarder()(address)" --rpc-url $RPC_URL

# Verify Forwarder
cast call $FORWARDER_ADDRESS "L2_GATEWAY()(address)" --rpc-url $RPC_URL
```

Or visit the [Cronos Testnet Explorer](https://explorer.cronos.org/testnet) and search for your contract addresses.

## Troubleshooting

### Common Issues

1. **"Insufficient funds" error**
   - Ensure you have enough testnet CRO in your wallet
   - Get more from the [Cronos Testnet Faucet](https://cronos.org/faucet)

2. **"Nonce too low" error**
   - Wait a few moments and try again
   - Check pending transactions in the Cronos explorer

3. **"Contract verification failed"**
   - Verification may take a few minutes
   - You can verify manually on the Cronos explorer later

4. **"RPC error"**
   - Check your internet connection
   - Try an alternative RPC URL if available

### Getting Help

- Check the [main README](./README.md) for more information
- Review the [TROUBLESHOOTING guide](./TROUBLESHOOTING.md)
- Visit the [Aztec-EVM Bridge repository](https://github.com/substance-labs/aztec-evm-bridge)

## Network Information

### Cronos Testnet

- **Network Name**: Cronos Testnet
- **RPC URL**: https://evm-t3.cronos.org
- **Chain ID**: 338
- **Currency Symbol**: TCRO
- **Block Explorer**: https://explorer.cronos.org/testnet

## Security Notes

⚠️ **IMPORTANT**: 
- Never commit your `.env` file to version control
- Keep your private keys secure
- Use a separate wallet for testnet deployments
- Double-check all addresses before deployment
- Verify contract source code after deployment

## Next Steps

After successful deployment:

1. Save the deployed contract addresses
2. Update your application configuration with the new addresses
3. Test the contracts with small transactions first
4. Monitor the contracts on the Cronos explorer
5. Document the deployment for your team

## Deployment Checklist

- [ ] Install Foundry
- [ ] Get testnet CRO from faucet
- [ ] Create and configure `.env` file
- [ ] Build contracts with `forge build`
- [ ] Deploy L2Gateway7683
- [ ] Deploy Forwarder
- [ ] Set forwarder address in gateway
- [ ] Set Aztec gateway addresses in both contracts
- [ ] Verify contracts on explorer
- [ ] Test contract functionality
- [ ] Document deployment addresses

## Contract Addresses (Template)

After deployment, record your contract addresses here:

```
Deployment Date: [DATE]
Network: Cronos Testnet (Chain ID: 338)

L2Gateway7683: 0x...
Forwarder: 0x...
Permit2: 0x000000000022D473030F116dDEE9F6B43aC78BA3
Aztec Inbox: 0x...
Aztec Outbox: 0x...
Anchor State Registry: 0x...
Aztec Gateway 7683: 0x...

Deployer Address: 0x...
Transaction Hashes:
- L2Gateway7683: 0x...
- Forwarder: 0x...
```
