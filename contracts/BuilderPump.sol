
// SPDX-License-Identifier: MIT

//ETH
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Ifactory.sol";
import "./IERC20.sol";

pragma solidity ^0.8.17;

contract BuilderPump is Ownable{


//global variable

    Ifactory factory;
    IUniswapV2Router02 public uniswapRouter = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address payable immutable feeContract;
    
    mapping (address => address) public tokenCreator;

    uint constant ONE_DAY = 86400;
    uint constant ONE_ETH = 10 ** 18;
    uint public feeRate;

    mapping (address =>uint) public burnableToken;
    mapping (address => uint) public tokenIdoBnbAmount;
    mapping (address => uint) public tokenBnbBalance;
    mapping (address => mapping (address => uint)) public userIdoBnbBalance;
    mapping (address => uint) public userMaxIdoAmount;
    mapping (address => uint) public tokenIdoComplitedTime;
    mapping (address => uint) public tokenClaimTime;
    mapping (address => uint) public tokenLastTimePrice;
    mapping (address => bool) public tokenLaunched;
    mapping (address => mapping (address => bool)) public isUserClaimed;

    //event Message
    event DeployToken(address token,string name,string symbol, address creator,string description, string image, string website,string githubRepository,string twLink,uint idoAmount,uint userMaxIdoAmount,uint time);

    constructor(address _factory,address payable  _feeContract)Ownable(msg.sender)
    {
        factory = Ifactory(_factory);
        feeContract = _feeContract;
    }

    receive() payable external {}

    modifier reEntrancyMutex() {
        bool _reEntrancyMutex;

        require(!_reEntrancyMutex,"FUCK");
        _reEntrancyMutex = true;
        _;
        _reEntrancyMutex = false;

    }

//业务逻辑

    function ido(address _token) public payable reEntrancyMutex() {
        require(msg.value > 0,"bnb = 0");
        require(userIdoBnbBalance[msg.sender][_token] + msg.value <= userMaxIdoAmount[_token],"exceed max ido amount");
        require(tokenBnbBalance[_token] + msg.value <= tokenIdoBnbAmount[_token],"exceed max ido amount");
        tokenBnbBalance[_token] += msg.value;
        userIdoBnbBalance[msg.sender][_token] += msg.value;
        if(tokenBnbBalance[_token] >= 99 * tokenIdoBnbAmount[_token] / 100){
            idoComplited(_token);
        }
    }

    function claimToken(address _token) public {
        require(tokenLaunched[_token],"not complited ido");
        require(!isUserClaimed[msg.sender][_token],"alredy claim");
        require(userIdoBnbBalance[msg.sender][_token] > 0,"ido amount 0");
        IERC20(_token).transfer( msg.sender,100000000 * ONE_ETH * 10 / 100 * userIdoBnbBalance[msg.sender][_token] / tokenIdoBnbAmount[_token]);
        isUserClaimed[msg.sender][_token] = true;
        
    }

    function idoComplited(address _token) internal {
        //require(tokenCreator[_token] == msg.sender,"not token creator");
        require(!tokenLaunched[_token],"complited ido");
        require(tokenBnbBalance[_token] >= 99 * tokenIdoBnbAmount[_token] / 100,"fuck");
        IERC20(_token).approve(0x10ED43C718714eb63d5aA57B78B54704E256024E, 100000000 * ONE_ETH);
        
        uniswapRouter.addLiquidityETH{value : tokenIdoBnbAmount[_token] / 2}(
            _token,                // ERC20 代币地址
            100000000 * ONE_ETH * 5 / 100,  // 希望添加的代币数量
            100000000 * ONE_ETH * 5 / 100,       // 最小代币数量（滑点保护）
            tokenIdoBnbAmount[_token] / 2,         // 最小ETH数量（滑点保护）
            address(0),           // 接收流动性凭证的地址
            block.timestamp             // 截止时间
        );
        tokenLaunched[_token] = true;
        tokenLastTimePrice[_token] = getPrice(_token);
        tokenClaimTime[_token] = block.timestamp;
        burnableToken[_token] = 100000000 * ONE_ETH * 85 / 100;
        
        if(feeRate != 0){
            uint fee = feeRate * tokenBnbBalance[_token] / 100;
            feeContract.transfer(fee);
            payable (tokenCreator[_token]).transfer((tokenBnbBalance[_token] - tokenIdoBnbAmount[_token] / 2 - fee));
        }else{
           payable (tokenCreator[_token]).transfer((tokenBnbBalance[_token] - tokenIdoBnbAmount[_token] / 2 )); 
        }
        
        
    }

    function unlockToken(address _token) public reEntrancyMutex(){
        //require(block.timestamp - tokenClaimTime[_token] >= 180 * ONE_DAY,"require 180 days");
        require(tokenLaunched[_token],"not complited ido");
        require(checkUnlockRemainTime(_token) == 0,"require 30 days");
        require(tokenCreator[_token] == msg.sender,"not creator");
        uint price = getPrice(_token);
        require(price >= 2 * tokenLastTimePrice[_token],"price not enought");
        IERC20(_token).transfer(msg.sender,100000000 * ONE_ETH * 5 / 100);
        tokenLastTimePrice[_token] = getPrice(_token);
        tokenClaimTime[_token] = block.timestamp;
        burnableToken[_token] -= 100000000 * ONE_ETH * 5 / 100;
    }

    function checkUnlockRemainTime(address _token) public view returns(uint time){
        if((block.timestamp - tokenClaimTime[_token]) >= 30 * ONE_DAY){
            time = 0;
        }else{
            time = 10 * ONE_DAY - (block.timestamp - tokenClaimTime[_token]);
        }
    }


    function launchIdo(string memory _name,string memory _symbol,string memory _image,string memory _description,string memory _website,string memory _githubRepository,string memory _twLink,uint _idoBNBAmount,uint _userMaxIdoAmount) public reEntrancyMutex() returns(address){
        require(_idoBNBAmount / _userMaxIdoAmount >= 1,"not enought user");
        address _token = factory.createToken( msg.sender,_name, _symbol,_image);

        tokenCreator[_token] = msg.sender;
        tokenIdoBnbAmount[_token] = _idoBNBAmount;
        userMaxIdoAmount[_token] = _userMaxIdoAmount;
        
        emit DeployToken(_token, _name, _symbol, msg.sender, _description, _image, _website,_githubRepository, _twLink, _idoBNBAmount,_userMaxIdoAmount, block.timestamp);
        return _token;      
    }


    function renounceCreatorship(address _token) public {
        require(tokenCreator[_token] == msg.sender,"you are not creator");
        tokenCreator[_token] = address(0);
        IERC20(_token).transfer(address(0),burnableToken[_token]);
        
    }

    function renounceCreatorshipAndSendToCZ(address _token) public {
        require(tokenCreator[_token] == msg.sender,"you are not creator");
        tokenCreator[_token] = address(0);
        IERC20(_token).transfer(0x28816c4C4792467390C90e5B426F198570E29307,burnableToken[_token]);
        
    }


//解锁逻辑
    function getPrice(address _token) public view returns(uint price) {
        address uniswapPair = IUniswapV2Factory(uniswapRouter.factory()).getPair(_token,uniswapRouter.WETH());
        // 获取流动性池的储备量
        IUniswapV2Pair pair = IUniswapV2Pair(uniswapPair);
        (uint112 reserve0, uint112 reserve1, ) = pair.getReserves();

        // 确认代币是否为 token0 或 token1
        (uint112 tokenReserve,uint112 bnbReserve) = _token == pair.token0() ? (reserve0,reserve1) : (reserve1,reserve0);

        price = bnbReserve * 10**18 / tokenReserve;
    }


//风险处理
    function withDrawBnb(address payable _receiptor,uint _amount) public onlyOwner {
        payable (_receiptor).transfer(_amount);       
    }
    function withDrawERC20(address _receiptor,address _token, uint _amount) public onlyOwner {
        IERC20(_token).transfer(_receiptor,_amount);   
    }

    function setFeeRate(uint _feeRate) public onlyOwner{
        feeRate = _feeRate;
    }

    


}
pragma solidity >=0.5.0;
interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);

}
pragma solidity >=0.5.0;
interface IUniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function token0() external view returns (address);
    function token1() external view returns (address);
}
