// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./CrvViaTriCrvMagician.sol";

/// @dev CRV Magician
/// IT IS NOT PART OF THE PROTOCOL. SILO CREATED THIS TOOL, MOSTLY AS AN EXAMPLE.
contract CrvViaTriCrvMagicianETH is CrvViaTriCrvMagician {
    constructor() CrvViaTriCrvMagician(
        0x4eBdF703948ddCEA3B11f675B4D1Fba9d2414A14, // TRI_CRV_POOL
        0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, // WETH
        0xD533a949740bb3306d119CC777fa900bA034cd52  // CRV
    ) {}
}
