// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

enum VehicleType { Bike, Car, Truck, Van }

interface IPicknGet
 {
   event ItemRecycled(address indexed user, uint256 itemId, string itemType, uint256 weight);

    function registerUser() external ;

    function registerAdmin(address _admin) external;

    function registerProducer(string memory  _name, string memory _country, uint256 _number) external ;

     function riderApplication(string memory _name, 
                              uint8 _number, 
                              string memory _vehicleNumber,
                              string memory _homeAddress,
                              string memory _country,
                              uint256 _capacity,
                              bytes memory _image,
                              bytes memory _vehicleRegistration,
                              VehicleType _vehicleType
                              ) external ;

    function approveRider(uint256 _riderId) external ;

    function banRider(uint256 _riderId) external ;
    
    function recycleItem(string memory _type, uint256 _weight) external ;

    function payUser(uint256 _id, uint256 _rid) external payable ;

    function deleteUserAccount(address _user) external ;

    function deleteAdmin(address _admin) external;

    function deleteAdminById(uint256 _adminId) external;

    function setRate(uint256 _rate) external ;

    function addProduct(uint256 _id, string memory _name, uint256 _quantity, bytes memory _data, uint256 _amount) external;

    function shopProduct(uint256 _pid, uint256 _quantity) external payable;

    function fundContract() external payable ;

    function contractBalance() external view returns (uint256);
}
