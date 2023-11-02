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

    uint256 spacing = 1 days;

    string public baseURI = "https://www.0xhoneyjar.xyz/merch/";

    constructor() ERC1155() {
        // Bucket hats 0.08
        idToPrice[73] = 0.08 ether;
        idToPrice[74] = 0.08 ether;
        idToPrice[75] = 0.08 ether;

        idToMaxSupply[73] = 23;
        idToMaxSupply[74] = 23;
        idToMaxSupply[75] = 23;

        // Fishing hats 0.09
        idToPrice[76] = 0.09 ether;
        idToPrice[77] = 0.09 ether;
        idToPrice[78] = 0.09 ether;

        idToMaxSupply[76] = 23;
        idToMaxSupply[77] = 23;
        idToMaxSupply[78] = 23;

        // Shirts 0.1
        idToPrice[79] = 0.1 ether;
        idToPrice[80] = 0.1 ether;
        idToPrice[81] = 0.1 ether;
        idToPrice[82] = 0.1 ether;
        idToPrice[83] = 0.1 ether;
        idToPrice[84] = 0.1 ether;
        idToPrice[85] = 0.1 ether;
        idToPrice[86] = 0.1 ether;
        idToPrice[87] = 0.1 ether;
        idToPrice[88] = 0.1 ether;
        idToPrice[89] = 0.1 ether;
        idToPrice[90] = 0.1 ether;

        idToMaxSupply[79] = 35;
        idToMaxSupply[80] = 35;
        idToMaxSupply[81] = 35;
        idToMaxSupply[82] = 35;
        idToMaxSupply[83] = 35;
        idToMaxSupply[84] = 35;
        idToMaxSupply[85] = 35;
        idToMaxSupply[86] = 35;
        idToMaxSupply[87] = 35;
        idToMaxSupply[88] = 35;
        idToMaxSupply[89] = 35;
        idToMaxSupply[90] = 35;

        // Hoodies 0.2
        idToPrice[91] = 0.2 ether;
        idToPrice[92] = 0.2 ether;
        idToPrice[93] = 0.2 ether;
        idToPrice[94] = 0.2 ether;

        idToMaxSupply[91] = 17;
        idToMaxSupply[92] = 17;
        idToMaxSupply[93] = 18;
        idToMaxSupply[94] = 17;

        uint256 initialDropTime = 1672444800; // Example: January 1, 2023

        // Bucket hats 0.08
        idToOpeningTime[73] = initialDropTime;
        idToOpeningTime[74] = initialDropTime;
        idToOpeningTime[75] = initialDropTime;

        // Fishing hats 0.09 (after Bucket hats)
        initialDropTime += spacing;
        idToOpeningTime[76] = initialDropTime;
        idToOpeningTime[77] = initialDropTime;
        idToOpeningTime[78] = initialDropTime;

        // Shirts 0.1 (after Fishing hats)
        initialDropTime += spacing;
        idToOpeningTime[79] = initialDropTime;
        idToOpeningTime[80] = initialDropTime;
        idToOpeningTime[81] = initialDropTime;
        idToOpeningTime[82] = initialDropTime;
        idToOpeningTime[83] = initialDropTime;
        idToOpeningTime[84] = initialDropTime;
        idToOpeningTime[85] = initialDropTime;
        idToOpeningTime[86] = initialDropTime;
        idToOpeningTime[87] = initialDropTime;
        idToOpeningTime[88] = initialDropTime;
        idToOpeningTime[89] = initialDropTime;
        idToOpeningTime[90] = initialDropTime;

        // Hoodies 0.2 (after Shirts)
        initialDropTime += spacing;
        idToOpeningTime[91] = initialDropTime;
        idToOpeningTime[92] = initialDropTime;
        idToOpeningTime[93] = initialDropTime;
        idToOpeningTime[94] = initialDropTime;
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
