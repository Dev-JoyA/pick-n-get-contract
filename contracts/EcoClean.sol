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
        uint256 pId;
        string name;
        address owner;
        bytes data;
        uint256 amount;
    }

    struct recycledItems{
        uint256 itemId;
        uint256 weight;
        ItemLib.ItemType itemType;
    }

    mapping (address => bool) public isProducersPaid;
    mapping(uint256 => mapping(uint256 => bool)) public hasReceivedPayment;

    mapping (uint256 => mapping (uint256 => recycledItems)) public itemByUserId;
    mapping (uint256 => bool) public hasRecycled;
    mapping (uint256 => uint256) public itemCountByUser;

   
    mapping (uint256 => mapping(uint256 => Products)) public  allProductsByProducer;
    mapping (uint256 => Product) public productsId;
    mapping (uint256 => uint256) public productCountByUser;
    mapping (uint256 => uint256[]) public allProductIdsByProducer;

    error AlreadyPaid();

    event ItemRecycled(address indexed user, uint256 itemId, string itemType, uint256 weight);
    event PaidForRecycledItem(address indexed user, uint256 indexed userId, uint256 itemId, ItemLib.ItemType itemType);

    function registerUser() public {
        _registerUser(msg.sender);
    }

    function registerProducer(address _producer, string memory  _name, string memory _country, uint256 _number) public {
        registerProductOwner(_producer, _name, _country, _number);    
    }
    

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

    function payUser(uint256 _id, uint256 _rid) public payable {
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
        payable(user).transfer(amount * (10 ** decimal));
        hasReceivedPayment[_id][_rid] = true;   
    }

    // PRODUCT ENDPOINT OR FUNCTIONS 

    function addProoduct(uint256 _id, string memory _name, bytes memory _data, uint256 _amount) public {
        if(isProducerRegistered[_id] == false){
            revert NotAuthorised();
        }
        address _owner = productOwner[_id];

        productCount++;

        productCountByUser[_id]++;
        
        allProductsByProducer[_id][productCountByUser[_id]] = Products({
            pId : productCountByUser[_id],
            name : _name,
            owner : _owner,
            data : _data,
            amount : _amount
        });
        productIds.push(productCountByUser[_id]);
        allProductIdsByProducer[_id] = productIds;   
    }

    function shopProduct() public {

    }

    function payProducer() public {

    }

    



    //  function addProduct(uint256 _id) internal {
    //     require(_id > 0, "Invalid ID");
    //     require(!isRegistered[_id], "Product already registered");

    //     productIds.push(_id);
    //     isRegistered[_id] = true;
    //     productOwner[_id] = msg.sender;
    //     productCount++;

    //     emit ProductAdded(_id, msg.sender);
    // }
    
}