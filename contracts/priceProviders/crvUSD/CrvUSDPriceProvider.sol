// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.13;

import "../IndividualPriceProvider.sol";

interface ICrvUSDPoolWithOracleLike {
    // solhint-disable-next-line
    function price_oracle() external view returns (uint256);
}

/// @title CrvUSDPriceProvider
abstract contract CrvUSDPriceProvider is IndividualPriceProvider {
    // solhint-disable-next-line var-name-mixedcase
    ICrvUSDPoolWithOracleLike public immutable POOL;
    /// @dev The asset in which the price is denominated.
    /// For the pool crvUSD/USDC it should be USDC
    address public immutable BASE_POOL_ASSET; // solhint-disable-line var-name-mixedcase

    error InvalidPool();
    error AssetNotSupported();
    error ZeroPrice();

    constructor(
        IPriceProvidersRepository _priceProvidersRepository,
        address _crvUsdToken,
        address _basePoolAsset,
        address _pool
    ) IndividualPriceProvider(_priceProvidersRepository, _crvUsdToken, "crvUSD") {
        BASE_POOL_ASSET = _basePoolAsset;
        POOL = ICrvUSDPoolWithOracleLike(_pool);

        // Sanity check. Should revert if the `_pool` address is invalid
        if (POOL.price_oracle() == 0) revert InvalidPool();
    }

    /// @inheritdoc IPriceProvider
    function getPrice(address _asset) external view virtual override returns (uint256 price) {
        if (!assetSupported(_asset)) revert AssetNotSupported();

        uint256 priceInBaseAsset = POOL.price_oracle();
        uint256 baseAssetInWeth = priceProvidersRepository.getPrice(BASE_POOL_ASSET);

        // convert price
        price = priceInBaseAsset * baseAssetInWeth;
        // the division will be fine, otherwise we will revert with a `0` price
        unchecked { price = price / 1e18; }

        // Zero price is unacceptable
        if (price == 0) revert ZeroPrice();
    }
}
