// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library ItemLib {
    enum ItemType { PAPER, PLASTIC, METALS, GLASS, OTHERS }

    function toItemType(string memory _type) internal pure returns (ItemType) {
        bytes32 t = keccak256(bytes(_type));

        if (t == keccak256("paper")) {
            return ItemType.PAPER;
        } else if (t == keccak256("plastic")) {
            return ItemType.PLASTIC;
        } else if (t == keccak256("metals")) {
            return ItemType.METALS;
        } else if (t == keccak256("glass")) {
            return ItemType.GLASS;
        } else {
            return ItemType.OTHERS;
        }
    }

    function toItemWeight(uint256 _weight, uint256 _rate, ItemType _type) internal pure returns (uint256){
        if(_weight < 5){
            return 0;
        }

        if(_type == ItemType.PAPER){
            return (_weight * _rate);
        }else if(_type == ItemType.GLASS){
            return ((_weight * _rate) / 2 );
        }else if(_type == ItemType.METALS){
            return ((_weight * _rate) * 3);
        }else if(_type == ItemType.PLASTIC){
            return ((_weight * _rate) * 2);
        }else if(_type == ItemType.OTHERS){
            return ((_weight * _rate) / 3);
        }else {
            return 0;
        }
    }
}
