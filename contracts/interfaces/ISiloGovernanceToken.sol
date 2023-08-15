// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface ISiloGovernanceToken {
    function mint(address, uint256) external;
    function burn(address, uint256) external;
    function balanceOf(address) external view returns (uint256);
    function owner() external view returns (address);
}
