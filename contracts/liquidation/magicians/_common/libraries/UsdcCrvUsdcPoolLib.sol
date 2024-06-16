// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../../interfaces/ICurvePoolLike128WithReturn.sol";

/// @dev Curve pool exchange
/// IT IS NOT PART OF THE PROTOCOL. SILO CREATED THIS TOOL, MOSTLY AS AN EXAMPLE.
library UsdcCrvUsdcPoolLib {
    int128 constant public USDC_INDEX = 0;
    int128 constant public CRV_USD_INDEX = 1;

    uint256 constant public UNKNOWN_AMOUNT = 1;

    function usdcToCrvUsdViaCurve(uint256 _amount, address _pool, IERC20 _usdc) internal returns (uint256) {
        _usdc.approve(_pool, _amount);

        return ICurvePoolLike128WithReturn(_pool).exchange(
            USDC_INDEX,
            CRV_USD_INDEX,
            _amount,
            UNKNOWN_AMOUNT
        );
    }

    function crvUsdToUsdcViaCurve(uint256 _amount, address _pool, IERC20 _crvUsd) internal returns (uint256) {
        _crvUsd.approve(_pool, _amount);

        return ICurvePoolLike128WithReturn(_pool).exchange(
            CRV_USD_INDEX,
            USDC_INDEX,
            _amount,
            UNKNOWN_AMOUNT
        );
    }
}
