// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./Admin.sol";
import "./Product.sol";
import "./User.sol";
import "./library/ItemLib.sol";

contract PicknGet is User, Admin, Product {
    using ItemLib for string;
    uint8 constant DECIMALS = 8;
    uint256 public riderCount;

    enum ProductStatus {Available, NotAvailable}
    enum ItemStatus {Pending_Confirmation, Confirmed, Sold, Paid}
    enum PickUpStatus {Pending , InTransit, PickedUp, Delivered, Cancelled}
    enum RiderStatus {Pending, Approved, Rejected, Banned}

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
        ItemStatus itemStatus;
    }

    struct RiderDetails {
        uint256 id;
        string name;
        uint8 phoneNumber;
        string vehicleNumber;
        address walletAddress;
        string homeAddress;
        RiderStatus riderStatus;
        bytes vehicleImage;
        bytes vehicleRegistrationImage;
    }

    struct PickUpDetails {
        uint256 pickUpId;
        uint256 userId;
        uint256 itemId;
        uint256 riderId;
        string pickUpAddress;
        string riderName;
        uint8 riderPhoneNumber;
        uint8 userPhoneNumber;
        string userName;
        PickUpStatus pickUpStatus;
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
    mapping (uint256 => Products) public products;


    mapping (uint256 => RiderDetails) public riderId;
    mapping (uint256 => bool) public validRider;


    error AlreadyPaid();
    error ProductSoldOut();
    error NoRecycleItem();
    error InsufficientPayment();
    error InsufficientStock();
    error NotConfirmed();

    event ItemRecycled(address indexed user, uint256 itemId, string itemType, uint256 weight);
    event PaidForRecycledItem(address indexed user, uint256 indexed userId, uint256 itemId, ItemLib.ItemType itemType);


    function registerUser(string memory _address, uint8 _number) public {
        _registerUser( _address, _number);
    }

    function registerAdmin(address _admin) public {
        _registerAdmin(_admin);
    }

    function registerProducer(string memory  _name, string memory _country, uint256 _number) public {
        registerProductOwner(msg.sender, _name, _country, _number);    
    }

    function riderApplication(string memory _name, 
                              uint8 _number, 
                              string memory _vehicleNumber,
                              string memory _homeAddress,
                              bytes memory _image,
                              bytes memory _vehicleRegistration
                              ) public 
        {
        require(riderId[riderCount].id == 0, "Already registered");
        riderCount++;
        riderId[riderCount] = RiderDetails({
            id : riderCount,
            name : _name,
            phoneNumber : _number,
            vehicleNumber : _vehicleNumber,
            walletAddress : msg.sender,
            homeAddress : _homeAddress,
            riderStatus : RiderStatus.Pending,
            vehicleImage : _image,
            vehicleRegistrationImage : _vehicleRegistration
        }); 
    }

    function approveRider(uint256 _riderId) public {
        onlyAdmin();
        require(riderId[_riderId].id == _riderId,"Rider does not exist with that Id");
        require(riderId[_riderId].riderStatus == RiderStatus.Rejected, "Rider is Rejected, needs to re-apply");
        riderId[_riderId].riderStatus = RiderStatus.Approved;
        validRider[_riderId] = true;
    }

    function banRider(uint256 _riderId) public {
        onlyAdmin();
        require(riderId[_riderId].id == _riderId,"Rider does not exist with that Id");
        require(riderId[_riderId].riderStatus == RiderStatus.Rejected, "Rider is Rejected, needs to re-apply");
        riderId[_riderId].riderStatus = RiderStatus.Banned;
        validRider[_riderId] = false;
    }
    
    function recycleItem(string memory _type, uint256 _weight) public { 
        if(!_isRegistered(msg.sender)){
            revert UserNotRegistered();
        }
        require(_weight > 0, "Invalid weight");

        uint256 id = userId[msg.sender];

        recycledItemId[id]++;

       itemByUserId[id][recycledItemId[id]] = RecycledItems({
            itemId: recycledItemId[id],
            weight: _weight,
            itemType: _type.toItemType(),
            itemStatus : ItemStatus.Pending_Confirmation
        });

        hasRecycled[id] = true;
        hasUserReceivedPayment[id][recycledItemId[id]] = false;
        emit ItemRecycled(msg.sender, recycledItemId[id], _type, _weight);
    }

    function confirmItem(uint256 _riderId, uint256 _userId, uint256 _recycleItemId) public {
        if(!validRider[_riderId]){
            revert NotAuthorised();
        }
        if(!hasRecycled[_userId]){
            revert NoRecycleItem();
        }
        require(recycledItemId[_userId] == _recycleItemId, "Item does not belong to user");

        itemByUserId[_userId][_recycleItemId].itemStatus = ItemStatus.Confirmed;
    }

    function payUser(uint256 _userId, uint256 _recycledItemId) public payable {
        onlyAdmin();
        address user = userAccountId[_userId].userAddress;
        !_isRegistered(_userId);
        if(itemByUserId[_userId][_recycledItemId].itemStatus != ItemStatus.Confirmed){
            revert NotConfirmed();
        }
        if(hasUserReceivedPayment[_userId][_recycledItemId] == true){
            revert AlreadyPaid();
        }

        uint256 itemWeight = itemByUserId[_userId][_recycledItemId].weight;
        ItemLib.ItemType _rType= itemByUserId[_userId][_recycledItemId].itemType;
        uint256 amount = ItemLib.toItemWeight(itemWeight, rate, _rType);

        emit PaidForRecycledItem(user, _userId, _recycledItemId, _rType);
        // payable(user).transfer(amount * (10 ** DECIMALS));
        (bool success, ) = payable(user).call{value: amount * (10 ** DECIMALS)}("");
        require(success, "Transfer failed");

        hasUserReceivedPayment[_userId][_recycledItemId] = true;   
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
    
        address _owner = registrationAddress[_id];

        productOwner[_id] = _owner;

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
        products[productCountByOwner[_id]] = Products({
            productId : productCountByOwner[_id],
            name : _name,
            quantity : _quantity,
            owner : _owner,
            data : _data,
            amount : _amount * (10**DECIMALS),
            productStatus : ProductStatus.Available
        });

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

        uint256[] storage activeProduct = productsByProducerId[_owner];
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