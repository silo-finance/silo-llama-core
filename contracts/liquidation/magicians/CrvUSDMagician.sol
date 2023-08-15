// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interfaces/IMagician.sol";
import "./_common/libraries/UsdtCrvUsdPoolLib.sol";
import "./_common/libraries/UsdtWethTricrypto2Lib.sol";
import "./_common/libraries/CalculateAmountIn256Lib.sol";

interface ICrvUSDPoolLike {
    // solhint-disable func-name-mixedcase
    function get_dx(int128 i, int128 j, uint256 dy) external view returns (uint256);
}

/// @dev crvUSD Magician
/// IT IS NOT PART OF THE PROTOCOL. SILO CREATED THIS TOOL, MOSTLY AS AN EXAMPLE.
abstract contract CrvUSDMagician is IMagician {
    using UsdtCrvUsdPoolLib for uint256;
    using UsdtWethTricrypto2Lib for uint256;
    using CalculateAmountIn256Lib for uint256;

    error InvalidAsset();
    error InvalidCalculationResult();

    // solhint-disable var-name-mixedcase
    address immutable public TRICRYPTO_2_POOL;
    address immutable public CRV_USD_USDT_POOL;

    IERC20 immutable public WETH;
    IERC20 immutable public USDT;
    IERC20 immutable public CRV_USD;
    // solhint-enable var-name-mixedcase

    constructor(
        address _tricrypto2Pool,
        address _crvUsdPool,
        address _weth,
        address _usdt,
        address _crvUsd
    ) {
        TRICRYPTO_2_POOL = _tricrypto2Pool;
        CRV_USD_USDT_POOL = _crvUsdPool;
        WETH = IERC20(_weth);
        USDT = IERC20(_usdt);
        CRV_USD = IERC20(_crvUsd);
    }

    /// @inheritdoc IMagician
    function towardsNative(address _asset, uint256 _crvUsdToSell)
        external
        virtual
        returns (address tokenOut, uint256 amountOut)
    {
        // crvUSD -> WETH
        if (_asset != address(CRV_USD)) revert InvalidAsset();

        amountOut = _crvUsdToSell.crvUsdToUsdt(CRV_USD_USDT_POOL, CRV_USD)
            .usdtToWethTricrypto2(TRICRYPTO_2_POOL, USDT, WETH);

        tokenOut = address(WETH);
    }

    /// @inheritdoc IMagician
    function towardsAsset(address _asset, uint256 _crvUsdToBuy)
        external
        virtual
        returns (address tokenOut, uint256 wehtIn)
    {
        // WETH -> crvUSD
        if (_asset != address(CRV_USD)) revert InvalidAsset();

        uint256 usdtIn = ICrvUSDPoolLike(CRV_USD_USDT_POOL).get_dx(
            UsdtCrvUsdPoolLib.USDT_INDEX,
            UsdtCrvUsdPoolLib.CRV_USD_INDEX,
            _crvUsdToBuy
        );

        uint256 usdtOut;
        (wehtIn, usdtOut) = _calcRequiredWETH(usdtIn);

        if (usdtOut < usdtIn) revert InvalidCalculationResult();

        wehtIn.wethToUsdtTricrypto2(TRICRYPTO_2_POOL, USDT, WETH)
            .usdtToCrvUsd(CRV_USD_USDT_POOL, USDT);

        tokenOut = address(CRV_USD);
    }

    function _calcRequiredWETH(uint256 usdtIn) internal virtual view returns (uint256 wehtIn, uint256 usdtOut) {
        uint256 oneWETH = 1e18;

        CalculateAmountIn256Lib.InputWithNormalization memory input =
            CalculateAmountIn256Lib.InputWithNormalization({
                amountRequired: usdtIn,
                one: oneWETH,
                pool: TRICRYPTO_2_POOL,
                i: UsdtWethTricrypto2Lib.WETH_INDEX,
                j: UsdtWethTricrypto2Lib.USDT_INDEX,
                iDecimals: UsdtWethTricrypto2Lib.WETH_DECIMALS,
                jDecimals: UsdtWethTricrypto2Lib.USDT_DECIMALS
            });

        return CalculateAmountIn256Lib.amountIn256WithNormalization(input);
    }
}
