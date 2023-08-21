// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../_common/libraries/CrvEthTriCrvPoolLib.sol";
import "../interfaces/IMagician.sol";

interface ICrvPoolLike {
    // solhint-disable func-name-mixedcase
    function get_dx(uint256 i, uint256 j, uint256 dy) external view returns (uint256);
    function get_dy(uint256 i, uint256 j, uint256 dx) external view returns (uint256);
}

/// @dev CRV Magician
/// IT IS NOT PART OF THE PROTOCOL. SILO CREATED THIS TOOL, MOSTLY AS AN EXAMPLE.
abstract contract CrvViaTriCrvMagician is IMagician {
    using CrvEthTriCrvPoolLib for uint256;

    // solhint-disable var-name-mixedcase
    address immutable public TRI_CRV_POOL;

    IERC20 immutable public WETH;
    IERC20 immutable public CRV;
    // solhint-enable var-name-mixedcase

    error InvalidAsset();

    constructor(
        address _triCrvPool,
        address _weth,
        address _crv
    ) {
        TRI_CRV_POOL = _triCrvPool;
        WETH = IERC20(_weth);
        CRV = IERC20(_crv);
    }

    /// @inheritdoc IMagician
    function towardsNative(address _asset, uint256 _crvToSell)
        external
        virtual
        returns (address tokenOut, uint256 amountOut)
    {
        // CRV -> WETH
        if (_asset != address(CRV)) revert InvalidAsset();

        amountOut = _crvToSell.crvToWethViaTriCrv(TRI_CRV_POOL, CRV);

        tokenOut = address(WETH);
    }

    /// @inheritdoc IMagician
    function towardsAsset(address _asset, uint256 _crvToBuy)
        external
        virtual
        returns (address tokenOut, uint256 wethIn)
    {
        // WETH -> CRV
        if (_asset != address(CRV)) revert InvalidAsset();

        wethIn = _getDx(_crvToBuy);

        uint256 expectedCrv = ICrvPoolLike(TRI_CRV_POOL).get_dy(
            CrvEthTriCrvPoolLib.WETH_INDEX,
            CrvEthTriCrvPoolLib.CRV_INDEX,
            wethIn
        );

        // get_dx returns such a WETH amount that when we will do an exchange,
        // we receive ~0.0001% less than we need for the liquidation. It is dust,
        // the liquidation will fail as we need to repay the exact amount.
        // To compensate for this, we will increase WETH a little bit.
        // It is fine if we will buy ~0.0001% more.
        if (expectedCrv < _crvToBuy) {
            uint256 oneCrv = 1e18;

            uint256 wethForOneCrv = ICrvPoolLike(TRI_CRV_POOL).get_dy(
                CrvEthTriCrvPoolLib.CRV_INDEX,
                CrvEthTriCrvPoolLib.WETH_INDEX,
                oneCrv
            );

            // it is impossible that we will need to spend ETH close to uint256 max
            unchecked { wethIn += wethForOneCrv / 1e3; }
        }

        wethIn.wethToCrvViaTriCrv(TRI_CRV_POOL, WETH);

        tokenOut = address(CRV);
    }

    function _getDx(uint256 _crvToBuy) internal view returns (uint256 wethIn) {
        return ICrvPoolLike(TRI_CRV_POOL).get_dx(
            CrvEthTriCrvPoolLib.WETH_INDEX,
            CrvEthTriCrvPoolLib.CRV_INDEX,
            _crvToBuy
        );
    }
}
