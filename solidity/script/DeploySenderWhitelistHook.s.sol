// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {SenderWhitelistHook} from "../contracts/hooks/SenderWhitelistHook.sol";

contract DeploySenderWhitelistHook is Script {
    function run() external {
        // Get the deployer's private key from environment variable
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);
        
        // Get the deployer address to use as the initial owner
        address deployer = vm.addr(deployerPrivateKey);
        console.log("Deploying SenderWhitelistHook with owner:", deployer);
        
        // Deploy the SenderWhitelistHook contract
        SenderWhitelistHook hook = new SenderWhitelistHook(deployer);
        
        console.log("SenderWhitelistHook deployed at:", address(hook));
        console.log("Owner:", hook.owner());
        console.log("Hook type:", hook.hookType());
        
        vm.stopBroadcast();
        
        // Log deployment information
        console.log("=== Deployment Summary ===");
        console.log("Contract: SenderWhitelistHook");
        console.log("Address:", address(hook));
        console.log("Owner:", hook.owner());
        console.log("Network: Pruv Testnet");
        console.log("Deployer:", deployer);
    }
}