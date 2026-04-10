# Quadratic Voting Governance

## Overview
A fair voting system on Ethereum where casting N votes costs N² tokens,
preventing wealthy users from dominating governance.

## Contracts
- **QVToken.sol** — ERC-20 token used as voting currency
- **QuadraticVoting.sol** — Governance contract with N² cost formula

## Technology
- Solidity 0.8.20
- Remix IDE
- Local Geth dev node (v1.13.x)

## Setup Instructions

### 1. Start Local Geth Node
```bash
geth --dev --http --http.api eth,web3,personal,net --http.corsdomain "*" --allow-insecure-unlock console
```

### 2. Connect Remix to Geth
- Open https://remix.ethereum.org
- Environment → Custom External Http Provider → http://127.0.0.1:8545

### 3. Deploy Contracts
1. Compile and deploy `QVToken.sol` — copy the deployed contract address
2. Compile and deploy `QuadraticVoting.sol` — paste QVToken address as constructor argument

### 4. Run the Demo

**Step 1 — Mint 500 tokens to your account:**
- In Remix, call `QVToken.mint(yourAddress, 500)`
- Verify with `QVToken.balanceOf(yourAddress)` → should return `500`

**Step 2 — Create a proposal:**
- Call `QuadraticVoting.createProposal("Increase developer fund")`
- This creates proposal with ID `0`

**Step 3 — Approve QuadraticVoting contract to spend tokens:**
- Call `QVToken.approve(quadraticVotingContractAddress, 100)`
- This allows the voting contract to deduct 100 tokens (10² cost for 10 votes)

**Step 4 — Cast 10 votes:**
- Call `QuadraticVoting.castVote(0, 10)`
- The contract automatically deducts 10² = 100 tokens from your balance

**Step 5 — Verify results:**
- Call `QVToken.balanceOf(yourAddress)` → returns `400` (500 - 100)
- Call `QuadraticVoting.getProposal(0)` → returns `totalVoteWeight = 10`


