// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Drip} from "../src/Drip.sol";
import {ERC1155TokenReceiver} from "solmate/tokens/ERC1155.sol";

contract DripTest is Test, ERC1155TokenReceiver {
    Drip public drip;

    function setUp() public {
        drip = new Drip();
    }

    function testMint() public {
        vm.warp(1672444800 + 2 days);

        drip.mint{value: 0.08 ether}(73, 1);
        assertEq(drip.balanceOf(address(this), 73), 1);

        drip.mint{value: 0.09 ether}(76, 1);
        assertEq(drip.balanceOf(address(this), 76), 1);
    }

    function testFailMintOutOfBoundsAbove() public {
        vm.warp(1672444800 + 2 days);
        drip.mint{value: 0.1 ether}(100, 1);
    }

    function testFailMintOutOfBoundsBelow() public {
        vm.warp(1672444800 + 2 days);
        drip.mint{value: 0.1 ether}(1, 1);
    }

    function testFailMintInsufficientFunds() public {
        vm.warp(1672444800 + 2 days);
        drip.mint{value: 0.08 ether}(76, 1);
    }

    function testFailOverpay() public {
        vm.warp(1672444800 + 2 days);
        drip.mint{value: 10 ether}(73, 2);
    }

    function testFailExceedsSupply() public {
        vm.warp(1672444800 + 2 days);
        drip.mint{value: 1.92 ether}(73, 24);
    }
}
