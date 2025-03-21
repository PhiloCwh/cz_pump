// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract bscBuilders is ERC721,Ownable{
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter private _tokenIdCounter;

    IERC20 ERC20;

    string public baseURI;
    string public constant baseExtension = ".json";
    uint256 constant ONE_ETHER = 10 ** 18;
    string public unrevealTokenURI;
    uint public totalSupply;
    uint public maxTotalSupply;
    bool isReveal;

    constructor()Ownable(msg.sender) ERC721("bscBuilders", "BB") {}



    function safeMint(address _to) internal {
        require(totalSupply + 1 <= maxTotalSupply,"fuck");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(_to, tokenId);
    }

    function safeMintByAmount(uint _amount) public {
        for(uint i; i < _amount; i++){
            safeMint(msg.sender);
        }
    }


    function withdrawToken(address _ERC20) external onlyOwner{
        IERC20 ERC20W = IERC20(_ERC20);
        ERC20W.transfer(msg.sender,ERC20W.balanceOf(address(this)));
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721)
        returns (string memory)
    {
        if(isReveal){
            return unrevealTokenURI;
        }else{
            return  string(abi.encodePacked(baseURI,tokenId.toString(),baseExtension));
        }
        

    }
}
