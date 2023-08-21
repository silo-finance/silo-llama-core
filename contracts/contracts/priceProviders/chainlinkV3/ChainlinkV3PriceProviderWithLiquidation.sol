// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./ChainlinkV3PriceProvider.sol";
import "../../interfaces/IPriceProviderV2.sol";

contract ChainlinkV3PriceProviderWithLiquidation is IPriceProviderV2, ChainlinkV3PriceProvider {

    error PriceError();
    error NotSupported();

    constructor(
        IPriceProvidersRepository _priceProvidersRepository,
        address _emergencyManager,
        AggregatorV3Interface _quoteAggregator,
        uint256 _quoteAggregatorHeartbeat
    ) ChainlinkV3PriceProvider(
        _priceProvidersRepository,
        _emergencyManager,
        _quoteAggregator,
        _quoteAggregatorHeartbeat)
    {
    }

    /// @inheritdoc IPriceProviderV2
    function getFallbackProvider(address _asset)
        external
        view
        virtual
        override(ChainlinkV3PriceProvider, IPriceProviderV2) returns (IPriceProvider)
    {
        return assetData[_asset].fallbackProvider;
    }

    /// @inheritdoc IPriceProviderV2
    function offChainProvider() external pure virtual returns (bool) {
        return true;
    }

    /// @inheritdoc IPriceProvider
    function assetSupported(address _asset)
        public
        view
        virtual
        override(ChainlinkV3PriceProvider, IPriceProvider)
        returns (bool)
    {
        AssetData storage data = assetData[_asset];

        // Asset is supported if:
        //     - the asset is the quote token
        //       OR
        //     - the aggregator address is defined AND

        if (_asset == quoteToken) {
            return true;
        }

        return address(data.aggregator) != address(0);
    }

    /// @inheritdoc IPriceProvider
    function getPrice(address _asset)
        public
        view
        virtual
        override(ChainlinkV3PriceProvider, IPriceProvider)
        returns (uint256)
    {
        address quote = quoteToken;

        if (_asset == quote) {
            return 10 ** _QUOTE_TOKEN_DECIMALS;
        }

        (bool success, uint256 price) = _getAggregatorPrice(_asset);
        if (!success) revert PriceError();

        return price;
    }

    function _getFallbackPrice(address) internal view virtual override returns (uint256) {
        revert NotSupported();
    }

    function _setFallbackPriceProvider(address _asset, IPriceProvider _fallbackProvider)
        internal
        virtual
        override
        returns (bool changed)
    {
        if (_fallbackProvider == assetData[_asset].fallbackProvider) {
            return false;
        }

        assetData[_asset].fallbackProvider = _fallbackProvider;

        if (address(_fallbackProvider) != address(0)) {
            if (
                !priceProvidersRepository.isPriceProvider(_fallbackProvider) ||
                !_fallbackProvider.assetSupported(_asset) ||
                _fallbackProvider.quoteToken() != quoteToken
            ) {
                revert InvalidFallbackPriceProvider();
            }

            // NOT doing sanity check on price, because it is only for liquidation
            // _getFallbackPrice(_asset);
        }

        emit NewFallbackPriceProvider(_asset, _fallbackProvider);

        return true;
    }
}
