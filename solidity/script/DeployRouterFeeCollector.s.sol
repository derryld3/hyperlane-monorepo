// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {RouterFeeCollector} from "../contracts/token/extensions/token_with_fee/RouterFeeCollector.sol";

contract DeployRouterFeeCollector is Script {
    function run() external {
        // Get the deployer's private key from environment variable
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // Get fee token address from environment variable
        address feeTokenAddress = vm.envAddress("FEE_TOKEN_ADDRESS");
        
        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);
        
        // Get the deployer address to use as the initial owner
        address deployer = vm.addr(deployerPrivateKey);
        console.log("Deploying RouterFeeCollector with owner:", deployer);
        console.log("Fee token address:", feeTokenAddress);
        
        // Deploy the RouterFeeCollector contract
        RouterFeeCollector feeCollector = new RouterFeeCollector(
            deployer,
            feeTokenAddress
        );
        
        console.log("RouterFeeCollector deployed at:", address(feeCollector));
        console.log("Owner:", feeCollector.owner());
        console.log("Beneficiary:", feeCollector.beneficiary());
        console.log("Fee Token Address:", feeCollector.feeTokenAddress());
        
        vm.stopBroadcast();
        
        // Log deployment information
        console.log("=== Deployment Summary ===");
        console.log("Contract: RouterFeeCollector");
        console.log("Address:", address(feeCollector));
        console.log("Owner:", feeCollector.owner());
        console.log("Beneficiary:", feeCollector.beneficiary());
        console.log("Fee Token:", feeCollector.feeTokenAddress());
        console.log("Deployer:", deployer);
    }
}