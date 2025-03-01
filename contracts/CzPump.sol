

// SPDX-License-Identifier: MIT

//ETH
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Ifactory.sol";
import "./IERC20.sol";

pragma solidity ^0.8.17;

contract CzPump is Ownable{


//global variable

    Ifactory factory;
    IUniswapV2Router02 public uniswapRouter = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    

    mapping (address => address) public tokenCreator;
    mapping (address => bool) public lpClaim;



//borrow variable 

    uint constant ONE_ETH = 10 ** 18;
    //address [] public createdTokenList;


    mapping (address => uint) public tokenIdoBnbAmount;
    mapping (address => uint) public tokenBnbBalance;
    mapping (address => mapping (address => uint)) public userTokenBnbBalance;
    mapping (address => uint) public tokenIdoComplitedTime;
    mapping (address => uint) public tokenClaimTime;
    mapping (address => bool) public tokenLaunched;
    mapping (address => mapping (address => bool)) public isClaimed;

    //event Message
    event DeployToken(address token,string name,string symbol, address creator,string description, string image, string website,string twLink,string tgLink, uint ethAmount,uint tokenAmount,uint time);

    constructor(address _factory)Ownable(msg.sender)
    {
        factory = Ifactory(_factory);
    }

    receive() payable external {}

    modifier reEntrancyMutex() {
        bool _reEntrancyMutex;

        require(!_reEntrancyMutex,"FUCK");
        _reEntrancyMutex = true;
        _;
        _reEntrancyMutex = false;

    }

//owner setting

    function ido(address _token) public payable reEntrancyMutex() {
        require(tokenBnbBalance[_token] + msg.value <= tokenIdoBnbAmount[_token],"exceed max ido amount");
        tokenBnbBalance[_token] += msg.value;
        userTokenBnbBalance[msg.sender][_token] += msg.value;
    }

    function claimToken(address _token) public {
        require(tokenLaunched[_token],"not complited ido");
        require(!isClaimed[msg.sender][_token],"alredy claim");
        require(userTokenBnbBalance[msg.sender][_token] > 0,"ido amount 0");
        IERC20(_token).transfer( msg.sender,100000000 * ONE_ETH * 5 / 100 * userTokenBnbBalance[msg.sender][_token] / tokenIdoBnbAmount[_token]);
        
    }

    function idoComplited(address _token) public {
        require(tokenCreator[_token] == msg.sender,"not token creator");
        IERC20(_token).approve(0x10ED43C718714eb63d5aA57B78B54704E256024E, 100000000 * ONE_ETH);
        uniswapRouter.addLiquidityETH{value : tokenIdoBnbAmount[_token] / 2}(
            _token,                // ERC20 代币地址
            100000000 * ONE_ETH * 5 / 100,  // 希望添加的代币数量
            100000000 * ONE_ETH * 5 / 100,       // 最小代币数量（滑点保护）
            tokenIdoBnbAmount[_token] / 2,         // 最小ETH数量（滑点保护）
            address(this),           // 接收流动性凭证的地址
            block.timestamp             // 截止时间
        );
        tokenLaunched[_token] = true;
    }


    function launchIdo(string memory _name,string memory _symbol,string memory _image,string memory _description,string memory _website,string memory _twLink,string memory _tgLink,uint _idoBNBAmount) public payable reEntrancyMutex() returns(address){
        address _token = factory.createToken( msg.sender,_name, _symbol,_image);
        _beForeDeployToken(_token,msg.sender);
        emit DeployToken(_token, _name, _symbol, msg.sender, _description, _image, _website, _twLink, _tgLink, msg.value, 100000000 * ONE_ETH, block.timestamp);
        return _token;
        
    }

    function _beForeDeployToken(address _token,address _deployer) internal {
        tokenCreator[_token] = _deployer;  

    }


//交易逻辑

    //Swap ETH for Tokens with tax



//清算逻辑



//读取数据




    function getTokenPrice(address token, uint256 amountIn) public view returns (uint256[] memory amounts) {
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = uniswapRouter.WETH();
        return uniswapRouter.getAmountsOut(amountIn, path);
    }

    // Get ETH price in Tokens
    function getETHPrice(address token, uint256 amountInETH) public view returns (uint256[] memory amounts) {
        address[] memory path = new address[](2);
        path[0] = uniswapRouter.WETH();
        path[1] = token;
        return uniswapRouter.getAmountsOut(amountInETH, path);
    }

    function getAmountsOut(uint amountIn, address[] calldata path)external view returns (uint[] memory amounts){
        return uniswapRouter.getAmountsOut(amountIn, path);
    }

    // function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts){
        return uniswapRouter.getAmountsIn(amountOut, path);
    }
}
pragma solidity >=0.5.0;
interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}
pragma solidity >=0.5.0;
interface IUniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}
