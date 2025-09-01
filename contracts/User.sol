// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;


contract User{
    address[] private users;
    uint256 private count;

    struct UserAccount {
        uint256 id;
        address userAddress;
    }

    //used to get userAccount id and address by id
    mapping (uint256 => UserAccount) public userAccountId;

    //used to get userAccount id by address
    mapping (address => uint256) public userId;
    
    error NotFound();
    error UserNotRegistered();
   
    function _registerUser(address _user) internal {
        if(_user == address(0)){
            revert NotFound();
        }
        require(userId[_user] == 0, "user already have an id");

        count++;
        userAccountId[count] = UserAccount({
            id : count,
            userAddress : _user
        });

        userId[_user] = count;
        
        users.push(_user);    
    }

    function _isRegistered(uint256 _id) internal view returns(bool){
        if(userAccountId[_id].userAddress == address(0)){
            revert UserNotRegistered();
        }

        return true;
    }

    function _isRegistered(address _user) internal view returns(bool) {
        return userId[_user] != 0;   
    }


   function _deleteUser(address _user) internal {
    if(_isRegistered(_user) == false){
        revert NotFound();
    }
    for (uint256 i = 0; i < users.length; i++) {
        if (users[i] == _user) {
            users[i] = users[users.length - 1];
            users.pop();
            
            uint256 id = userId[_user];
            delete userAccountId[id];
            delete userId[_user];
            break;
        }
    }
}


}