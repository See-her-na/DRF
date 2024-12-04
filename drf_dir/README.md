# DecentralizedResearchFund (DRF)

## Project Overview

DecentralizedResearchFund (DRF) is a blockchain-based smart contract system designed to revolutionize the way research is funded and managed. Built on the Stacks blockchain using Clarity, this project aims to create a transparent, efficient, and decentralized platform for research grant management.

## Features

- **Role-based Access Control**: Implements a hierarchical role system (Program Director, Reviewer, Researcher) to manage permissions.
- **Research Grant Submission**: Allows researchers to submit grant proposals with titles, abstracts, and funding targets.
- **Decentralized Funding**: Enables anyone to contribute funding to research grants they find valuable.
- **Milestone Tracking**: Facilitates the creation and approval of research milestones to ensure project progress.
- **Transparent Fund Management**: All transactions and grant statuses are recorded on the blockchain for full transparency.

## Smart Contract Structure

The smart contract includes several key components:

1. **Data Maps**:
   - `roles`: Stores user roles
   - `research-grants`: Stores grant information
   - `funding-contributions`: Records individual funding contributions
   - `research-milestones`: Tracks milestones for each grant

2. **Public Functions**:
   - `submit-research-grant`: Submit a new research grant proposal
   - `contribute-funding`: Contribute funds to a specific grant
   - `add-research-milestone`: Add a milestone to a grant
   - `approve-milestone`: Approve a completed milestone

3. **Read-only Functions**:
   - `get-research-grant`: Retrieve details of a specific grant
   - `get-contribution-by-id`: Get details of a specific funding contribution
   - `get-milestone-by-id`: Retrieve details of a specific milestone

## Getting Started

### Prerequisites

- Stacks blockchain environment
- Clarity contract deployer

### Deployment

1. Deploy the smart contract to the Stacks blockchain.
2. Initialize the contract by setting the contract owner as the Program Director.

### Interacting with the Contract

Users can interact with the contract through a frontend application or directly through blockchain transactions. Key interactions include:

- Submitting research grants (Reviewers)
- Contributing funding to grants (Any user)
- Adding and approving milestones (Program Director)

## Security Considerations

- Role-based access control ensures that only authorized users can perform sensitive operations.
- All financial transactions are handled through secure blockchain mechanisms.

## Future Enhancements

- Implement a voting system for grant approval
- Add a reputation system for researchers based on milestone completions
- Integrate with external oracles for real-world data verification

## Contributing

We welcome contributions to the DecentralizedResearchFund project. Please read our contributing guidelines before submitting pull requests.

## Acknowledgments

- Stacks blockchain community
- Open-source contributors in the decentralized science (DeSci) space

