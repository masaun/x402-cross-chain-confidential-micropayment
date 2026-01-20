#!/bin/bash

# Script to install all Foundry dependencies for the EVM contracts

set -e

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Installing Foundry Dependencies${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

echo -e "${YELLOW}Installing forge-std...${NC}"
forge install foundry-rs/forge-std

echo -e "${YELLOW}Installing OpenZeppelin contracts...${NC}"
forge install openzeppelin/openzeppelin-contracts

echo -e "${YELLOW}Installing Permit2...${NC}"
forge install uniswap/permit2

echo -e "${YELLOW}Installing Hyperlane...${NC}"
forge install hyperlane-xyz/hyperlane-monorepo

echo -e "${YELLOW}Installing Optimism contracts...${NC}"
forge install ethereum-optimism/optimism

echo -e "${YELLOW}Installing Aztec packages...${NC}"
forge install AztecProtocol/aztec-packages

echo -e "${YELLOW}Installing lib-keccak...${NC}"
forge install ethereum-optimism/lib-keccak

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Dependencies Installed Successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Run 'forge build' to compile contracts"
echo "2. Configure .env file with your deployment settings"
echo "3. Run './deploy-cronos.sh' to deploy to Cronos testnet"
echo ""
