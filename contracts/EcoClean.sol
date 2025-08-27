// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./Admin.sol";
import "./Product.sol";
import "./User.sol";
import "./library/ProductLib.sol";

contract EcoClean is User, Admin, Product {
    using ProductLib for string;
    uint8 constant decimal = 8;

    struct Products {
        uint256 productId;
        string name;
        bytes data;
        ProductLib.ProductType productType;
        uint256 amount;
    }

    struct userItems{
        uint256 itemId;
        uint256 weight;
        ProductLib.ProductType productType;
    }

    //if user is paid 
    mapping (address => bool) isPaid;

    //if user have recived payment or the item
    mapping(uint256 => mapping(uint256 => bool)) hasReceivedPayment;

    //userid, id of the product, the item
    mapping (uint256 => mapping (uint256 => userItems)) itemByUserId;
    mapping (uint256 => bool) hasRecycled;
    mapping(uint256 => uint256) public productCountByUser;

    error AlreadyPaid();

    event ItemRecycled(address indexed user, uint256 itemId, string productType, uint256 weight);
    event PaidForRecycledItem(address indexed user, uint256 indexed userId, uint256 itemId, ProductLib.ProductType productType);

    function recycleItem(string memory _type, uint256 _weight) public { 
        if(!_isRegistered(msg.sender)){
             _registerUser(msg.sender);
        }
        require(_weight > 0, "Invalid weight");

        uint256 id = userId[msg.sender];

        productCountByUser[id]++;

       itemByUserId[id][productCountByUser[id]] = userItems({
            itemId: productCountByUser[id],
            weight: _weight,
            productType: _type.toProductType()
        });

        hasRecycled[id] = true;
        emit ItemRecycled(msg.sender, productCountByUser[id], _type, _weight);
    }

    function payUser(uint256 _id, uint256 _pid, uint256 _rate) public payable {
        makePayment();
        address user = userAccountId[_id].userAddress;
        !_isRegistered(_id);
        if(hasReceivedPayment[_id][_pid] == true){
            revert AlreadyPaid();
        }

        uint256 itemWeight = itemByUserId[_id][_pid].weight;
        ProductLib.ProductType _pType= itemByUserId[_id][_pid].productType;
        uint256 amount = ProductLib.toProductWeight(itemWeight, rate, _pType);

        emit PaidForRecycledItem(user, _id, _pid, _pType);
        payable(user).transfer(amount * decimal);
        hasReceivedPayment[_id][_pid] = true;
        
    }
    
}