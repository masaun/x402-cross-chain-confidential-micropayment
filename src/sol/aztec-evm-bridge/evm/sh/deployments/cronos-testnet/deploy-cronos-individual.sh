#!/bin/bash

# Individual contract deployment script for Cronos EVM Testnet
# This script allows deploying L2Gateway7683 and Forwarder separately using forge create

set -e

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
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

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Cronos Testnet Contract Deployment${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}RPC URL:${NC} $RPC_URL"
echo ""

# Function to deploy L2Gateway7683
deploy_gateway() {
    echo -e "${BLUE}Deploying L2Gateway7683...${NC}"
    
    if [ -z "$PERMIT2" ]; then
        echo -e "${RED}Error: PERMIT2 address not set in .env file${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Constructor args:${NC}"
    echo -e "  - permit2: $PERMIT2"
    echo ""
    
    forge create --broadcast \
        --private-key "$PRIVATE_KEY" \
        --rpc-url "$RPC_URL" \
        src/L2Gateway7683.sol:L2Gateway7683 \
        --constructor-args "$PERMIT2"
    
    echo ""
    echo -e "${GREEN}✓ L2Gateway7683 deployed successfully!${NC}"
    echo -e "${YELLOW}Note: Verify manually at https://explorer.cronos.org/testnet${NC}"
    echo ""
}

# Function to deploy Forwarder
deploy_forwarder() {
    echo -e "${BLUE}Deploying Forwarder...${NC}"
    
    # Check if L2_GATEWAY_ADDRESS is set
    if [ -z "$L2_GATEWAY_ADDRESS" ]; then
        echo -e "${RED}Error: L2_GATEWAY_ADDRESS not set in .env file${NC}"
        echo "Please deploy L2Gateway7683 first or set L2_GATEWAY_ADDRESS in .env"
        exit 1
    fi
    
    if [ -z "$AZTEC_INBOX" ] || [ "$AZTEC_INBOX" = "your_aztec_inbox_address_here" ]; then
        echo -e "${RED}Error: AZTEC_INBOX address not set in .env file${NC}"
        exit 1
    fi
    
    if [ -z "$AZTEC_OUTBOX" ] || [ "$AZTEC_OUTBOX" = "your_aztec_outbox_address_here" ]; then
        echo -e "${RED}Error: AZTEC_OUTBOX address not set in .env file${NC}"
        exit 1
    fi
    
    if [ -z "$ANCHOR_STATE_REGISTRY" ] || [ "$ANCHOR_STATE_REGISTRY" = "your_anchor_state_registry_address_here" ]; then
        echo -e "${RED}Error: ANCHOR_STATE_REGISTRY address not set in .env file${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Constructor args:${NC}"
    echo -e "  - l2Gateway: $L2_GATEWAY_ADDRESS"
    echo -e "  - aztecInbox: $AZTEC_INBOX"
    echo -e "  - aztecOutbox: $AZTEC_OUTBOX"
    echo -e "  - anchorStateRegistry: $ANCHOR_STATE_REGISTRY"
    echo ""
    
    forge create --broadcast \
        --private-key "$PRIVATE_KEY" \
        --rpc-url "$RPC_URL" \
        src/Forwarder.sol:Forwarder \
        --constructor-args \
        "$L2_GATEWAY_ADDRESS" \
        "$AZTEC_INBOX" \
        "$AZTEC_OUTBOX" \
        "$ANCHOR_STATE_REGISTRY"
    
    echo ""
    echo -e "${GREEN}✓ Forwarder deployed successfully!${NC}"
    echo -e "${YELLOW}Note: Verify manually at https://explorer.cronos.org/testnet${NC}"
    echo ""
}

# Main menu
echo "Select deployment option:"
echo "1) Deploy L2Gateway7683 only"
echo "2) Deploy Forwarder only"
echo "3) Deploy both contracts"
echo ""
read -p "Enter choice [1-3]: " choice

case $choice in
    1)
        deploy_gateway
        ;;
    2)
        deploy_forwarder
        ;;
    3)
        deploy_gateway
        echo ""
        echo -e "${YELLOW}Please update L2_GATEWAY_ADDRESS in .env with the deployed gateway address, then run this script again to deploy Forwarder.${NC}"
        echo -e "${YELLOW}Or manually set the gateway address and press Enter to continue...${NC}"
        read -p "L2_GATEWAY_ADDRESS: " gateway_addr
        if [ ! -z "$gateway_addr" ]; then
            export L2_GATEWAY_ADDRESS="$gateway_addr"
            deploy_forwarder
        fi
        ;;
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Important next steps:${NC}"
echo "1. Verify contracts manually at: https://explorer.cronos.org/testnet"
echo "   (Cronos Testnet is not supported by Sourcify auto-verification)"
echo "2. Update the AZTEC_GATEWAY_7683 address in .env if not already set"
echo "3. Call setAztecGateway7683() on both contracts with the Aztec gateway address"
echo "4. Call setForwarder() on L2Gateway7683 with the Forwarder address"
echo ""
