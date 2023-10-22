// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


interface IReserveProvider {
  event ReserveUpdated(address indexed newAddress);
  event ProxyCreated(bytes32 id, address indexed newAddress);
  event AddressSet(bytes32 id, address indexed newAddress, bool hasProxy);

  /**
   *  @dev the contract has no proxy.
   */
  function setAddress(bytes32 id, address newAddress) external;

  /**
   *  @dev the contract has proxy.
   */

  function getAddress(bytes32 id) external view returns (address);

  function getReserve() external view returns (address);

  function setReserve(address implement, address public_key) external;

}
