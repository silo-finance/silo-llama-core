// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../interfaces/IMagician.sol";
import "../_common/libraries/FraxUsdcPoolLib.sol";
import "../_common/libraries/SdaiFraxPoolLib.sol";
import "../_common/libraries/SdaiSusdePoolLib.sol";
import "../_common/libraries/UsdcCrvUsdcPoolLib.sol";
import "../_common/libraries/CrvUSDToWethViaTriCrvPoolLib.sol";

/// @dev sUSDe Magician
/// IT IS NOT PART OF THE PROTOCOL. SILO CREATED THIS TOOL, MOSTLY AS AN EXAMPLE.
contract SUSDeViaCurveMaigicianEth is IMagician {
    using FraxUsdcPoolLib for uint256;
    using SdaiFraxPoolLib for uint256;
    using SdaiSusdePoolLib for uint256;
    using UsdcCrvUsdcPoolLib for uint256;
    using CrvUSDToWethViaTriCrvPoolLib for uint256;

    IERC20 public constant SUSDE = IERC20(0x9D39A5DE30e57443BfF2A8307A4256c8797A3497);
    IERC20 public constant SDAI = IERC20(0x83F20F44975D03b1b09e64809B757c47f942BEeA);
    IERC20 public constant FRAX = IERC20(0x853d955aCEf822Db058eb8505911ED77F175b99e);
    IERC20 public constant USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IERC20 public constant CRV_USD = IERC20(0xf939E0A03FB07F59A73314E73794Be0E57ac1b4E);

    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    address public constant SDAI_FRAX_POOL = 0xcE6431D21E3fb1036CE9973a3312368ED96F5CE7;
    address public constant USDC_CRV_USD_POOOL = 0x4DEcE678ceceb27446b35C672dC7d61F30bAD69E;
    address public constant FRX_USDC_POOL = 0xDcEF968d416a41Cdac0ED8702fAC8128A64241A2;
    address public constant SDAI_SUSDE_POOL = 0x167478921b907422F8E88B43C4Af2B8BEa278d3A;
    address public constant TRI_CRV_POOL = 0x4eBdF703948ddCEA3B11f675B4D1Fba9d2414A14;

    error Unsupported();

    /// @inheritdoc IMagician
    function towardsNative(
        address _asset,
        uint256 _amount
    )
        external
        virtual
        returns (address tokenOut, uint256 amountOut)
    {
        if (_asset != address(SUSDE)) revert Unsupported();

        tokenOut = address(WETH);

        amountOut;

        {
            amountOut = _amount
                .susdeToSdaiViaCurve(SDAI_SUSDE_POOL, SUSDE)
                .sdaiToFraxViaCurve(SDAI_FRAX_POOL, SDAI)
                .fraxToUsdcViaCurve(FRX_USDC_POOL, FRAX)
                .usdcToCrvUsdViaCurve(USDC_CRV_USD_POOOL, USDC);
        }

        amountOut = amountOut.crvUsdToWethViaTriCrv(TRI_CRV_POOL, CRV_USD);
    }

    /// @dev As Curve LP Tokens can be collateral-only assets we skip the implementation of this function
    function towardsAsset(address, uint256) external virtual pure returns (address, uint256) {
        revert Unsupported();
    }
}
