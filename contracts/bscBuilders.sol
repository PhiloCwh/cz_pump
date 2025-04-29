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
    uint256 public totalSupply;
    uint256 public maxTotalSupply = 3000;
    bool isReveal;
    uint256 constant nftPrice = 1e16;
    uint256 constant nftWlPrice = 5e15;


    mapping (address => bool) public whiteList;

    constructor()Ownable(msg.sender) ERC721("bscBuilders", "BB") {}


    fallback() external payable {
        require(msg.value % 1e16 == 0,"require uint BNB");
        require(msg.value >= nftPrice,"require  1 BNB");
        safeMintByAmount(msg.value / 1e16,msg.sender);
     }

     //set

    function setWhiteList(address _user) internal {
        whiteList[_user] = true;
    }

    function setWhiteListByList(address [] memory _user) public onlyOwner{
        for (uint256 i = 0 ;i < _user.length; i++){
            whiteList[_user[i]] = true;
        }
    }

    function setUnrevealTokenURI(string memory _tokenURI) public onlyOwner {
        unrevealTokenURI = _tokenURI;
    }

    function setBaseURI(string memory _baseURI) external onlyOwner {
        baseURI = _baseURI;
    } 

    function setReveal() public onlyOwner {
        isReveal = !isReveal;
    }

    function safeMint(address _to) internal {
        require(totalSupply + 1 <= maxTotalSupply,"exceed max supply");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(_to, tokenId);
        totalSupply++;
    }

    function mintWithWhiteList() public payable  {
        require(whiteList[msg.sender],"you are didn it whitelist");
        require(msg.value == nftWlPrice,"require 0.005BNB");
        whiteList[msg.sender] = false;
        safeMint(msg.sender);

    }

    function safeMintByAmount(uint _amount,address _to) internal {
        for(uint i; i < _amount; i++){
            safeMint(_to);
        }
    }


    function withdrawToken(address _ERC20) external onlyOwner{
        IERC20 ERC20W = IERC20(_ERC20);
        ERC20W.transfer(msg.sender,ERC20W.balanceOf(address(this)));
    }

    function withdrawBNB(uint _amount) external onlyOwner {
        payable (msg.sender).transfer(_amount);
    }


    function withdrawAllBNB() external onlyOwner {
        payable (msg.sender).transfer(address(this).balance);
    }

    

    function burnNFTGetBNB(uint256 _tokenId) external {
        transferFrom(msg.sender, address(this), _tokenId);
        _burn(_tokenId);
        payable (msg.sender).transfer(1e16);
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
