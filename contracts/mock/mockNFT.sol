// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract mockNFT is ERC721 {
    constructor() ERC721("mockNFT", "mNFT") {}

    function mint(address to, uint256 tokenId) external {
        _mint(to, tokenId);
    }
}