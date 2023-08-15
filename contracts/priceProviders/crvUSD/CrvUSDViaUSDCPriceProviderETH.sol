// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./CrvUSDPriceProvider.sol";

/// @dev crvUSD price provider that resolves a price via crvUSD/USDC pool
/// IT IS NOT PART OF THE PROTOCOL. SILO CREATED THIS TOOL, MOSTLY AS AN EXAMPLE.
contract CrvUSDViaUSDCPriceProviderETH is CrvUSDPriceProvider {
    constructor(IPriceProvidersRepository _priceProvidersRepository) CrvUSDPriceProvider(
        _priceProvidersRepository,
        0xf939E0A03FB07F59A73314E73794Be0E57ac1b4E, // CRV_USD
        0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, // USDC
        0x390f3595bCa2Df7d23783dFd126427CCeb997BF4  // CRV_USD_USDT_POOL
    ) {}
}
