// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./Admin.sol";
import "./Product.sol";
import "./User.sol";
import "./library/ItemLib.sol";

contract EcoClean is User, Admin, Product {
    using ItemLib for string;
    uint8 constant decimal = 8;

    struct Products {
        uint256 productId;
        string name;
        address productOwner;
        bytes data;
        // ProductLib.ProductType productType;
        uint256 amount;
    }

    struct recycledItems{
        uint256 itemId;
        uint256 weight;
        ItemLib.ItemType itemType;
    }

    //if user is paid 
    mapping (address => bool) isPaid;

    //if user have recived payment or the item
    mapping(uint256 => mapping(uint256 => bool)) hasReceivedPayment;

    //userid, id of the product, the item
    mapping (uint256 => mapping (uint256 => recycledItems)) itemByUserId;
    mapping (uint256 => bool) hasRecycled;
    mapping(uint256 => uint256) public itemCountByUser;

    error AlreadyPaid();

    event ItemRecycled(address indexed user, uint256 itemId, string itemType, uint256 weight);
    event PaidForRecycledItem(address indexed user, uint256 indexed userId, uint256 itemId, ItemLib.ItemType itemType);

    function recycleItem(string memory _type, uint256 _weight) public { 
        if(!_isRegistered(msg.sender)){
             _registerUser(msg.sender);
        }
        require(_weight > 0, "Invalid weight");

        uint256 id = userId[msg.sender];

        itemCountByUser[id]++;

       itemByUserId[id][itemCountByUser[id]] = recycledItems({
            itemId: itemCountByUser[id],
            weight: _weight,
            itemType: _type.toItemType()
        });

        hasRecycled[id] = true;
        emit ItemRecycled(msg.sender, itemCountByUser[id], _type, _weight);
    }

    function payUser(uint256 _id, uint256 _rid, uint256 _rate) public payable {
        makePayment();
        address user = userAccountId[_id].userAddress;
        !_isRegistered(_id);
        if(hasReceivedPayment[_id][_rid] == true){
            revert AlreadyPaid();
        }

        uint256 itemWeight = itemByUserId[_id][_rid].weight;
        ItemLib.ItemType _rType= itemByUserId[_id][_rid].itemType;
        uint256 amount = ItemLib.toItemWeight(itemWeight, rate, _rType);

        emit PaidForRecycledItem(user, _id, _rid, _rType);
        payable(user).transfer(amount * decimal);
        hasReceivedPayment[_id][_rid] = true;
        
    }
    
}