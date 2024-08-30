// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

contract CharityVoting is Ownable {
    struct CharityProposal {
        address charityAddress;
        uint256 votes;
    }

    CharityProposal[] public proposals;
    mapping(address => uint256) public userVotes;

    event ProposalCreated(uint256 proposalIndex, address charityAddress);
    event Voted(address indexed voter, uint256 proposalIndex, uint256 amount);
    event CharityFundsDistributed(uint256 totalVotes);

    constructor(address initialOwner) Ownable(initialOwner){
        // Initial owner is set to the provided address
    }

    function createProposal(address charityAddress) external onlyOwner {
        proposals.push(CharityProposal({
            charityAddress: charityAddress,
            votes: 0
        }));
        emit ProposalCreated(proposals.length - 1, charityAddress);
    }

    function vote(uint256 proposalIndex, uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(userVotes[msg.sender] >= amount, "Insufficient votes");

        userVotes[msg.sender] -= amount;
        proposals[proposalIndex].votes += amount;

        emit Voted(msg.sender, proposalIndex, amount);
    }

    function distributeCharityFunds(address tokenAddress) external onlyOwner {
        uint256 totalVotes = 0;
        for (uint256 i = 0; i < proposals.length; i++) {
            totalVotes += proposals[i].votes;
        }

        require(totalVotes > 0, "No votes have been cast");

        for (uint256 i = 0; i < proposals.length; i++) {
            uint256 charityAmount = (address(this).balance * proposals[i].votes) / totalVotes;
            payable(proposals[i].charityAddress).transfer(charityAmount);
        }

        emit CharityFundsDistributed(totalVotes);
    }

    receive() external payable {}
}
