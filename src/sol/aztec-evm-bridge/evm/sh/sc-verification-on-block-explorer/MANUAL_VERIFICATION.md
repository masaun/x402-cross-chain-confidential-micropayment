# Manual Contract Verification on Cronos Testnet

Since Cronos Testnet (Chain ID 338) is not supported by Sourcify for automatic verification, you'll need to verify your contracts manually on the Cronos Explorer.

## Deployed Contracts

Based on your deployment, you have:
- **L2Gateway7683**: `0x...`

## How to Verify Manually

### Method 1: Using Cronos Explorer Web Interface

1. **Visit Cronos Testnet Explorer**
   - Go to: https://explorer.cronos.org/testnet
   - Search for your contract address

2. **Navigate to Contract Tab**
   - Click on the "Contract" tab
   - Click "Verify and Publish"

3. **Fill in Contract Details**
   - **Contract Address**: `0x...`
   - **Compiler Type**: Solidity (Single file) or Solidity (Standard Json-Input)
   - **Compiler Version**: `v0.8.28+commit.7893614a`
   - **License Type**: UNLICENSED (or choose appropriate)
   - **Optimization**: Enabled
   - **Runs**: 200

4. **Submit Contract Code**
   - **For Single File**: Flatten your contract and paste the code
   - **For Standard Json-Input**: Upload the standard JSON file

5. **Constructor Arguments**
   - For L2Gateway7683: ABI-encoded Permit2 address
   - For Forwarder: ABI-encoded L2Gateway, AztecInbox, AztecOutbox, AnchorStateRegistry addresses

### Method 2: Using Forge Flatten + Manual Upload (Recommended)

This is the most reliable method for Cronos Testnet:

```bash
# Navigate to the evm directory
cd src/sol/aztec-evm-bridge/evm

# Step 1: Flatten the contract
forge flatten src/L2Gateway7683.sol > L2Gateway7683_flat.sol

# Step 2: Get constructor arguments (ABI-encoded)
cast abi-encode "constructor(address)" 0x000000000022D473030F116dDEE9F6B43aC78BA3

# Step 3: Open the contract page and paste:
# - Contract code: Contents of L2Gateway7683_flat.sol
# - Constructor args: Output from step 2 (hex string)
```

**Note**: Cronos Testnet's Blockscout API endpoint does not support automatic verification via `forge verify-contract`. You must use the web interface.

### Get Flattened Contract Source

To get a flattened version of your contract for verification:

```bash
# Navigate to the evm directory
cd src/sol/aztec-evm-bridge/evm

# Flatten L2Gateway7683
forge flatten src/L2Gateway7683.sol > L2Gateway7683_flattened.sol

# Flatten Forwarder
forge flatten src/Forwarder.sol > Forwarder_flattened.sol
```

### Get Constructor Arguments (ABI Encoded)

```bash
# For L2Gateway7683
cast abi-encode "constructor(address)" $PERMIT2

# For Forwarder
cast abi-encode "constructor(address,address,address,address)" \
  $L2_GATEWAY_ADDRESS \
  $AZTEC_INBOX \
  $AZTEC_OUTBOX \
  $ANCHOR_STATE_REGISTRY
```

## Verification Checklist

- [ ] Copy contract address from deployment output
- [ ] Flatten contract source code
- [ ] Identify correct compiler version (0.8.28)
- [ ] Prepare constructor arguments (ABI encoded)
- [ ] Submit to Cronos Explorer
- [ ] Verify submission was successful
- [ ] Check contract is now verified on explorer

## Troubleshooting

### "Constructor Arguments Invalid"
- Make sure arguments are ABI-encoded
- Verify the order matches the constructor signature
- Remove any `0x` prefix if required by the form

### "Compilation Failed"
- Check you're using the exact compiler version: `0.8.28`
- Ensure optimization is enabled with 200 runs
- Verify you included all imports when flattening

### "Already Verified"
- Contract may have been verified automatically
- Check the contract page on the explorer

## Resources

- **Cronos Testnet Explorer**: https://explorer.cronos.org/testnet
- **Cronos Documentation**: https://docs.cronos.org/
- **Foundry Verification Guide**: https://book.getfoundry.sh/reference/forge/forge-verify-contract

---

**Note**: After verification, your contract source code will be publicly visible on the Cronos Explorer, allowing users to interact with it directly through the web interface.
