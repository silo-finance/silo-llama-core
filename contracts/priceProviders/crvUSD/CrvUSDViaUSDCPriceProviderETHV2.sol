// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./CrvUSDPriceProvider.sol";

/// @dev crvUSD price provider that resolves a price via crvUSD/USDC pool
/// IT IS NOT PART OF THE PROTOCOL. SILO CREATED THIS TOOL, MOSTLY AS AN EXAMPLE.
contract CrvUSDViaUSDCPriceProviderETHV2 is CrvUSDPriceProvider {
    constructor(IPriceProvidersRepository _priceProvidersRepository) CrvUSDPriceProvider(
        _priceProvidersRepository,
        0xf939E0A03FB07F59A73314E73794Be0E57ac1b4E, // CRV_USD
        0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, // USDC
        0x4DEcE678ceceb27446b35C672dC7d61F30bAD69E  // CRV_USD_USDC_POOL
    ) {}
}
