// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC1155} from "solmate/tokens/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Drip is ERC1155, Ownable {
    using Strings for uint256;

    error InvalidID();
    error MintNotOpen();
    error InsufficientFunds();
    error ExceedsMaxSupply();

    struct Item {
        uint128 price;
        uint32 maxSupply;
        uint32 currentSupply;
        uint64 openingTime;
    }

    mapping(uint256 => Item) public idToItem;

    uint256 spacing = 1 days;

    string public baseURI = "https://honey-interface-git-claim-0xhoneyjar-s-team.vercel.app/api/metadata_merch/";

    constructor() ERC1155() Ownable(msg.sender) {}

    function uri(uint256 id) public view override returns (string memory) {
        return string(abi.encodePacked(baseURI, id.toString()));
    }

    function mint(uint256 id, uint32 quantity) public payable {
        Item memory item = idToItem[id];
        if (item.price == 0) revert InvalidID();
        if (block.timestamp < item.openingTime) revert MintNotOpen();
        if (msg.value != item.price * quantity) revert InsufficientFunds();
        if (item.currentSupply + quantity > item.maxSupply) revert ExceedsMaxSupply();

        idToItem[id].currentSupply += quantity;
        _mint(msg.sender, id, uint256(quantity), "");
    }

    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function setItems(
        uint256 dropTime,
        uint256[] calldata ids,
        uint256[] calldata prices,
        uint256[] calldata maxSupply
    ) public onlyOwner {
        uint256 length = ids.length;
        for (uint256 i; i < length; i++) {
            idToItem[ids[i]] = Item({
                price: uint128(prices[i]),
                maxSupply: uint32(maxSupply[i]),
                currentSupply: 0,
                openingTime: uint64(dropTime)
            });
        }
    }
}
