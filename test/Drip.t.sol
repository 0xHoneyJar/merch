// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {Drip} from "../src/Drip.sol";
import {ERC1155TokenReceiver} from "solmate/tokens/ERC1155.sol";
import {Solarray} from "solarray/Solarray.sol";

contract DripTest is Test, ERC1155TokenReceiver {
    Drip public drip;

    uint256 currentTime = 1672444800;

    function setUp() public {
        drip = new Drip();
        
        vm.warp(currentTime + 2 days);
        uint256 dropTime = currentTime;

        uint256[] memory ids = Solarray.uint256s(73, 76);

        uint256[] memory prices = Solarray.uint256s(0.08 ether, 0.09 ether);

        uint256[] memory maxSupplies = Solarray.uint256s(23, 1);

        // Set the items
        drip.setItems(dropTime, ids, prices, maxSupplies);
    }

    function testMint() public {
        vm.warp(currentTime + 2 days);

        drip.mint{value: 0.08 ether}(73, 1);
        assertEq(drip.balanceOf(address(this), 73), 1);

        drip.mint{value: 0.09 ether}(76, 1);
        assertEq(drip.balanceOf(address(this), 76), 1);
    }

    function testMintOutOfBoundsAboveRevert() public {
        vm.warp(currentTime + 2 days);

        vm.expectRevert(Drip.InvalidID.selector);
        drip.mint{value: 0.1 ether}(100, 1);
    }

    function testMintOutOfBoundsBelowRevert() public {
        vm.warp(currentTime + 2 days);

        vm.expectRevert(Drip.InvalidID.selector);
        drip.mint{value: 0.1 ether}(1, 1);
    }

    function testMintInsufficientFundsRevert() public {
        vm.warp(currentTime + 2 days);

        vm.expectRevert(Drip.InsufficientFunds.selector);
        drip.mint{value: 0.08 ether}(76, 1);
    }

    function testOverpayRevert() public {
        vm.warp(currentTime + 2 days);

        vm.expectRevert(Drip.InsufficientFunds.selector);
        drip.mint{value: 10 ether}(73, 2);
    }

    function testExceedsSupplyRevert() public {
        vm.warp(currentTime + 2 days);

        vm.expectRevert(Drip.ExceedsMaxSupply.selector);
        drip.mint{value: 1.92 ether}(73, 24);
    }

    function testWithdrawFunds() public {
        vm.warp(currentTime + 2 days);

        drip.mint{value: 0.08 ether}(73, 1);
        assertEq(drip.balanceOf(address(this), 73), 1);

        drip.mint{value: 0.09 ether}(76, 1);
        assertEq(drip.balanceOf(address(this), 76), 1);

        uint256 balance = address(this).balance;
        drip.withdraw();
        assertEq(address(this).balance, balance + 0.17 ether);
    }

    function testAttackerCannotWithdrawFunds() public {
        vm.warp(currentTime + 2 days);

        drip.mint{value: 0.08 ether}(73, 1);
        drip.mint{value: 0.09 ether}(76, 1);

        vm.prank(address(0xfeef));
        vm.expectRevert();
        drip.withdraw();
    }

    receive() external payable {}
}
