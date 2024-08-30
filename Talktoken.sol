// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Talktoken is ERC20, ERC20Burnable, ReentrancyGuard, Ownable {
    address public charityWallet;
    address public liquidityPool;
    uint256 public constant CHARITY_PERCENTAGE = 2; // 2% for charity
    uint256 public constant BURN_PERCENTAGE = 1; // 1% for burning
    uint256 public constant MAX_TOKENS_PER_WALLET = 1000000 * 10**18; // example limit

    mapping(address => bool) private _whitelistedAddresses;

    event TokensStaked(address indexed user, uint256 amount);
    event TokensUnstaked(address indexed user, uint256 amount);
    event CharityWalletChanged(address indexed newCharityWallet);
    event LiquidityPoolChanged(address indexed newLiquidityPool);

    constructor(address initialOwner) ERC20("Talktoken", "TALK") Ownable(initialOwner) {
        _mint(msg.sender, 45000000 * 10**18); // Initial supply
        charityWallet = 0xb8e103DC617CDE7b393f81f0155604a7F4402489;
        _whitelistedAddresses[msg.sender] = true;
    }

    modifier onlyWhitelisted() {
        require(_whitelistedAddresses[msg.sender], "Not whitelisted");
        _;
    }

    function setCharityWallet(address newCharityWallet) external onlyWhitelisted {
        charityWallet = newCharityWallet;
        emit CharityWalletChanged(newCharityWallet);
    }

    function setLiquidityPool(address newLiquidityPool) external onlyWhitelisted {
        liquidityPool = newLiquidityPool;
        emit LiquidityPoolChanged(newLiquidityPool);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        uint256 charityAmount = (amount * CHARITY_PERCENTAGE) / 100;
        uint256 burnAmount = (amount * BURN_PERCENTAGE) / 100;
        uint256 transferAmount = amount - charityAmount - burnAmount;

        _transfer(_msgSender(), charityWallet, charityAmount);
        _burn(_msgSender(), burnAmount);
        _transfer(_msgSender(), recipient, transferAmount);

        return true;
    }

    function stakeTokens(uint256 amount) external nonReentrant {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        _transfer(msg.sender, liquidityPool, amount);
        emit TokensStaked(msg.sender, amount);
    }

    function unstakeTokens(uint256 amount) external nonReentrant {
        _transfer(liquidityPool, msg.sender, amount);
        emit TokensUnstaked(msg.sender, amount);
    }

    function addWhitelistAddress(address account) external onlyOwner {
        _whitelistedAddresses[account] = true;
    }

    function removeWhitelistAddress(address account) external onlyOwner {
        _whitelistedAddresses[account] = false;
    }
}
