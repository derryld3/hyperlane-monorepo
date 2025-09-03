#!/bin/bash

# SenderWhitelistHook Deployment and Verification Script
# This script deploys the SenderWhitelistHook contract and verifies it
#
# USAGE:
# 1. Set your private key as an environment variable:
#    export PRIVATE_KEY=your_private_key_here
#
# 2. Run the script from the deployment_scripts directory:
#    ./deploy_sender_whitelist_hook.sh [rpc_url] [explorer_url]
#    Example: ./deploy_sender_whitelist_hook.sh (uses defaults)
#    Example: ./deploy_sender_whitelist_hook.sh https://sepolia.infura.io/v3/YOUR_API_KEY https://sepolia.etherscan.io
#
# REQUIREMENTS:
# - Foundry installed (forge command available)
# - Private key with sufficient funds on the target network
# - Internet connection for RPC calls and verification
#
# WHAT THIS SCRIPT DOES:
# 1. Validates environment and file prerequisites
# 2. Compiles the SenderWhitelistHook contract
# 3. Deploys the contract to the specified network using legacy transactions
# 4. Automatically verifies the contract on the specified Blockscout explorer
# 5. Provides deployment summary with contract address and explorer links
#
# OUTPUT:
# - Contract address on the target network
# - Transaction hash
# - Explorer URL for viewing the verified contract
# - Instructions for interacting with the deployed contract

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Set default values
DEFAULT_RPC_URL="https://rpc.testnet.pruv.network"
DEFAULT_EXPLORER_URL="https://explorer.testnet.pruv.network"

# Parse arguments with defaults
RPC_URL=${1:-$DEFAULT_RPC_URL}
EXPLORER_URL=${2:-$DEFAULT_EXPLORER_URL}
VERIFIER_URL="$EXPLORER_URL/api"

# Configuration
CONTRACT_NAME="SenderWhitelistHook"
CONTRACT_FILE="contracts/hooks/SenderWhitelistHook.sol"
DEPLOY_SCRIPT="script/DeploySenderWhitelistHook.s.sol"


echo -e "${BLUE}=== SenderWhitelistHook Deployment Script ===${NC}"
echo -e "${BLUE}Contract: ${CONTRACT_NAME}${NC}"
echo -e "${BLUE}RPC URL: ${RPC_URL}${NC}"
echo -e "${BLUE}Explorer URL: ${EXPLORER_URL}${NC}"
echo -e "${BLUE}Usage: export PRIVATE_KEY=your_private_key_here && $0 [rpc_url] [explorer_url]${NC}"
echo -e "${BLUE}Defaults: RPC URL = $DEFAULT_RPC_URL, Explorer URL = $DEFAULT_EXPLORER_URL${NC}"
echo ""

# Check if private key is set
if [ -z "$PRIVATE_KEY" ]; then
    echo -e "${RED}Error: PRIVATE_KEY environment variable is not set${NC}"
    echo -e "${YELLOW}Please set it with: export PRIVATE_KEY=your_private_key_here${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Private key is set${NC}"

# Navigate to the solidity directory
cd solidity
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Could not navigate to solidity directory${NC}"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "foundry.toml" ]; then
    echo -e "${RED}Error: foundry.toml not found in solidity directory${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Found foundry.toml${NC}"

# Check if contract file exists
if [ ! -f "$CONTRACT_FILE" ]; then
    echo -e "${RED}Error: Contract file $CONTRACT_FILE not found${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Contract file exists${NC}"

# Check if deployment script exists
if [ ! -f "$DEPLOY_SCRIPT" ]; then
    echo -e "${RED}Error: Deployment script $DEPLOY_SCRIPT not found${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Deployment script exists${NC}"
echo ""

# Step 1: Compile the contract
echo -e "${BLUE}Step 1: Compiling contracts...${NC}"
forge build
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Compilation successful${NC}"
else
    echo -e "${RED}✗ Compilation failed${NC}"
    exit 1
fi
echo ""

# Step 2: Deploy the contract
echo -e "${BLUE}Step 2: Deploying contract...${NC}"
echo -e "${YELLOW}Using legacy transaction type (no EIP-1559)${NC}"

DEPLOY_OUTPUT=$(forge script $DEPLOY_SCRIPT \
    --private-key $PRIVATE_KEY \
    --rpc-url $RPC_URL \
    --broadcast \
    --legacy 2>&1)

DEPLOY_EXIT_CODE=$?

echo "$DEPLOY_OUTPUT"

if [ $DEPLOY_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✓ Deployment successful${NC}"
    
    # Extract contract address from output
    # Look for the specific line that contains "deployed at:"
    CONTRACT_ADDRESS=$(echo "$DEPLOY_OUTPUT" | grep "deployed at:" | grep -o '0x[a-fA-F0-9]\{40\}' | head -1)
    
    if [ -n "$CONTRACT_ADDRESS" ]; then
        echo -e "${GREEN}Contract deployed at: $CONTRACT_ADDRESS${NC}"
    else
        echo -e "${YELLOW}Warning: Could not extract contract address from output${NC}"
        echo -e "${YELLOW}Please check the broadcast files in solidity/broadcast/ directory${NC}"
    fi
else
    echo -e "${RED}✗ Deployment failed${NC}"
    exit 1
fi
echo ""

# Step 3: Verify the contract (if address was extracted)
if [ -n "$CONTRACT_ADDRESS" ]; then
    echo -e "${BLUE}Step 3: Verifying contract...${NC}"
    
    VERIFY_OUTPUT=$(forge verify-contract \
        $CONTRACT_ADDRESS \
        $CONTRACT_FILE:$CONTRACT_NAME \
        --rpc-url $RPC_URL \
        --verifier blockscout \
        --verifier-url $VERIFIER_URL 2>&1)
    
    VERIFY_EXIT_CODE=$?
    
    echo "$VERIFY_OUTPUT"
    
    if [ $VERIFY_EXIT_CODE -eq 0 ]; then
        echo -e "${GREEN}✓ Verification successful${NC}"
        
        # Extract verification URL if available
        VERIFICATION_URL=$(echo "$VERIFY_OUTPUT" | grep -o 'https://[^[:space:]]*')
        if [ -n "$VERIFICATION_URL" ]; then
            echo -e "${GREEN}Verification URL: $VERIFICATION_URL${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ Verification failed or pending${NC}"
        echo -e "${YELLOW}You can manually verify at: $EXPLORER_URL/address/$CONTRACT_ADDRESS${NC}"
    fi
else
    echo -e "${YELLOW}Step 3: Skipping verification (contract address not found)${NC}"
    echo -e "${YELLOW}Please check broadcast files and verify manually if needed${NC}"
fi

echo ""
echo -e "${BLUE}=== Deployment Summary ===${NC}"
echo -e "${GREEN}Contract: $CONTRACT_NAME${NC}"
if [ -n "$CONTRACT_ADDRESS" ]; then
    echo -e "${GREEN}Address: $CONTRACT_ADDRESS${NC}"
    echo -e "${GREEN}Explorer: $EXPLORER_URL/address/$CONTRACT_ADDRESS${NC}"
fi
echo -e "${GREEN}RPC URL: $RPC_URL${NC}"
echo -e "${GREEN}Deployment completed successfully!${NC}"