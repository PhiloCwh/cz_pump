// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
//6
import "./czpumpToken.sol";

contract standToken is ERC20{
    string private _tokenURI;

    constructor(string memory _name,string memory _simple, string memory _tokenUri,address _receipor) ERC20(0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24,_name, _simple) 
    {
        _mint(_receipor,100000000 * 10**18);
        _tokenURI = _tokenUri;
    }      
    function tokenURI() public view returns(string memory) {
        return _tokenURI;
    }
}
