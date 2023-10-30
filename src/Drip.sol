// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC1155} from "solmate/tokens/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Drip is ERC1155 {
    using Strings for uint256;

    mapping(uint256 => uint256) public idToPrice;
    mapping(uint256 => uint256) public idToMaxSupply;
    mapping(uint256 => uint256) public idToCurrentSupply;

    string public baseURI = "https://drip.solmate.io/";

    constructor() ERC1155() {
        idToPrice[1] = 0.1 ether; // T-Shirt
        idToPrice[2] = 0.05 ether; // Jacket

        idToMaxSupply[1] = 1;
        idToMaxSupply[2] = 2;
    }

    function uri(uint256 id) public view override returns (string memory) {
        return string(abi.encodePacked(baseURI, id.toString()));
    }

    function mint(uint256 id, uint256 quantity) public payable {
        require(idToPrice[id] > 0, "Invalid ID");
        require(id <= 2, "Invalid ID");
        require(msg.value == idToPrice[id] * quantity, "Incorrect Ether value");
        require(idToCurrentSupply[id] + quantity <= idToMaxSupply[id], "Exceeds max supply");

        idToCurrentSupply[id] += quantity;
        _mint(msg.sender, id, quantity, "");
    }
}
