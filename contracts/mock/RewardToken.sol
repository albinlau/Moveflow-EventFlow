// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RewardToken is ERC20 {

    constructor() ERC20("Reward Token", "RCOIN") {}

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function mint(address _to, uint256 _amount) public {
        _mint(_to, _amount);
    }

}
 