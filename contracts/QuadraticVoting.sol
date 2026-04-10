// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title QuadraticVoting - Governance contract with quadratic cost formula
/// @author Your Name
/// @notice Users spend N² tokens to cast N votes on a proposal
/// @dev Requires QVToken approval before voting

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract QuadraticVoting {

    /// @notice The ERC-20 token used for voting
    IERC20 public token;

    /// @notice Address that receives spent tokens (acts as a burn address)
    address public treasury;

    /// @notice Owner of the contract
    address public owner;

    /// @notice Struct representing a governance proposal
    /// @param description Human-readable description of the proposal
    /// @param totalVoteWeight Sum of all vote weights cast (not number of voters)
    /// @param active Whether voting is still open
    struct Proposal {
        string description;
        uint256 totalVoteWeight;
        bool active;
    }

    /// @notice All proposals indexed by ID
    mapping(uint256 => Proposal) public proposals;

    /// @notice Tracks how many votes each address has cast per proposal
    mapping(uint256 => mapping(address => uint256)) public votesCast;

    /// @notice Total number of proposals created
    uint256 public proposalCount;

    /// @dev Emitted when a new proposal is created
    event ProposalCreated(uint256 indexed proposalId, string description);

    /// @dev Emitted when a vote is cast
    /// @param proposalId The proposal voted on
    /// @param voter The address that voted
    /// @param voteWeight The N votes cast
    /// @param tokensCost The N² tokens spent
    event VoteCast(uint256 indexed proposalId, address indexed voter, uint256 voteWeight, uint256 tokensCost);

    /// @dev Restricts to contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    /// @notice Deploy the contract with a token address
    /// @param tokenAddress Address of the deployed QVToken contract
    constructor(address tokenAddress) {
        token = IERC20(tokenAddress);
        treasury = address(this); // tokens are sent to this contract (effectively burned from circulation)
        owner = msg.sender;
    }

    /// @notice Create a new proposal
    /// @param description Text describing the proposal
    /// @return proposalId The ID of the newly created proposal
    function createProposal(string calldata description) external onlyOwner returns (uint256 proposalId) {
        proposalId = proposalCount;
        proposals[proposalId] = Proposal({
            description: description,
            totalVoteWeight: 0,
            active: true
        });
        proposalCount++;
        emit ProposalCreated(proposalId, description);
    }

    /// @notice Cast N votes on a proposal — costs N² tokens
    /// @dev Caller must have approved this contract to spend N² tokens beforehand
    /// @param proposalId The ID of the proposal to vote on
    /// @param voteWeight The number of votes (N) to cast
    function castVote(uint256 proposalId, uint256 voteWeight) external {
        require(proposalId < proposalCount, "Invalid proposal");
        require(proposals[proposalId].active, "Proposal not active");
        require(voteWeight > 0, "Vote weight must be > 0");

        uint256 tokenCost = voteWeight * voteWeight; // N² formula

        // Transfer N² tokens from voter to this contract
        bool success = token.transferFrom(msg.sender, treasury, tokenCost);
        require(success, "Token transfer failed");

        // Update proposal vote weight
        proposals[proposalId].totalVoteWeight += voteWeight;
        votesCast[proposalId][msg.sender] += voteWeight;

        emit VoteCast(proposalId, msg.sender, voteWeight, tokenCost);
    }

    /// @notice Close a proposal to stop further voting
    /// @param proposalId The proposal to close
    function closeProposal(uint256 proposalId) external onlyOwner {
        require(proposalId < proposalCount, "Invalid proposal");
        proposals[proposalId].active = false;
    }

    /// @notice Get proposal details
    /// @param proposalId The proposal ID
    /// @return description The proposal text
    /// @return totalVoteWeight Total votes accumulated
    /// @return active Whether voting is open
    function getProposal(uint256 proposalId) external view returns (
        string memory description,
        uint256 totalVoteWeight,
        bool active
    ) {
        Proposal storage p = proposals[proposalId];
        return (p.description, p.totalVoteWeight, p.active);
    }
}