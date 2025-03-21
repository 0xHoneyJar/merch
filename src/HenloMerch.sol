// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { ERC721Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { SafeTransferLib as STL } from "solady/utils/SafeTransferLib.sol";

contract HenloMerch is ERC721Upgradeable, OwnableUpgradeable, UUPSUpgradeable {
    /*###############################################################
                            ERRORS
    ###############################################################*/
    error InvalidID();
    error MintNotOpen();
    error InsufficientFunds();
    error ExceedsMaxSupply();
    error TokenNotFound();
    /*###############################################################
                            EVENTS
    ###############################################################*/
    event ItemMinted(uint256 indexed itemId, uint256 indexed tokenId);
    event TransferedToTreasury(uint256 indexed itemId, uint256 indexed tokenId);
    /*###############################################################
                            STRUCTS
    ###############################################################*/
    struct Item {
        uint128 price;
        uint32 maxSupply;
        uint32 currentSupply;
        uint32 openingTime;
        uint32 closingTime;
    }
    /*###############################################################
                            STORAGE
    ###############################################################*/
    mapping(uint256 id => Item) public idToItem;
    address                     public operator;
    address                     public treasury;
    
    uint256     constant MAX_DISCOUNT   = 20;
    uint256     constant ID_SEPARATOR   = 100_000;
    IERC721     constant honeycombs;
    string      constant _baseTokenURI;
    /*###############################################################
                            CONSTRUCTOR
    ###############################################################*/
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }
    /*###############################################################
                            INITIALIZER
    ###############################################################*/
    function initialize(address _owner) external initializer {
        __Ownable_init(_owner);
    }
    /*###############################################################
                            PROXY MANAGEMENT
    ###############################################################*/
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
    /*###############################################################
                            MODIFIERS
    ###############################################################*/
    modifier onlyOperatorOrOwner() {
        if (msg.sender != operator && msg.sender != owner()) revert NotOperatorOrOwner();
        _;
    }
    /*###############################################################
                            OWNER FUNCTIONS
    ###############################################################*/
    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }
    function setHoneycombs(address _honeycombs) public onlyOwner {
        honeycombs = IERC721(_honeycombs);
    }
    function withdraw() public onlyOwner {
        STL.safeTransferETH(owner(), address(this).balance);
    }
    function setOperator(address _operator) public onlyOwner {
        operator = _operator;
    }
    function setTreasury(address _treasury) public onlyOwner {
        treasury = _treasury;
    }

     
    function setItems(
        uint256[] calldata ids,
        uint128[] calldata prices,
        uint32[] calldata maxSupply,
        uint32[] calldata dropTimes,
        uint32[] calldata closingTimes
    ) public onlyOperatorOrOwner {
        uint256 length = ids.length;
        for (uint256 i; i < length; i++) {
            idToItem[ids[i]] = Item({
                price: prices[i],
                maxSupply: maxSupply[i],
                currentSupply: 0,
                openingTime: dropTimes[i],
                closingTime: closingTimes[i]
            });
        }
    }
    /*###############################################################
                            VIEW FUNCTIONS
    ###############################################################*/
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }
    /*###############################################################
                            PUBLIC FUNCTIONS
    ###############################################################*/
    function mint(uint256 id, uint32 quantity) public payable {
        Item memory item = idToItem[id];
        if (item.price == 0) revert InvalidID();
        if (block.timestamp < item.openingTime || block.timestamp > item.closingTime) revert MintNotOpen();
        if (msg.value != item.price * quantity) revert InsufficientFunds();
        if (item.maxSupply > 0 && item.currentSupply + quantity > item.maxSupply) revert ExceedsMaxSupply();

        uint256 honeycombsBalance = honeycombs.balanceOf(msg.sender);
        // cap discount at 20%
        // 1 honeycomb = 1% discount
        uint256 discount = honeycombsBalance > MAX_DISCOUNT ? MAX_DISCOUNT : honeycombsBalance;
        uint256 toRefund = honeycombsBalance > 0 ? (item.price * quantity * discount) / 100 : 0;

        idToItem[id].currentSupply += quantity;
        
        // Mint each token individually
        for (uint32 i = 0; i < quantity; i++) {
            uint256 tokenId = id * ID_SEPARATOR + item.currentSupply - 1 + i;
            _safeMint(msg.sender, tokenId);
            emit ItemMinted(id, tokenId);
        }
        
        if (toRefund > 0) {
            STL.safeTransferETH(msg.sender, toRefund);
        }
    }

    function bulkTransferToTreasury(uint256[] calldata ids) public {
        for (uint256 i; i < ids.length; i++) {
            uint256 tokenId = ids[i];
            transferFrom(msg.sender, treasury, tokenId);
            emit TransferedToTreasury(ids[i], tokenId);
        }
    }
}
