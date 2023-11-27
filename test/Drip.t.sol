// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
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

    function testMintOutOfBoundsAboveRevert() public {
        vm.warp(1672444800 + 2 days);

        vm.expectRevert(Drip.InvalidID.selector);
        drip.mint{value: 0.1 ether}(100, 1);
    }

    function testMintOutOfBoundsBelowRevert() public {
        vm.warp(1672444800 + 2 days);

        vm.expectRevert(Drip.InvalidID.selector);
        drip.mint{value: 0.1 ether}(1, 1);
    }

    function testMintInsufficientFundsRevert() public {
        vm.warp(1672444800 + 2 days);

        vm.expectRevert(Drip.InsufficientFunds.selector);
        drip.mint{value: 0.08 ether}(76, 1);
    }

    function testOverpayRevert() public {
        vm.warp(1672444800 + 2 days);

        vm.expectRevert(Drip.InsufficientFunds.selector);
        drip.mint{value: 10 ether}(73, 2);
    }

    function testExceedsSupplyRevert() public {
        vm.warp(1672444800 + 2 days);

        vm.expectRevert(Drip.ExceedsMaxSupply.selector);
        drip.mint{value: 1.92 ether}(73, 24);
    }
}
