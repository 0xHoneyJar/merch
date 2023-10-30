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
        drip.mint{value: 0.1 ether}(1, 1);
        assertEq(drip.balanceOf(address(this), 1), 1);

        drip.mint{value: 0.05 ether}(2, 1);
        assertEq(drip.balanceOf(address(this), 2), 1);
    }

    function testFailMintOutOfBounds() public {
        drip.mint{value: 0.1 ether}(3, 1);
    }

    function testFailMintInsufficientFunds() public {
        drip.mint{value: 0.05 ether}(1, 1);
    }
}
