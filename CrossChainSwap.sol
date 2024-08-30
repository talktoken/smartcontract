// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CrossChainSwap {
    address public tokenAddress;

    constructor(address _tokenAddress) {
        tokenAddress = _tokenAddress;
    }

    function swapTokens(address recipient, uint256 amount) external {
        IERC20(tokenAddress).transferFrom(msg.sender, recipient, amount);
    }
}

