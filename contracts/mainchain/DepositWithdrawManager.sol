pragma solidity ^0.6.6;
pragma experimental ABIEncoderV2;

import {IERC20} from "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/cryptography/ECDSA.sol";

import {DataTypes as dt} from "./DataTypes.sol";
import {RollupChain} from "./RollupChain.sol";
import {TransitionEvaluator} from "./TransitionEvaluator.sol";
import {AccountRegistry} from "./AccountRegistry.sol";
import {TokenRegistry} from "./TokenRegistry.sol";


contract DepositWithdrawManager {
    mapping(address => mapping(address => uint256)) public depositNonces;
    mapping(address => mapping(address => uint256)) public withdrawNonces;

    event TokenDeposited(address account, address token, uint256 amount);
    event TokenWithdrawn(address account, address token, uint256 amount);

    RollupChain rollupChain;
    TransitionEvaluator transitionEvaluator;
    AccountRegistry accountRegistry;
    TokenRegistry tokenRegistry;

    constructor(
        address _rollupChainAddress,
        address _transitionEvaluatorAddress,
        address _accountRegistryAddress,
        address _tokenRegistryAddress
    ) public {
        rollupChain = RollupChain(_rollupChainAddress);
        transitionEvaluator = TransitionEvaluator(_transitionEvaluatorAddress);
        accountRegistry = AccountRegistry(_accountRegistryAddress);
        tokenRegistry = TokenRegistry(_tokenRegistryAddress);
    }

    function registerAndDeposit(
        address _account,
        address _token,
        uint256 _amount,
        bytes calldata _registerSignature,
        bytes calldata _depositSignature
    ) external {
        accountRegistry.registerAccount(_account, _registerSignature);
        deposit(_account, _token, _amount, _depositSignature);
    }

    function deposit(
        address _account,
        address _token,
        uint256 _amount,
        bytes memory _signature
    ) public {
        uint256 nonce = depositNonces[_account][_token];
        bytes32 depositHash = keccak256(
            abi.encodePacked(
                address(this),
                "deposit",
                _account,
                _token,
                _amount,
                nonce
            )
        );
        bytes32 prefixedHash = ECDSA.toEthSignedMessageHash(depositHash);
        require(
            ECDSA.recover(prefixedHash, _signature) == _account,
            "Deposit signature is invalid!"
        );
        require(
            IERC20(_token).transferFrom(_account, address(this), _amount),
            "Deposit failed"
        );
        emit TokenDeposited(_account, _token, _amount);
        depositNonces[_account][_token]++;
    }

    function withdraw(
        address _account,
        dt.IncludedTransition memory _includedTransition,
        bytes memory _signature
    ) public {
        require(
            rollupChain.verifyWithdrawTransition(_account, _includedTransition),
            "Withdraw transition invalid"
        );
        dt.WithdrawTransition memory withdrawTransition = transitionEvaluator
            .decodeWithdrawTransition(_includedTransition.transition);
        address token = tokenRegistry.tokenIndexToTokenAddress(
            withdrawTransition.tokenIndex
        );
        uint256 withdrawNonce = withdrawTransition.nonce;
        uint256 amount = withdrawTransition.amount;
        bytes32 withdrawHash = keccak256(
            abi.encodePacked(
                address(this),
                "withdraw",
                _account,
                token,
                amount,
                withdrawNonce
            )
        );
        bytes32 prefixedHash = ECDSA.toEthSignedMessageHash(withdrawHash);
        require(
            ECDSA.recover(prefixedHash, _signature) == _account,
            "Withdraw signature is invalid!"
        );
        require(
            withdrawNonce == withdrawNonces[_account][token],
            "Wrong withdraw nonce"
        );
        withdrawNonces[_account][token]++;

        require(IERC20(token).transfer(_account, amount), "Withdraw failed");
        emit TokenWithdrawn(_account, token, amount);
    }
}
