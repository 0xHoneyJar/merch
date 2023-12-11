// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { ERC1155 } from "solmate/tokens/ERC1155.sol";
import { Ownable } from "solady/src/auth/Ownable.sol";
import { LibString } from "solady/src/utils/LibString.sol";
import { SafeTransferLib } from "solady/src/utils/SafeTransferLib.sol";

contract Drip is ERC1155, Ownable {
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

    uint256 constant spacing = 1 days;

    string constant public baseURI = "https://honey-interface-git-claim-0xhoneyjar-s-team.vercel.app/api/metadata_merch/";

    constructor() ERC1155() {
        _initializeOwner(msg.sender);
    }

    function uri(uint256 id) public pure override returns (string memory) {
        return LibString.concat(baseURI, LibString.toString(id));
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
        SafeTransferLib.safeTransferAllETH(msg.sender);
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
