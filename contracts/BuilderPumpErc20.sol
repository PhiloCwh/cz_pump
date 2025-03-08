
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
    
    mapping (address => mapping (address => address)) public tokenCreator;//basetoken issuetoken user

    uint constant ONE_DAY = 86400;
    uint constant ONE_ETH = 10 ** 18;


    mapping (address => mapping (address => uint)) public tokenIdoBaseTokenAmount;//basetoken issuetoken amount
    mapping (address => mapping (address => uint)) public tokenBaseTokenBalance;// basetoken issuetoken amount
    mapping (address => mapping (address => mapping (address => uint))) public userIdoBaseTokenBalance; //user basetoken issue token amount
    mapping (address => mapping (address => uint)) public userMaxIdoBaseTokenAmount;//user basetoken issuetoken amount
    mapping (address => mapping (address => uint)) public tokenIdoComplitedTime;//basetoken issuetoken time
    mapping (address => mapping (address => uint)) public tokenClaimTime;//basetoken issuetoken time
    mapping (address => mapping (address => uint)) public tokenLastTimePrice;//basetoken issuetoken price
    mapping (address => mapping (address => bool)) public tokenLaunched;//basetoken issuetoken bool
    mapping (address => mapping (address => bool)) public isUserClaimed;//basetoken issuetoken bool

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

    function ido(address _baseToken,address _issueToken,uint _amount) public reEntrancyMutex() {
        require(userIdoBaseTokenBalance[msg.sender][_baseToken][_issueToken] +_amount <= userMaxIdoBaseTokenAmount[_baseToken][_issueToken],"exceed max ido amount");
        require(tokenBaseTokenBalance[_baseToken][_issueToken] + _amount <= tokenIdoBaseTokenAmount[_baseToken][_issueToken],"exceed max ido amount");
        tokenBaseTokenBalance[_baseToken][_issueToken] += _amount;
        userIdoBaseTokenBalance[msg.sender][_baseToken][_issueToken] += _amount;
        if(tokenBaseTokenBalance[_baseToken][_issueToken] >= 99 * tokenIdoBaseTokenAmount[_baseToken][_issueToken] / 100){
            idoComplited(_baseToken,_issueToken);
        }
    }

    function claimToken(address _baseToken,address _issueToken) public {
        require(tokenLaunched[_baseToken][_issueToken],"not complited ido");
        require(!tokenLaunched[_baseToken][_issueToken],"alredy claim");
        require(userIdoBaseTokenBalance[msg.sender][_baseToken][_issueToken] > 0,"ido amount 0");
        IERC20(_issueToken).transfer( msg.sender,100000000 * ONE_ETH * 10 / 100 * userIdoBaseTokenBalance[msg.sender][_baseToken][_issueToken] / tokenIdoBaseTokenAmount[_baseToken][_issueToken]);
        tokenLaunched[_baseToken][_issueToken] = true;
        
    }

    // function addLiquidity(
    //     address tokenA,
    //     address tokenB,
    //     uint amountADesired,
    //     uint amountBDesired,
    //     uint amountAMin,
    //     uint amountBMin,
    //     address to,
    //     uint deadline
    // ) external returns (uint amountA, uint amountB, uint liquidity);

    function idoComplited(address _baseToken,address _issueToken) internal {
        //require(tokenCreator[_baseToken][_issueToken] == msg.sender,"not token creator");
        require(!tokenLaunched[_baseToken][_issueToken],"complited ido");
        require(tokenBaseTokenBalance[_baseToken][_issueToken] >= 99 * tokenIdoBaseTokenAmount[_baseToken][_issueToken] / 100,"fuck");
        IERC20(_issueToken).approve(0x10ED43C718714eb63d5aA57B78B54704E256024E, 100000000 * ONE_ETH);
        uint fee = tokenBaseTokenBalance[_baseToken][_issueToken] / 100;
        uniswapRouter.addLiquidity(
            _baseToken,                // ERC20 代币地址
            _issueToken,
            tokenBaseTokenBalance[_baseToken][_issueToken],  // 希望添加的代币数量
            100000000 * ONE_ETH * 5 / 100,       // 最小代币数量（滑点保护）
            tokenBaseTokenBalance[_baseToken][_issueToken],  // 希望添加的代币数量
            100000000 * ONE_ETH * 5 / 100,       // 最小代币数量（滑点保护）
            address(0),           // 接收流动性凭证的地址
            block.timestamp             // 截止时间
        );
        tokenLaunched[_baseToken][_issueToken] = true;
        tokenLastTimePrice[_baseToken][_issueToken] = getPrice(_baseToken,_issueToken);
        tokenClaimTime[_baseToken][_issueToken] = block.timestamp;
        payable (tokenCreator[_baseToken][_issueToken]).transfer((tokenBaseTokenBalance[_baseToken][_issueToken] - tokenIdoBaseTokenAmount[_baseToken][_issueToken] / 2 - fee));
        feeContract.transfer(fee);
        
    }

    function unlockToken(address _baseToken,address _issueToken) public reEntrancyMutex(){
        //require(block.timestamp - tokenClaimTime[_baseToken][_issueToken] >= 180 * ONE_DAY,"require 180 days");
        require(tokenLaunched[_baseToken][_issueToken],"not complited ido");
        require(checkUnlockRemainTime(_baseToken,_issueToken) == 0,"require 30 days");
        require(tokenCreator[_baseToken][_issueToken] == msg.sender,"not creator");
        uint price = getPrice(_baseToken,_issueToken);
        require(price >= 2 * tokenLastTimePrice[_baseToken][_issueToken],"price not enought");
        IERC20(_issueToken).transfer(msg.sender,100000000 * ONE_ETH * 5 / 100);
        tokenLastTimePrice[_baseToken][_issueToken] = getPrice(_baseToken,_issueToken);
        tokenClaimTime[_baseToken][_issueToken] = block.timestamp;
    }

    function checkUnlockRemainTime(address _baseToken,address _issueToken) public view returns(uint time){
        if((block.timestamp - tokenClaimTime[_baseToken][_issueToken]) >= 30 * ONE_DAY){
            time = 0;
        }else{
            time = 10 * ONE_DAY - (block.timestamp - tokenClaimTime[_baseToken][_issueToken]);
        }
    }


    function launchIdo(address _baseToken,string memory _name,string memory _symbol,string memory _image,string memory _description,string memory _website,string memory _githubRepository,string memory _twLink,uint _idoBNBAmount,uint _userMaxIdoAmount) public reEntrancyMutex() returns(address){
        require(_idoBNBAmount / _userMaxIdoAmount >= 1,"not enought user");
        address _issueToken = factory.createToken( msg.sender,_name, _symbol,_image);

        tokenCreator[_baseToken][_issueToken] = msg.sender;
        tokenIdoBaseTokenAmount[_baseToken][_issueToken] = _idoBNBAmount;
        userMaxIdoBaseTokenAmount[_baseToken][_issueToken] = _userMaxIdoAmount;
        
        emit DeployToken(_issueToken, _name, _symbol, msg.sender, _description, _image, _website,_githubRepository, _twLink, _idoBNBAmount,_userMaxIdoAmount, block.timestamp);
        return _issueToken;      
    }


    function renounceCreatorship(address _baseToken,address _issueToken) public {
        require(tokenCreator[_baseToken][_issueToken] == msg.sender,"you are not creator");
        tokenCreator[_baseToken][_issueToken] = address(0);
        IERC20(_issueToken).transfer(address(0),IERC20(_issueToken).balanceOf(address(this)) - 100000000 * ONE_ETH * 5 / 100);
        
    }

    function renounceCreatorshipAndSendToCZ(address _baseToken,address _issueToken) public {
        require(tokenCreator[_baseToken][_issueToken] == msg.sender,"you are not creator");
        tokenCreator[_baseToken][_issueToken] = address(0);
        IERC20(_issueToken).transfer(0x28816c4C4792467390C90e5B426F198570E29307,IERC20(_issueToken).balanceOf(address(this)) - 100000000 * ONE_ETH * 5 / 100);
        
    }


//解锁逻辑
    function getPrice(address _baseToken,address _issueToken) public view returns(uint price) {
        address uniswapPair = IUniswapV2Factory(uniswapRouter.factory()).getPair(_baseToken,_issueToken);
        // 获取流动性池的储备量
        IUniswapV2Pair pair = IUniswapV2Pair(uniswapPair);
        (uint112 reserve0, uint112 reserve1, ) = pair.getReserves();

        // 确认代币是否为 token0 或 token1
        (uint112 tokenReserve,uint112 bnbReserve) = _issueToken == pair.token0() ? (reserve0,reserve1) : (reserve1,reserve0);

        price = bnbReserve * 10**18 / tokenReserve;
    }


//风险处理
    function withDrawBnb(address payable _receiptor,uint _amount) public onlyOwner {
        payable (_receiptor).transfer(_amount);       
    }
    function withDrawERC20(address _receiptor,address _token, uint _amount) public onlyOwner {
        IERC20(_token).transfer(_receiptor,_amount);   
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
