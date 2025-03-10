
contract TWAPOracleV3 {
    address public pool;

    constructor(address _pool) {
        pool = _pool;
    }

    function getTwapPrice(uint32 interval) external view returns (int56 twapPrice) {
        uint32;
        secondsAgo[0] = interval;
        secondsAgo[1] = 0;

        (int56[] memory tickCumulatives,) = IUniswapV3Pool(pool).observe(secondsAgo);
        int56 tickDifference = tickCumulatives[1] - tickCumulatives[0];
        twapPrice = tickDifference / int56(uint56(interval));
    }
}
