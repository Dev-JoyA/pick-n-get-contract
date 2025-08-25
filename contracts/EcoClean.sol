// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract EcoClean {
    // user will recycle item
    //admin will pay user
    // swap stable coin for fiat - FE

    mapping (address => bool) isPaid;

    // shop within the site using hbar 

    //  function recievedPayment(address _user) internal view{
    //     for(uint256 i = 0; i < users.length; i++){
    //         if(users[i] != _user){
    //             revert NotFound();
    //         }
    //     }

    //     uint256 _id = userId[_user]; 
    //     if(userAccountId[_id].userAddress != _user){
    //         revert UserNotRegistered();
    //     }  
    // }
}