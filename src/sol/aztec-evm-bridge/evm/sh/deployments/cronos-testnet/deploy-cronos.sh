#!/bin/bash

# Deployment script for L2Gateway7683 and Forwarder contracts on Cronos EVM Testnet
# This script uses Foundry's forge to deploy the contracts

set -e

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Navigate to the evm root directory (3 levels up from sh/deployments/cronos-testnet)
EVM_ROOT="$SCRIPT_DIR/../../.."
cd "$EVM_ROOT"

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${RED}Error: .env file not found!${NC}"
    echo "Please create a .env file based on .env.example and fill in the required values."
    exit 1
fi

# Load environment variables
source .env

# Validate required environment variables
if [ -z "$PRIVATE_KEY" ] || [ "$PRIVATE_KEY" = "your_private_key_here" ]; then
    echo -e "${RED}Error: PRIVATE_KEY not set in .env file${NC}"
    exit 1
fi

if [ -z "$RPC_URL" ]; then
    echo -e "${RED}Error: RPC_URL not set in .env file${NC}"
    exit 1
fi

if [ -z "$PERMIT2" ]; then
    echo -e "${RED}Error: PERMIT2 address not set in .env file${NC}"
    exit 1
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Deploying Contracts to Cronos Testnet${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}RPC URL:${NC} $RPC_URL"
echo ""

# Create deployments directory if it doesn't exist
mkdir -p deployments

# Deploy using Foundry script
echo -e "${YELLOW}Running deployment script...${NC}"
forge script script/Deploy.s.sol:Deploy \
    --rpc-url "$RPC_URL" \
    --broadcast \
    -vvvv

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Deployment details saved to:${NC} deployments/deployment.json"
echo ""
echo -e "${YELLOW}Manual Verification Required:${NC}"
echo "Cronos Testnet is not supported by Sourcify auto-verification."
echo "Please verify your contracts manually at:"
echo "  https://explorer.cronos.org/testnet"
echo ""
echo -e "${YELLOW}Post-Deployment Configuration:${NC}"
echo "Make sure to update the AZTEC_GATEWAY_7683 addresses in both contracts"
echo "if they haven't been set yet. You can do this using:"
echo ""
echo "  L2Gateway7683.setAztecGateway7683(<aztec_gateway_address>)"
echo "  Forwarder.setAztecGateway7683(<aztec_gateway_address>)"
echo ""
