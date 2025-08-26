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
}
