// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./Admin.sol";
import "./Product.sol";
import "./User.sol";
import "./library/ProductLib.sol";

contract EcoClean is User, Admin, Product {
    using ProductLib for string;

    enum ProductType {PAPER, PLASTIC, METALS, GLASS, OTHERS}

    struct Products {
        uint256 productId;
        string name;
        bytes data;
        ProductType productType;
        uint256 amount;
    }

    struct userItems{
        uint256 itemId;
        uint256 weight;
        ProductLib.ProductType productType;
    }
    
    // user will recycle item
    //users wil shop within the site
    //admin will pay user
    //admin will set rates of a recycled item
    //payment based on weight
    // swap stable coin for fiat - FE

    mapping (address => bool) isPaid;
    mapping (uint256 => mapping (uint256 => userItems)) itemByUserId;
    mapping (uint256 => bool) hasRecycled;
    mapping(uint256 => uint256) public productCountByUser;

    event ItemRecycled(address indexed user, uint256 itemId, string productType, uint256 weight);

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

    function payUser() public {
    }
    

    //  function recievedPayment(address _user) internal view{
    //     for(uint256 i = 0; i < users.length; i++){
    //         if(users[i] != _user){
    //             revert NotFound();
    //         }
    //     }

    //     uint256 _id = userId[_user]; 
    //     if(userAccountId[_id].userAddress != _user){
    //         revert UserNotRegistered();
    //     }  
    // }
}