// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./Admin.sol";
import "./Product.sol";
import "./User.sol";
import "./library/ItemLib.sol";

contract PicknGet is User, Admin, Product{
    using ItemLib for string;
    uint8 constant DECIMALS = 8;
    uint256 public riderCount;

    enum ItemStatus {Pending_Confirmation, Confirmed, Sold, Paid}
    enum RiderStatus {Pending, Approved, Rejected, Banned}
    enum VehicleType {Bike, Car, Truck, Van}

   
    struct RecycledItems{
        uint256 itemId;
        uint256 weight;
        ItemLib.ItemType itemType;
        ItemStatus itemStatus;
        string description;
        bytes image;
    }

    struct RiderDetails {
        uint256 id;
        string name;
        string phoneNumber;
        string vehicleNumber;
        address walletAddress;
        string homeAddress;
        RiderStatus riderStatus;
        string country;
        uint256 capacity;
        bytes vehicleImage;
        bytes vehicleRegistrationImage;
        VehicleType vehicleType;
        bytes profilePicture;
    }
    // user id to recycleid mapping
    mapping (uint256 => mapping(uint256 => bool)) public hasUserReceivedPayment;

    //userId mapped to itemId and items 
    mapping (uint256 => mapping (uint256 => RecycledItems)) public itemByUserId;
    mapping (uint256 => bool) public hasRecycled;
    mapping (uint256 => uint256) public recycledItemId;
    mapping (uint256 => uint256) public totalRecycleddByUser;
    mapping (uint256 => uint256) public totalEarned;

    mapping (uint256 => RiderDetails) public riderId;
    mapping (uint256 => bool) public validRider;
    mapping (uint256 => bool) public isApproved;

    error AlreadyPaid();
    error NoRecycleItem();
    error InsufficientPayment();
    error NotConfirmed();

    event ItemRecycled(address indexed user, uint256 itemId, string itemType, uint256 weight);
    event PaidForRecycledItem(address indexed user, uint256 indexed userId, uint256 itemId, ItemLib.ItemType itemType);
    event RiderApproved(uint256 indexed riderId, string _name, 
                              string _number, 
                              string  _vehicleNumber,
                              bytes  _image,
                              string _country,
                              VehicleType _vehicleType);


    function registerUser(string memory _address, string memory _number, string memory _name, bytes memory _picture) public {
        _registerUser( _address, _number, _name, _picture);
    }

    function registerAdmin(address _admin) public {
        _registerAdmin(_admin);
    }

    function registerProducer(string memory  _name, string memory _country, uint256 _number) public {
        registerProductOwner(msg.sender, _name, _country, _number);    
    }

    function riderApplication(string memory _name, 
                              string memory _number, 
                              string memory _vehicleNumber,
                              string memory _homeAddress,
                              string memory _country,
                              uint256 _capacity,
                              bytes memory _image,
                              bytes memory _vehicleRegistration,
                              VehicleType _vehicleType,
                              bytes memory _picture

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
            country : _country, 
            capacity : _capacity,
            vehicleImage : _image,
            vehicleRegistrationImage : _vehicleRegistration,
            vehicleType : _vehicleType,
            profilePicture : _picture
        }); 
    }

    function approveRider(uint256 _riderId) public {
        onlyAdmin();
        if(isApproved[_riderId]){
            revert ("Rider is already approved");
        }
        if(riderId[_riderId].id != _riderId){
            revert ("Rider does not exist with that Id");
        }
        if(riderId[_riderId].riderStatus == RiderStatus.Rejected){
            revert ("Rider is Rejected, needs to re-apply");
        }
        riderId[_riderId].riderStatus = RiderStatus.Approved;
        validRider[_riderId] = true;
        isApproved[_riderId] = true;
        emit RiderApproved(_riderId, riderId[_riderId].name, riderId[_riderId].phoneNumber, riderId[_riderId].vehicleNumber, riderId[_riderId].vehicleImage, riderId[_riderId].country, riderId[_riderId].vehicleType);
    }

    function banRider(uint256 _riderId) public {
        onlyAdmin();
        if(riderId[_riderId].id == _riderId){
            revert ("Rider does not exist with that Id");
        }
        if(riderId[_riderId].riderStatus == RiderStatus.Rejected){
            revert ("Rider is Rejected, needs to re-apply");
        }
        riderId[_riderId].riderStatus = RiderStatus.Banned;
        validRider[_riderId] = false;
    }
    
    function recycleItem(string memory _type, uint256 _weight, string memory _description, bytes memory _data) public { 
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
            itemStatus : ItemStatus.Pending_Confirmation,
            description: _description,
            image: _data
        });

        hasRecycled[id] = true;
        hasUserReceivedPayment[id][recycledItemId[id]] = false;
        totalRecycleddByUser[id] += _weight;
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
        uint256 rate = rates[_rType];
        uint256 amount = itemWeight * rate;

        emit PaidForRecycledItem(user, _userId, _recycledItemId, _rType);
        (bool success, ) = payable(user).call{value: amount * (10 ** DECIMALS)}("");
        require(success, "Transfer failed");
        totalEarned[_userId] += amount;
        hasUserReceivedPayment[_userId][_recycledItemId] = true;   
    }

    function deleteUserAccount(address _user) public {
        _deleteUser(_user);
    }

    function deleteAdmin(address _admin) public {
        _deleteAdmin(_admin);
    }

    // function deleteAdminById(uint256 _adminId) public {
    //     _deleteAdminById(_adminId);
    // }

    function setRate(ItemLib.ItemType _type, uint256 _rate) public {
        _setRate(_type, _rate);
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