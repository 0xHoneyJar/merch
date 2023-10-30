// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC1155} from "solmate/tokens/ERC1155.sol";

contract Counter is ERC1155 {
    constructor() ERC1155() {}

    function uri(uint256 id) public view override returns (string memory) {
        return "";
    }
}
