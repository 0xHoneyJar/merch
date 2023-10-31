// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC1155} from "solmate/tokens/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Drip is ERC1155 {
    using Strings for uint256;

    mapping(uint256 => uint256) public idToPrice;
    mapping(uint256 => uint256) public idToMaxSupply;
    mapping(uint256 => uint256) public idToCurrentSupply;
    mapping(uint256 => uint256) public idToOpeningTime;

    string public baseURI = "https://www.0xhoneyjar.xyz/merch/";

    constructor() ERC1155() {
        // Hoodies 0.2

        // Beanies 0.08

        // Hats 0.09

        // Shirts 0.1
        idToPrice[10] = 0.1 ether; // T-Shirt S
        idToPrice[11] = 0.1 ether; // T-Shirt M
        idToPrice[12] = 0.1 ether; // T-Shirt L
        idToPrice[13] = 0.1 ether; // T-Shirt XL

        idToMaxSupply[10] = 100;
        idToMaxSupply[11] = 100;
        idToMaxSupply[12] = 100;
        idToMaxSupply[13] = 100;

        // Set opening times using Unix timestamp
        idToOpeningTime[1] = 1672444800; // January 1, 2023
        idToOpeningTime[2] = 1672531200; // January 2, 2023
    }

    function uri(uint256 id) public view override returns (string memory) {
        return string(abi.encodePacked(baseURI, id.toString()));
    }

    function mint(uint256 id, uint256 quantity) public payable {
        require(idToPrice[id] > 0, "Invalid ID");
        require(id <= 13, "Invalid ID");
        require(block.timestamp >= idToOpeningTime[id], "Not yet open for minting");
        require(quantity > 0, "Invalid quantity");
        require(msg.value == idToPrice[id] * quantity, "Incorrect Ether value");
        require(idToCurrentSupply[id] + quantity <= idToMaxSupply[id], "Exceeds max supply");

        idToCurrentSupply[id] += quantity;
        _mint(msg.sender, id, quantity, "");
    }
}
