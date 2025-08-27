// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;


contract Admin { 

    address[] admins;
    uint256 count;
    uint256 public rate;

    error NotAuthorised();
    error InValid();

    mapping(address => uint256) adminId;
    mapping(address => bool ) isRegistered;
    mapping(uint256 => address) public idToAdmin;


    function _onlyAdmin() private view {
      if(!isRegistered[msg.sender]){
            revert NotAuthorised();
        }

    }

    function registerAdmin(address _admin) internal {
        if(_admin == address(0)){
            revert InValid();
        }
        require(!isRegistered[_admin], "Already Registered");
        admins.push(_admin);
        count++;
        isRegistered[_admin] = true;
        idToAdmin[count] = _admin;
        adminId[_admin] = count;
        idToAdmin[count] = _admin; 
    }

    function deleteAdmin(address _admin) internal {
        _onlyAdmin();
        for(uint256 i = 0; i < admins.length; i++){
            if(admins[i] == _admin){
                admins[i] = admins[admins.length - 1];
                admins.pop();

                uint256 _id = adminId[_admin];
                delete adminId[_admin];
                delete idToAdmin[_id];
                isRegistered[_admin] = false;
                break;
            }
        }

    }

    function deleteAdminById(uint256 id) internal {
    _onlyAdmin();

    address _admin = idToAdmin[id]; 
    require(_admin != address(0), "Invalid ID");

    for(uint256 i = 0; i < admins.length; i++){
        if(admins[i] == _admin){
            admins[i] = admins[admins.length - 1];
            admins.pop();

            delete adminId[_admin];
            delete idToAdmin[id];   
            isRegistered[_admin] = false;
            break;
        }
    }
}


    function setRate(uint256 _rate) internal{
        _onlyAdmin();
        rate = _rate;
    }

    function makePayment() internal view {
        _onlyAdmin();
    }    

}