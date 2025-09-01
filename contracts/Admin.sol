// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;


contract Admin { 

    address[] admins;
    uint256 count;
    uint256 public rate;

    error NotAuthorised();
    error InValid();

    mapping(address => uint256) public adminId;
    mapping(address => bool ) public isAdminRegistered;
    mapping(uint256 => address) public idToAdmin;


    function _onlyAdmin() private view {
      if(!isAdminRegistered[msg.sender]){
            revert NotAuthorised();
        }

    }

    function _registerAdmin(address _admin) internal {
        if(_admin == address(0)){
            revert InValid();
        }
        require(!isAdminRegistered[_admin], "Already Registered");
        admins.push(_admin);
        count++;
        isAdminRegistered[_admin] = true;
        idToAdmin[count] = _admin;
        adminId[_admin] = count;
        idToAdmin[count] = _admin; 
    }

    function _deleteAdmin(address _admin) internal {
        _onlyAdmin();
        for(uint256 i = 0; i < admins.length; i++){
            if(admins[i] == _admin){
                admins[i] = admins[admins.length - 1];
                admins.pop();

                uint256 _id = adminId[_admin];
                delete adminId[_admin];
                delete idToAdmin[_id];
                isAdminRegistered[_admin] = false;
                break;
            }
        }

    }

    function _deleteAdminById(uint256 id) internal {
    _onlyAdmin();

    address _admin = idToAdmin[id]; 
    require(_admin != address(0), "Invalid ID");

    for(uint256 i = 0; i < admins.length; i++){
        if(admins[i] == _admin){
            admins[i] = admins[admins.length - 1];
            admins.pop();

            delete adminId[_admin];
            delete idToAdmin[id];   
            isAdminRegistered[_admin] = false;
            break;
        }
    }
}


    function _setRate(uint256 _rate) internal{
        _onlyAdmin();
        rate = _rate;
    }

    function makePayment() internal view {
        _onlyAdmin();
    }    

}