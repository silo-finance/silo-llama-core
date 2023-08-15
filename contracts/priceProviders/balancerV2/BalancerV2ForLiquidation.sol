// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.7.6;
pragma abicoder v2;

import "./BalancerV2PriceProviderV2.sol";

/// @title BalancerV2ForLiquidation
/// @notice This contract is used only for liquidation purposes
contract BalancerV2ForLiquidation is BalancerV2PriceProviderV2 {
    /// @param _priceProvidersRepository address of PriceProvidersRepository
    /// @param _vault main BalancerV2 contract, something like router for Uniswap but much more
    /// @param _periodForAvgPrice period in seconds for TWAP price, ie. 1800 means 30 min
    constructor(
        IPriceProvidersRepository _priceProvidersRepository,
        IVault _vault,
        uint32 _periodForAvgPrice
    ) BalancerV2PriceProviderV2(_priceProvidersRepository, _vault, _periodForAvgPrice) {
        // all configuration is in BalancerV2PriceProviderV2
    }

    /// @dev Setup pool for asset. Use it also for update.
    /// @param _asset asset address
    /// @param _poolId BalancerV2 pool ID
    function setupAsset(address _asset, bytes32 _poolId) external virtual override onlyManager {
        IERC20[] memory tokens = verifyPool(_poolId, _asset);

        assetsPools[_asset] = BalancerPool(_poolId, resolvePoolAddress(_poolId), address(tokens[0]) == _asset);

        emit PoolForAsset(_asset, _poolId);
    }

    /// @inheritdoc IPriceProvider
    function assetSupported(address _asset) external view virtual override returns (bool) {
        return assetsPools[_asset].priceOracle != address(0) || _asset == quoteToken;
    }

    /// @notice Checks if provided `_poolId` is valid pool for `_asset`
    /// @dev NOTICE: keep in ming anyone can register pool in balancer Vault
    /// https://github.com/balancer-labs/balancer-v2-monorepo
    /// /blob/09c69ed5dc4715a0076c1dc87a81c0b6c2669b5a/pkg/vault/contracts/PoolRegistry.sol#L67
    /// @param _poolId balancer poolId
    /// @param _asset token address for which we want to check the pool
    /// @return tokens IERC20[] pool tokens in original order, vault throws `INVALID_POOL_ID` error when pool is invalid
    function verifyPool(bytes32 _poolId, address _asset) public view virtual override returns (IERC20[] memory tokens) {
        if (_asset == address(0)) revert("AssetIsZero");
        if (_poolId == bytes32(0)) revert("PoolIdIsZero");

        address quote = quoteToken;

        uint256[] memory balances;
        (tokens, balances,) = vault.getPoolTokens(_poolId);

        (address tokenAsset, address tokenQuote) = address(tokens[0]) == quote
            ? (address(tokens[1]), address(tokens[0]))
            : (address(tokens[0]), address(tokens[1]));

        if (tokenAsset != _asset) revert("InvalidPoolForAsset");

        if (tokenQuote != quote) revert("InvalidPoolForQuoteToken");

        uint256 quoteBalance = address(tokens[0]) == quote ? balances[0] : balances[1];
        if (quoteBalance == 0) revert("EmptyPool");
    }

    function getPrice(address) public pure virtual override returns (uint256) {
        revert("NotSupported");
    }
}
