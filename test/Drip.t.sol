// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {Drip} from "../src/Drip.sol";
import {ERC1155TokenReceiver} from "solmate/tokens/ERC1155.sol";
import {ERC721} from "solmate/tokens/ERC721.sol";
import {Solarray} from "solarray/Solarray.sol";
import {StdUtils} from "forge-std/StdUtils.sol";

contract HoneyCombs is ERC721 {
    uint256 counter;
    constructor() ERC721("honeycombs", "hc") {}
    function tokenURI(uint256) public pure override returns (string memory) {
        return "";
    }
    function mint(address to, uint256 amount) public {
        for (uint256 i = 0; i < amount; i++) {
            _mint(to, counter++);
        }
    }
}

contract DripTest is Test, ERC1155TokenReceiver {
    Drip public drip;

    uint256 currentTime = 1672444800;
    HoneyCombs honeycombs;

    function setUp() public {
        // etch honeycomb contract on mainnet address
        honeycombs = new HoneyCombs();
        vm.etch(address(0xCB0477d1Af5b8b05795D89D59F4667b59eAE9244), address(honeycombs).code);

        drip = new Drip();
        
        vm.warp(currentTime + 2 days);
        uint256 dropTime = currentTime;

        uint256[] memory ids = Solarray.uint256s(73, 76);
        uint256[] memory prices = Solarray.uint256s(0.08 ether, 0.09 ether);
        uint256[] memory maxSupplies = Solarray.uint256s(23, 1);
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

    // function testDiscount(uint256 combsToUse, uint256 amountToBuy) public {
    //     uint256 combsToUse = StdUtils.bound(combsToUse, 0, 20);
    //     uint256 amountToBuy = StdUtils.bound(amountToBuy, 0, 25);

    //     // mint hcs for discount
    //     honeycombs.mint(address(this), combsToUse);
    //     uint256 balanceBefore = address(this).balance;
    //     // mint drip
    //     drip.mint{value: 0.08 ether * amountToBuy}(73, uint32(amountToBuy));
    //     // balance should have diminished by (0.08 * amount) / (100 - combsToUse)
    //     assertEq(address(this).balance, balanceBefore - ((0.08 ether * amountToBuy) / (100 - combsToUse)));
    // }

    receive() external payable {}
}
