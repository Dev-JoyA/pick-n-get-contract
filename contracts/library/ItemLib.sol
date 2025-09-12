// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library ItemLib {
    enum ItemType { PAPER, PLASTIC, METALS, GLASS, ELECTRONICS, TEXTILES, OTHERS }

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
        }  else if (t == keccak256("glass")) {
            return ItemType.GLASS;
        } else if (t == keccak256("electronics")) {
            return ItemType.ELECTRONICS;
        } else if (t == keccak256("textiles")) {
            return ItemType.TEXTILES;
        } else {
            return ItemType.OTHERS;
        }
    }
}
