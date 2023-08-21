// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../../interfaces/ICurvePoolLike128WithReturn.sol";

/// @dev Curve pool exchange
/// IT IS NOT PART OF THE PROTOCOL. SILO CREATED THIS TOOL, MOSTLY AS AN EXAMPLE.
library UsdtCrvUsdPoolLib {
    using SafeERC20 for IERC20;

    int128 constant public USDT_INDEX = 0;
    int128 constant public CRV_USD_INDEX = 1;

    uint256 constant public UNKNOWN_AMOUNT = 1;

    function crvUsdToUsdt(uint256 _amount, address _pool, IERC20 _crvUSD) internal returns (uint256 receivedUsdt) {
        _crvUSD.approve(_pool, _amount);

        receivedUsdt = ICurvePoolLike128WithReturn(_pool).exchange(
            CRV_USD_INDEX,
            USDT_INDEX,
            _amount,
            UNKNOWN_AMOUNT
        );
    }

    function usdtToCrvUsd(uint256 _amount, address _pool, IERC20 _usdt) internal returns (uint256 receivedCrvUSD) {
        _usdt.safeApprove(_pool, _amount);

        receivedCrvUSD = ICurvePoolLike128WithReturn(_pool).exchange(
            USDT_INDEX,
            CRV_USD_INDEX,
            _amount,
            UNKNOWN_AMOUNT
        );
    }
}
