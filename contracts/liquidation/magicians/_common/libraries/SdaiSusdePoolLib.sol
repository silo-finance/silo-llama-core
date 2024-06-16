// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../../interfaces/ICurvePoolLike128WithReturn.sol";

/// @dev Curve pool exchange
/// IT IS NOT PART OF THE PROTOCOL. SILO CREATED THIS TOOL, MOSTLY AS AN EXAMPLE.
library SdaiSusdePoolLib {
    int128 constant public SDAI_INDEX = 0;
    int128 constant public SUSDE_INDEX = 1;

    uint256 constant public UNKNOWN_AMOUNT = 1;

    function susdeToSdaiViaCurve(
        uint256 _amount,
        address _pool,
        IERC20 _sUSDe
    ) internal returns (uint256 receivedWeth) {
        _sUSDe.approve(_pool, _amount);

        receivedWeth = ICurvePoolLike128WithReturn(_pool).exchange(
            SUSDE_INDEX,
            SDAI_INDEX,
            _amount,
            UNKNOWN_AMOUNT
        );
    }

    function sdaiToSusdeViaCurve(uint256 _amount, address _pool, IERC20 _sDAI) internal returns (uint256 receivedCrv) {
        _sDAI.approve(_pool, _amount);

        receivedCrv = ICurvePoolLike128WithReturn(_pool).exchange(
            SDAI_INDEX,
            SUSDE_INDEX,
            _amount,
            UNKNOWN_AMOUNT
        );
    }
}
