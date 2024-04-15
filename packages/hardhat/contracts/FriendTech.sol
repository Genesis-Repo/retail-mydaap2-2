// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FriendTech is ERC20 {
    address public owner;

    mapping(address => uint256) private sharePrice;
    mapping(address => uint256) public totalShares;
    mapping(address => bool) public hasVoted;
    mapping(uint256 => uint256) public votes;

    constructor() ERC20("FriendTech", "FTK") {
        owner = msg.sender;
    }

    // Set the price per share for the caller
    function setSharePrice(uint256 price) external {
        require(price > 0, "Price must be greater than zero");
        sharePrice[msg.sender] = price;
    }

    // Get the price per share for a specific user
    function getSharePrice(address user) public view returns (uint256) {
        return sharePrice[user];
    }

    // Set the total shares owned by the caller
    function setTotalShares(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        totalShares[msg.sender] = amount;
    }

    // Get the total shares owned by a specific user
    function getTotalShares(address user) public view returns (uint256) {
        return totalShares[user];
    }

    // Buy shares from a seller by sending Ether
    function buyShares(address seller, uint256 amount) external payable {
        require(amount > 0, "Amount must be greater than zero");
        require(totalShares[seller] >= amount, "Seller does not have enough shares");
        require(sharePrice[seller] <= msg.value, "Insufficient payment");

        totalShares[seller] -= amount;
        totalShares[msg.sender] += amount;

        uint256 tokensToMint = (msg.value * 10**decimals()) / sharePrice[seller];
        _mint(msg.sender, tokensToMint);
    }

    // Sell shares to a buyer and receive Ether in return
    function sellShares(address buyer, uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(totalShares[msg.sender] >= amount, "Insufficient shares");

        totalShares[msg.sender] -= amount;
        totalShares[buyer] += amount;

        uint256 tokensToBurn = (amount * sharePrice[msg.sender]) / 10**decimals();
        _burn(msg.sender, tokensToBurn);
        payable(buyer).transfer(tokensToBurn);
    }

    // Transfer shares to another address
    function transferShares(address to, uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(totalShares[msg.sender] >= amount, "Insufficient shares");

        totalShares[msg.sender] -= amount;
        totalShares[to] += amount;

        _transfer(msg.sender, to, amount);
    }

    // Vote on a specific proposal by index
    function vote(uint256 proposalIndex) external {
        require(totalShares[msg.sender] > 0, "Must own shares to vote");
        require(!hasVoted[msg.sender], "Already voted on this proposal");

        votes[proposalIndex]++;
        hasVoted[msg.sender] = true;
    }
}