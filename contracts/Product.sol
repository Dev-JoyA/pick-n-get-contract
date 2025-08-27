// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract Product {
    uint256[] private productIds;
    uint256 private productCount;

    mapping(uint256 => bool) public isRegistered;
    mapping(uint256 => address) public productOwner;

    event ProductAdded(uint256 indexed id, address owner);

    function addProduct(uint256 _id) internal {
        require(_id > 0, "Invalid ID");
        require(!isRegistered[_id], "Product already registered");

        productIds.push(_id);
        isRegistered[_id] = true;
        productOwner[_id] = msg.sender;
        productCount++;

        emit ProductAdded(_id, msg.sender);
    }

    function getProductOwner(uint256 _id) internal view returns (address) {
        require(isRegistered[_id], "Product not registered");
        return productOwner[_id];
    }

    function getAllProductIds() internal view returns (uint256[] memory) {
        return productIds;
    }

    function totalProducts() internal view returns (uint256) {
        return productCount;
    }
}
