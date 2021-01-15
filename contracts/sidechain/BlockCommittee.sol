pragma solidity ^0.6.6;
pragma experimental ABIEncoderV2;

import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "openzeppelin-solidity/contracts/cryptography/ECDSA.sol";


contract BlockCommittee is Ownable {
    struct BlockProposal {
        uint256 blockNumber;
        bytes[] transitions;
    }

    address[] public validators;
    bytes[] public signatures;

    address public currentProposer;
    uint256 private currentProposerIndex;
    bool private proposalOngoing;
    BlockProposal currentProposal;
    uint256 numSignatures;

    event BlockProposed(uint256 blockNumber, bytes[] transitions);
    event BlockConsensusReached(BlockProposal proposal, bytes[] signatures);
    event ProposerChanged(address newProposer);

    modifier onlyProposer() {
        require(
            msg.sender == currentProposer,
            "Only proposer may perform action"
        );
        _;
    }

    modifier onlyWhenProposalOngoingStatus(bool status) {
        require(proposalOngoing == status, "Invalid proposal status");
        _;
    }

    constructor(address[] memory _validators) public {
        resetValidators(_validators);
    }

    function setValidators(address[] calldata _validators)
        external
        onlyOwner
        onlyWhenProposalOngoingStatus(false)
    {
        resetValidators(_validators);
    }

    function resetValidators(address[] memory _validators) internal {
        require(_validators.length > 0, "Empty validator set");

        validators = _validators;
        currentProposerIndex = 0;
        currentProposer = validators[0];
        emit ProposerChanged(currentProposer);
        resetConsensusStatus();
    }

    function proposeBlock(
        uint256 _blockNumber,
        bytes[] calldata _transitions,
        bytes calldata _signature
    ) external onlyProposer onlyWhenProposalOngoingStatus(false) {
        bytes[] memory transitions = new bytes[](_transitions.length);
        for (uint256 i = 0; i < _transitions.length; i++) {
            transitions[i] = _transitions[i];
        }
        currentProposal = BlockProposal({
            blockNumber: _blockNumber,
            transitions: transitions
        });
        proposalOngoing = true;
        // TODO: Figure out why emit BlockProposed(currentProposal) doesn't work
        emit BlockProposed(_blockNumber, transitions);
        signBlock(msg.sender, _signature);
    }

    function signBlock(address _signer, bytes memory _signature)
        public
        onlyWhenProposalOngoingStatus(true)
    {
        uint256 numValidators = validators.length;
        bool isValidator;
        for (uint256 i = 0; i < numValidators; i++) {
            if (_signer == validators[i]) {
                signatures[i] = _signature;
                isValidator = true;
                break;
            }
        }
        require(isValidator, "Signer must be a validator");

        bytes32 proposalHash = keccak256(
            abi.encode(currentProposal.blockNumber, currentProposal.transitions)
        );
        bytes32 prefixedHash = ECDSA.toEthSignedMessageHash(proposalHash);
        require(
            ECDSA.recover(prefixedHash, _signature) == _signer,
            "Signature is invalid!"
        );

        numSignatures++;
        // Require signatures from all the validators if less than 4, or 2/3 of
        // the validators if at least 4.
        bool hasEnoughSignatures = numValidators < 4
            ? numSignatures == numValidators
            : numSignatures * 3 > numValidators * 2;
        if (hasEnoughSignatures) {
            emit BlockConsensusReached(currentProposal, signatures);
            resetConsensusStatus();
            pickNextProposer();
        }
    }

    function resetConsensusStatus() internal {
        proposalOngoing = false;
        signatures = new bytes[](validators.length);
        delete currentProposal;
        numSignatures = 0;
    }

    function pickNextProposer() internal {
        currentProposerIndex = (currentProposerIndex + 1) % validators.length;
        currentProposer = validators[currentProposerIndex];
        emit ProposerChanged(currentProposer);
    }
}
