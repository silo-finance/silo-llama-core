// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../../interfaces/ICurvePoolLike256WithReturn.sol";

/// @dev Curve pool exchange
/// IT IS NOT PART OF THE PROTOCOL. SILO CREATED THIS TOOL, MOSTLY AS AN EXAMPLE.
library CrvEthCurvePoolLib {
    uint256 constant public WETH_INDEX = 0;
    uint256 constant public CRV_INDEX = 1;

    uint256 constant public UNKNOWN_AMOUNT = 1;

    function crvToWethViaCurve(uint256 _amount, address _pool, IERC20 _crv) internal returns (uint256 receivedWeth) {
        _crv.approve(_pool, _amount);

        receivedWeth = ICurvePoolLike256WithReturn(_pool).exchange(
            CRV_INDEX,
            WETH_INDEX,
            _amount,
            UNKNOWN_AMOUNT
        );
    }

    function wethToCrvViaCurve(uint256 _amount, address _pool, IERC20 _weth) internal returns (uint256 receivedCrv) {
        _weth.approve(_pool, _amount);

        receivedCrv = ICurvePoolLike256WithReturn(_pool).exchange(
            WETH_INDEX,
            CRV_INDEX,
            _amount,
            UNKNOWN_AMOUNT
        );
    }
}
