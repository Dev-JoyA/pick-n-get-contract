// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library ProductLib {
    enum ProductType { PAPER, PLASTIC, METALS, GLASS, OTHERS }

    function toProductType(string memory _type) internal pure returns (ProductType) {
        bytes32 t = keccak256(bytes(_type));

        if (t == keccak256("paper")) {
            return ProductType.PAPER;
        } else if (t == keccak256("plastic")) {
            return ProductType.PLASTIC;
        } else if (t == keccak256("metals")) {
            return ProductType.METALS;
        } else if (t == keccak256("glass")) {
            return ProductType.GLASS;
        } else {
            return ProductType.OTHERS;
        }
    }

    function toProductWeight(uint256 _weight, uint256 _rate, ProductType _type) internal pure returns (uint256){
        if(_weight < 5){
            return 0;
        }

        if(_type == ProductType.PAPER){
            return (_weight * _rate);
        }else if(_type == ProductType.GLASS){
            return ((_weight * _rate) / 2 );
        }else if(_type == ProductType.METALS){
            return ((_weight * _rate) * 3);
        }else if(_type == ProductType.PLASTIC){
            return ((_weight * _rate) * 2);
        }else if(_type == ProductType.OTHERS){
            return ((_weight * _rate) / 3);
        }else {
            return 0;
        }
    }
}
