pragma solidity ^0.6.6;


contract DataTypes {
    struct Block {
        bytes32 rootHash;
        uint256 blockSize;
    }

    struct DepositTx {
        address account;
        address token;
        uint256 amount;
    }

    struct WithdrawTx {
        address account;
        address token;
        uint256 amount;
        uint256 nonce;
    }

    struct TransferTx {
        address sender;
        address recipient;
        address token;
        uint256 amount;
        uint256 nonce;
    }

    struct CreateAndDepositTransition {
        uint256 transitionType;
        bytes32 stateRoot;
        uint256 accountSlotIndex;
        address account;
        uint256 tokenIndex;
        uint256 amount;
        bytes signature;
    }

    struct DepositTransition {
        uint256 transitionType;
        bytes32 stateRoot;
        uint256 accountSlotIndex;
        uint256 tokenIndex;
        uint256 amount;
        bytes signature;
    }

    struct WithdrawTransition {
        uint256 transitionType;
        bytes32 stateRoot;
        uint256 accountSlotIndex;
        uint256 tokenIndex;
        uint256 amount;
        uint256 nonce;
        bytes signature;
    }

    struct CreateAndTransferTransition {
        uint256 transitionType;
        bytes32 stateRoot;
        uint256 senderSlotIndex;
        uint256 recipientSlotIndex;
        address recipientAccount;
        uint256 tokenIndex;
        uint256 amount;
        uint256 nonce;
        bytes signature;
    }

    struct TransferTransition {
        uint256 transitionType;
        bytes32 stateRoot;
        uint256 senderSlotIndex;
        uint256 recipientSlotIndex;
        uint256 tokenIndex;
        uint256 amount;
        uint256 nonce;
        bytes signature;
    }

    struct TransitionInclusionProof {
        uint256 blockNumber;
        uint256 transitionIndex;
        bytes32[] siblings;
    }

    struct IncludedTransition {
        bytes transition;
        TransitionInclusionProof inclusionProof;
    }

    struct AccountInfo {
        address account;
        uint256[] balances;
        uint256[] transferNonces;
        uint256[] withdrawNonces;
    }

    struct StorageSlot {
        uint256 slotIndex;
        AccountInfo value;
    }

    struct IncludedStorageSlot {
        StorageSlot storageSlot;
        bytes32[] siblings;
    }
}
