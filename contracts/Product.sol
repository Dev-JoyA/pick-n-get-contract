// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract Product {
    uint256[] private productIds;
    uint256 private productCount;
    uint256 private registrationCount;

    struct Details {
        string name;
        string country;
        uint256 phoneNumber;
    }

    //registration id 
    mapping(uint256 => bool) public isProducerRegistered;
    //registration id per details 
    mapping (uint256 => Details) public ownerDetails;
    mapping (uint256 => address) public productOwner;
    //registration Id
    mapping (address => uint256) public registrationId;

    event ProductAdded(uint256 indexed id, address owner);

    error AlreadyRegistered();
    error Invalid(address);

    function registerProductOwner (address _producer, string memory  _name, string memory _country, uint256 _number) internal {
        if(_producer == address(0)){
            revert Invalid(_producer);
        }
        if(registrationId[_producer] != 0){
            revert AlreadyRegistered();
        }

        registrationCount++;
        ownerDetails[registrationCount] = Details({
            name : _name,
            country : _country,
            phoneNumber : _number
        });

        isProducerRegistered[registrationCount] = true;
        registrationId[_producer] = registrationCount;
    }
   

    function getProductOwner(uint256 _id) internal view returns (address) {
        require(isProducerRegistered[_id], "Product not registered");
        return productOwner[_id];
    }

    function getAllProductIds() internal view returns (uint256[] memory) {
        return productIds;
    }

    function totalProducts() internal view returns (uint256) {
        return productCount;
    }
}
