// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title QVToken - ERC-20 Token for Quadratic Voting
/// @author Your Name
/// @notice This token is used as the voting currency in the Quadratic Voting system
/// @dev Implements a minimal ERC-20 with mint capability for the owner

contract QVToken {
    /// @notice Token name
    string public name = "QuadVoteToken";

    /// @notice Token symbol
    string public symbol = "QVT";

    /// @notice Decimals (0 for simplicity - whole tokens only)
    uint8 public decimals = 0;

    /// @notice Total supply of tokens
    uint256 public totalSupply;

    /// @notice Owner of the contract (can mint tokens)
    address public owner;

    /// @notice Mapping of address to token balance
    mapping(address => uint256) public balanceOf;

    /// @notice Mapping of allowances
    mapping(address => mapping(address => uint256)) public allowance;

    /// @dev Emitted on token transfer
    event Transfer(address indexed from, address indexed to, uint256 value);

    /// @dev Emitted on approval
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /// @dev Restricts function to contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    /// @notice Deploys the token and assigns ownership to deployer
    constructor() {
        owner = msg.sender;
    }

    /// @notice Mint tokens to a specific address
    /// @param to Recipient address
    /// @param amount Number of tokens to mint
    function mint(address to, uint256 amount) external onlyOwner {
        balanceOf[to] += amount;
        totalSupply += amount;
        emit Transfer(address(0), to, amount);
    }

    /// @notice Transfer tokens to another address
    /// @param to Recipient address
    /// @param amount Number of tokens to transfer
    /// @return success True if transfer succeeds
    function transfer(address to, uint256 amount) external returns (bool success) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    /// @notice Approve a spender to use tokens on your behalf
    /// @param spender Address to approve
    /// @param amount Amount to approve
    /// @return success True if approval succeeds
    function approve(address spender, uint256 amount) external returns (bool success) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /// @notice Transfer tokens from one address to another using allowance
    /// @param from Source address
    /// @param to Recipient address
    /// @param amount Number of tokens
    /// @return success True if transfer succeeds
    function transferFrom(address from, address to, uint256 amount) external returns (bool success) {
        require(balanceOf[from] >= amount, "Insufficient balance");
        require(allowance[from][msg.sender] >= amount, "Allowance exceeded");
        allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }
}