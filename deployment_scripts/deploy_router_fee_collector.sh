#!/bin/bash

# Deploy RouterFeeCollector Contract
# Usage: ./deploy_router_fee_collector.sh [rpc_url] [fee_token_address] [explorer_url]
# Example: ./deploy_router_fee_collector.sh (uses defaults)
# Example: ./deploy_router_fee_collector.sh https://sepolia.infura.io/v3/YOUR_API_KEY 0x1234567890123456789012345678901234567890 https://sepolia.etherscan.io

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Set default values
DEFAULT_RPC_URL="https://rpc.testnet.pruv.network"
DEFAULT_FEE_TOKEN_ADDRESS="0xeCacC484026a02022565496E088CA0581cC36373"
DEFAULT_EXPLORER_URL="https://explorer.testnet.pruv.network"

# Parse arguments with defaults
RPC_URL=${1:-$DEFAULT_RPC_URL}
FEE_TOKEN_ADDRESS=${2:-$DEFAULT_FEE_TOKEN_ADDRESS}
EXPLORER_URL=${3:-$DEFAULT_EXPLORER_URL}

print_info "Usage: export PRIVATE_KEY=your_private_key_here && $0 [rpc_url] [fee_token_address] [blockscout_explorer_url]"
print_info "Example: export PRIVATE_KEY=your_private_key_here && $0 https://rpc.blockchain.network 0x1234567890123456789012345678901234567890 https://explorer.blockchain.network"
print_info "Defaults: RPC URL = $DEFAULT_RPC_URL, Fee Token Address = $DEFAULT_FEE_TOKEN_ADDRESS, Explorer URL = $DEFAULT_EXPLORER_URL"

# Validate fee token address format (basic check)
if [[ ! $FEE_TOKEN_ADDRESS =~ ^0x[a-fA-F0-9]{40}$ ]]; then
    print_error "Invalid fee token address format: $FEE_TOKEN_ADDRESS"
    print_info "Address should be in format: 0x followed by 40 hexadecimal characters"
    exit 1
fi

# Check if PRIVATE_KEY is set
if [ -z "$PRIVATE_KEY" ]; then
    print_error "PRIVATE_KEY environment variable is not set."
    print_info "Please set your private key: export PRIVATE_KEY=your_private_key_here"
    exit 1
fi

print_info "Starting deployment of RouterFeeCollector..."
print_info "RPC URL: $RPC_URL"
print_info "Fee Token Address: $FEE_TOKEN_ADDRESS"
print_info "Explorer URL: $EXPLORER_URL"

# Set the FEE_TOKEN_ADDRESS environment variable for the forge script
export FEE_TOKEN_ADDRESS=$FEE_TOKEN_ADDRESS

# Run the deployment script
print_info "Executing forge script..."

# Change to solidity directory to run forge commands
cd solidity

DEPLOY_OUTPUT=$(forge script script/DeployRouterFeeCollector.s.sol:DeployRouterFeeCollector \
    --rpc-url "$RPC_URL" \
    --broadcast \
    --legacy \
    -vvvv 2>&1)

DEPLOY_EXIT_CODE=$?

echo "$DEPLOY_OUTPUT"

if [ $DEPLOY_EXIT_CODE -eq 0 ]; then
    print_success "RouterFeeCollector deployed successfully!"
    
    # Extract contract address from output
    CONTRACT_ADDRESS=$(echo "$DEPLOY_OUTPUT" | grep "deployed at:" | grep -o '0x[a-fA-F0-9]\{40\}' | head -1)
    
    if [ -n "$CONTRACT_ADDRESS" ]; then
        print_success "Contract deployed at: $CONTRACT_ADDRESS"
        
        # Verify the contract
        print_info "Verifying contract on explorer..."
        
        VERIFY_OUTPUT=$(forge verify-contract \
             $CONTRACT_ADDRESS \
             contracts/token/extensions/token_with_fee/RouterFeeCollector.sol:RouterFeeCollector \
             --rpc-url "$RPC_URL" \
             --verifier blockscout \
             --verifier-url "$EXPLORER_URL/api" 2>&1)
        
        VERIFY_EXIT_CODE=$?
        
        echo "$VERIFY_OUTPUT"
        
        if [ $VERIFY_EXIT_CODE -eq 0 ]; then
            print_success "Contract verification successful!"
        else
            print_warning "Contract verification failed or pending"
            print_info "You can manually verify at: $EXPLORER_URL/address/$CONTRACT_ADDRESS"
        fi
        
        print_info "Contract Address: $CONTRACT_ADDRESS"
        print_info "Explorer: $EXPLORER_URL/address/$CONTRACT_ADDRESS"
    else
        print_warning "Could not extract contract address from output"
        print_info "Please check the broadcast files in solidity/broadcast/ directory"
    fi
else
    print_error "Deployment failed. Check the error messages above."
    exit 1
fi

print_info "Deployment completed"