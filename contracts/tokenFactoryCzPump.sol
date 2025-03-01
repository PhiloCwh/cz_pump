// SPDX-License-Identifier: MIT

//ETH
import "./standToken4.sol";
pragma solidity ^0.8.17;

contract tokenFactory{

    uint constant ONE_ETH = 10 ** 18;


    function createToken(address _user,string memory _name,string memory _simple,string memory _tokenUri) public returns(address){
        bytes32 _salt = keccak256(
            abi.encodePacked(
                _name,_simple,_user,block.timestamp
            )
        );
        standToken tokenAddr = new standToken{
            salt : bytes32(_salt)
        }
        (_name,_simple,_tokenUri,msg.sender);
        return address(tokenAddr);

    }
}
