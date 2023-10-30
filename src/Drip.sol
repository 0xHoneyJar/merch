// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC1155} from "solmate/tokens/ERC1155.sol";

contract Drip is ERC1155 {
    mapping(uint256 => uint256) public idToPrice;

    constructor() ERC1155() {
        idToPrice[1] = 0.1 ether;
        idToPrice[2] = 0.05 ether;
    }

    function uri(uint256 id) public view override returns (string memory) {
        return string(abi.encodePacked(baseURI, tokenId.toString()));
    }

    function mint(uint256 id, uint256 quantity) public payable {
        require(idToPrice[id] > 0, "Invalid ID");
        require(id < 2, "Invalid ID");
        require(msg.value == idToPrice[id] * quantity, "Incorrect Ether value");

        _mint(msg.sender, id, quantity, "");
    }
}
