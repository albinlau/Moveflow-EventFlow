// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IReserveProvider} from "./interfaces/IReserveProvider.sol";
import {UpgradeableProxy} from "./proxy/UpgradeableProxy.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract ReserveProvider is IReserveProvider, Ownable {
  // if the contract has no proxy (id => contractAddress)
  // if the contract has proxy    (id => proxyAddress)
  // the address of contract be recorded always store datas.
  mapping(bytes32 => address) private _addresses;

  bytes32 private constant ASSERT_RESERVE = "ASSERT_RESERVE";

  function setAddress(bytes32 id, address newAddress) external override onlyOwner {
    _addresses[id] = newAddress;
    emit AddressSet(id, newAddress, false);
  }

  function getAddress(bytes32 id) public view override returns (address) {
    return _addresses[id];
  }

  function getReserve() external view override returns (address) {
    return getAddress(ASSERT_RESERVE);
  }

  function setReserve(address implement, address public_key) external override onlyOwner {
    _updateImpl(ASSERT_RESERVE, implement, abi.encodeWithSignature("initialize(address)", public_key));
    emit ReserveUpdated(implement);
  }

  function _updateImpl(bytes32 id, address newAddress, bytes memory params) internal {
    // get proxy
    address payable proxyAddress = payable(_addresses[id]);

    if (proxyAddress == address(0)) {
      // new proxy & init (proxy delegateCall)
      UpgradeableProxy proxy = new UpgradeableProxy(
        newAddress, // logic
        address(this), // admin
        params
      );
      _addresses[id] = address(proxy);
      emit ProxyCreated(id, address(proxy));
    } else {
      UpgradeableProxy(proxyAddress).upgradeTo(newAddress);
    }
  }
  
  function getImplementation(address proxyAddress) external view onlyOwner returns (address) {
    UpgradeableProxy proxy = UpgradeableProxy(payable(proxyAddress));
    return proxy.getImplementation();
  }

}
