// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./Admin.sol";
import "./Product.sol";
import "./User.sol";
import "./library/ItemLib.sol";

contract EcoClean is User, Admin, Product {
    using ItemLib for string;
    uint8 constant DECIMALS = 8;

    enum ProductStatus {Available, NotAvailable}

    struct Products {
        uint256 productId;
        string name;
        uint256 quantity;
        address owner;
        bytes data;
        uint256 amount;
        ProductStatus productStatus;
    }

    struct RecycledItems{
        uint256 itemId;
        uint256 weight;
        ItemLib.ItemType itemType;
    }

    mapping (address => mapping(uint256 => bool)) public isProducerPaidForProduct;
    mapping (uint256 => mapping(uint256 => bool)) public hasUserReceivedPayment;

    mapping (uint256 => mapping (uint256 => RecycledItems)) public itemByUserId;
    mapping (uint256 => bool) public hasRecycled;
    mapping (uint256 => uint256) public recycledItemId;

   
    mapping (uint256 => mapping(uint256 => Products)) public  allProductsByProducer;
    //used for looking up a producer by his id;
    mapping (uint256 => uint256) public productIdByOwner;
    //producer id to number of product they have used for giving givingg id to a specific producer
    mapping (uint256 => uint256) public productCountByOwner;
    mapping (uint256 => bool) public validPid;
    mapping (uint256 => uint256[]) public productsByProducerId;

    error AlreadyPaid();
    error ProductSoldOut();
    error InsufficientPayment();
    error InsufficientStock();

    event ItemRecycled(address indexed user, uint256 itemId, string itemType, uint256 weight);
    event PaidForRecycledItem(address indexed user, uint256 indexed userId, uint256 itemId, ItemLib.ItemType itemType);

    function registerUser() public {
        _registerUser(msg.sender);
    }

    function registerAdmin(address _admin) public {
        _registerAdmin(_admin);
    }

    function registerProducer(string memory  _name, string memory _country, uint256 _number) public {
        registerProductOwner(msg.sender, _name, _country, _number);    
    }
    
    function recycleItem(string memory _type, uint256 _weight) public { 
        if(!_isRegistered(msg.sender)){
             _registerUser(msg.sender);
        }
        require(_weight > 0, "Invalid weight");

        uint256 id = userId[msg.sender];

        recycledItemId[id]++;

       itemByUserId[id][recycledItemId[id]] = RecycledItems({
            itemId: recycledItemId[id],
            weight: _weight,
            itemType: _type.toItemType()
        });

        hasRecycled[id] = true;
        hasUserReceivedPayment[id][recycledItemId[id]] = false;
        emit ItemRecycled(msg.sender, recycledItemId[id], _type, _weight);
    }

    function payUser(uint256 _id, uint256 _rid) public payable {
        onlyAdmin();
        address user = userAccountId[_id].userAddress;
        !_isRegistered(_id);
        if(hasUserReceivedPayment[_id][_rid] == true){
            revert AlreadyPaid();
        }

        uint256 itemWeight = itemByUserId[_id][_rid].weight;
        ItemLib.ItemType _rType= itemByUserId[_id][_rid].itemType;
        uint256 amount = ItemLib.toItemWeight(itemWeight, rate, _rType);

        emit PaidForRecycledItem(user, _id, _rid, _rType);
        // payable(user).transfer(amount * (10 ** DECIMALS));
        (bool success, ) = payable(user).call{value: amount * (10 ** DECIMALS)}("");
        require(success, "Transfer failed");

        hasUserReceivedPayment[_id][_rid] = true;   
    }

    function deleteUserAccount(address _user) public {
        _deleteUser(_user);
    }

    function deleteAdmin(address _admin) public {
        _deleteAdmin(_admin);
    }

    function deleteAdminById(uint256 _adminId) public {
        _deleteAdminById(_adminId);
    }

    function setRate(uint256 _rate) public {
        _setRate(_rate);
    }

    // PRODUCT ENDPOINT OR FUNCTIONS 

    function addProduct(uint256 _id, string memory _name, uint256 _quantity, bytes memory _data, uint256 _amount) public {
        if(isProducerRegistered[_id] == false){
            revert NotAuthorised();
        }
        address _owner = productOwner[_id];

        productCount++;

        productCountByOwner[_id]++;
        
        allProductsByProducer[_id][productCountByOwner[_id]] = Products({
            productId : productCountByOwner[_id],
            name : _name,
            quantity : _quantity,
            owner : _owner,
            data : _data,
            amount : _amount * (10**DECIMALS),
            productStatus : ProductStatus.Available
        });

        productIds.push(productCountByOwner[_id]);
        productIdByOwner[productCountByOwner[_id]] = _id;
        productsByProducerId[_id] = productIds; 
        validPid[productCountByOwner[_id]] = true;  
    }

    function shopProduct(uint256 _pid, uint256 _quantity) public payable {
        require(_pid > 0, "Invalid product ID");
        require(validPid[_pid] == true, "No product with that id" );
        uint256 _owner = productIdByOwner[_pid];
        address _producer = productOwner[_owner];
        Products storage product = allProductsByProducer[_owner][_pid]; 

        if(product.productStatus == ProductStatus.NotAvailable){
            revert ProductSoldOut();
        }

        if (product.quantity < _quantity) {
            revert InsufficientStock();
        }

        uint256 totalCost = _quantity * product.amount ;
        require(msg.value == totalCost, "Incorrect payment");

        productCount--;
        productCountByOwner[_owner]--;
        for(uint256 i = 0; i < productIds.length; i++){
            if(productIds[i] == _pid){
                productIds[i] = productIds[productIds.length - 1];
                productIds.pop();
                break;
            }
        }

        product.quantity -= _quantity;
        if (product.quantity == 0) {
            product.productStatus = ProductStatus.NotAvailable;
        }

        uint256[] storage activeProduct = productsByProducerId[_pid];
        for(uint256 i = 0; i < activeProduct.length; i++){
            if(activeProduct[i] == _pid){
                activeProduct[i] = activeProduct[activeProduct.length - 1];
                activeProduct.pop();
                break;
            }
        }
        require(isProducerPaidForProduct[_producer][_pid] == false, "Already paid producer ");
        payable(_producer).transfer(msg.value);
        isProducerPaidForProduct[_producer][_pid] = true;
    }  

    function fundContract() external payable {
        require(msg.value > 0, "Must send some HBAR");
    }

    function contractBalance() external view returns (uint256) {
        onlyAdmin();
        return address(this).balance;
    }


    receive() external payable {}
    fallback() external payable {}
    
}