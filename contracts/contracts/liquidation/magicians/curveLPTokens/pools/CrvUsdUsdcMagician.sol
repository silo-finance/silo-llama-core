// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../../_common/libraries/UsdcUsdt3poolLib.sol";
import "../../_common/libraries/UsdtWethTricrypto2Lib.sol";
import "../../interfaces/IMagician.sol";
import "../../interfaces/ICurvePoolLike128WithReturn.sol";

/// @dev Curve LP Tokens unwrapping
/// IT IS NOT PART OF THE PROTOCOL. SILO CREATED THIS TOOL, MOSTLY AS AN EXAMPLE.
contract CrvUsdUsdcMagician is IMagician {
    using UsdcUsdt3poolLib for uint256;
    using UsdtWethTricrypto2Lib for uint256;

    /// @dev Index value for the coin (curve CRV_USD/USDC pool)
    int128 public constant USDC_INDEX_CRV_USD_USDC_POOL = 0;

    uint256 constant public UNKNOWN_AMOUNT = 1;

    // solhint-disable var-name-mixedcase
    ICurvePoolLike128WithReturn public immutable CRV_USD_USDC_POOL;
    address public immutable CRV3_POOL;
    address public immutable TRICTYPTO_2_POOL;

    IERC20 public immutable USDC;
    IERC20 public immutable USDT;
    IERC20 public immutable WETH;
    // solhint-enable var-name-mixedcase

    /// @dev Revert on a `towardsAsset` call as it in unsupported 
    error Unsupported();
    /// @dev Revert in the constructor if provided an empty address
    error EmptyAddress();

    // solhint-disable-next-line code-complexity
    constructor(
        address _crvUsdUsdcPool,
        address _crv3Pool,
        address _tricrypto2,
        address _usdc,
        address _usdt,
        address _weth
    ) {
        if (_crvUsdUsdcPool == address(0)) revert EmptyAddress();
        if (_crv3Pool == address(0)) revert EmptyAddress();
        if (_tricrypto2 == address(0)) revert EmptyAddress();
        if (_usdc == address(0)) revert EmptyAddress();
        if (_usdt == address(0)) revert EmptyAddress();
        if (_weth == address(0)) revert EmptyAddress();

        CRV_USD_USDC_POOL = ICurvePoolLike128WithReturn(_crvUsdUsdcPool);
        CRV3_POOL = _crv3Pool;
        TRICTYPTO_2_POOL = _tricrypto2;

        USDC = IERC20(_usdc);
        USDT = IERC20(_usdt);
        WETH = IERC20(_weth);
    }

    /// @dev As Curve LP Tokens can be collateral-only assets we skip the implementation of this function
    function towardsAsset(address, uint256) external virtual pure returns (address, uint256) {
        revert Unsupported();
    }

    /// @inheritdoc IMagician
    function towardsNative(
        address,
        uint256 _amount
    )
        external
        virtual
        returns (address tokenOut, uint256 amountOut)
    {
        tokenOut = address(WETH);

        amountOut = CRV_USD_USDC_POOL
            .remove_liquidity_one_coin(
                _amount,
                USDC_INDEX_CRV_USD_USDC_POOL,
                UNKNOWN_AMOUNT
            )
            .usdcToUsdtVia3Pool(address(CRV3_POOL), USDC, USDT)
            .usdtToWethTricrypto2(TRICTYPTO_2_POOL, USDT, WETH);
    }
}
