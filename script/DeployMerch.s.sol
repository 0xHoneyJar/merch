// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {HenloMerch} from "../src/HenloMerch.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DeployMerch is Script {
    // Constants for deployment
    address constant HONEYCOMBS = 0x886D2176D899796cD1AfFA07Eff07B9b2B80f1be;
    uint32 constant START_TIME = 1742948407;
    uint32 constant DURATION = 2 weeks;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy implementation
        HenloMerch implementation = new HenloMerch();

        // Deploy proxy with deployer address
        bytes memory initData = abi.encodeWithSelector(
            HenloMerch.initialize.selector,
            deployer // Using deployer address instead of msg.sender
        );

        ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), initData);

        // Get the proxy as HenloMerch
        HenloMerch merch = HenloMerch(address(proxy));

        // Set Honeycombs contract
        merch.setHoneycombs(HONEYCOMBS);

        // Set up products
        setupProducts(merch);

        vm.stopBroadcast();

        console.log("Deployment successful!");
        console.log("Implementation:", address(implementation));
        console.log("Proxy:", address(proxy));
    }

    function setupProducts(HenloMerch merch) internal {
        // Arrays for bulk product setup
        uint256[] memory ids = new uint256[](10);
        uint128[] memory prices = new uint128[](10);
        uint32[] memory maxSupply = new uint32[](10);
        uint32[] memory dropTimes = new uint32[](10);
        uint32[] memory closingTimes = new uint32[](10);

        // White Shirt - ID: 1
        ids[0] = 1;
        prices[0] = 1 ether;
        maxSupply[0] = 1000;

        // White Hiking Hat - ID: 2
        ids[1] = 2;
        prices[1] = 1 ether;
        maxSupply[1] = 500;

        // Maroon Bucket Hat - ID: 3
        ids[2] = 3;
        prices[2] = 1 ether;
        maxSupply[2] = 500;

        // Henlo Hoodie - ID: 4
        ids[3] = 4;
        prices[3] = 1 ether;
        maxSupply[3] = 750;

        // Grey Shirt - ID: 5
        ids[4] = 5;
        prices[4] = 1 ether;
        maxSupply[4] = 1000;

        // Grey Hiking Hat - ID: 6
        ids[5] = 6;
        prices[5] = 1 ether;
        maxSupply[5] = 500;

        // Grey Bucket Hat - ID: 7
        ids[6] = 7;
        prices[6] = 1 ether;
        maxSupply[6] = 500;

        // Black Shirt - ID: 8
        ids[7] = 8;
        prices[7] = 1 ether;
        maxSupply[7] = 1000;

        // Black Hiking Hat - ID: 9
        ids[8] = 9;
        prices[8] = 1 ether;
        maxSupply[8] = 500;

        // Black Bucket Hat - ID: 10
        ids[9] = 10;
        prices[9] = 1 ether;
        maxSupply[9] = 500;

        // Set same start and end time for all products
        for (uint256 i = 0; i < 10; i++) {
            dropTimes[i] = START_TIME;
            closingTimes[i] = START_TIME + DURATION;
        }

        // Set all products in one transaction
        merch.setItems(ids, prices, maxSupply, dropTimes, closingTimes);
    }
}
