contract TWAPOracle {
    address public pair;
    uint256 public price0CumulativeLast;
    uint32 public blockTimestampLast;
    
    constructor(address _pair) {
        pair = _pair;
        (price0CumulativeLast,, blockTimestampLast) = IUniswapV2Pair(pair).getReserves();
    }

    function update() external {
        (uint256 price0Cumulative,, uint32 blockTimestamp) = IUniswapV2Pair(pair).getReserves();
        uint32 timeElapsed = blockTimestamp - blockTimestampLast;
        require(timeElapsed > 0, "No time elapsed");
        
        uint256 twapPrice = (price0Cumulative - price0CumulativeLast) / timeElapsed;

        // 更新数据
        price0CumulativeLast = price0Cumulative;
        blockTimestampLast = blockTimestamp;
    }

    function consult() external view returns (uint256) {
        return price0CumulativeLast;  // 返回当前价格（可优化）
    }
}
