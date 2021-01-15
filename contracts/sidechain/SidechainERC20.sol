pragma solidity ^0.6.6;

import {ISidechainERC20} from "./ISidechainERC20.sol";
import {ERC20} from "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/utils/Address.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "openzeppelin-solidity/contracts/cryptography/ECDSA.sol";


contract SidechainERC20 is ISidechainERC20, ERC20, Ownable {
    using SafeMath for uint256;

    address public mainchainToken;
    mapping(address => uint256) public transferNonces;
    mapping(address => uint256) public withdrawNonces;

    event Deposit(
        address indexed mainchainToken,
        address indexed account,
        uint256 amount,
        bytes signature
    );

    event Withdraw(
        address indexed mainchainToken,
        address indexed account,
        uint256 amount,
        uint256 nonce,
        bytes signature
    );

    event Transfer(
        address indexed mainchainToken,
        address indexed sender,
        address indexed recipient,
        uint256 amount,
        uint256 nonce,
        bytes signature
    );

    constructor(
        address _mainchainToken,
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) public ERC20(_name, _symbol) {
        require(_mainchainToken != address(0x0));
        mainchainToken = _mainchainToken;
        _setupDecimals(_decimals);
    }

    function deposit(
        address _account,
        uint256 _amount,
        bytes memory _signature
    ) public {
        require(_amount > 0 && _account != address(0x0));

        // TODO: Check validator signature

        _mint(_account, _amount);

        // TODO: nonce?

        emit Deposit(mainchainToken, _account, _amount, _signature);
    }

    function withdraw(
        address _account,
        uint256 _amount,
        bytes memory _signature
    ) public {
        require(_amount > 0 && balanceOf(_account) >= _amount);

        _burn(_account, _amount);

        uint256 oldNonce = withdrawNonces[_account];
        withdrawNonces[_account] = oldNonce.add(1);

        emit Withdraw(mainchainToken, _account, _amount, oldNonce, _signature);
    }

    // prettier-ignore
    function transfer(
        address _sender,
        address _recipient,
        uint256 _amount,
        bytes memory _signature
    ) public override returns (bool) {
        uint256 oldNonce = transferNonces[_sender];
        if (!Address.isContract(_sender)) {
            bytes32 hash = keccak256(
                abi.encodePacked(
                    _sender,
                    _recipient,
                    mainchainToken,
                    _amount,
                    oldNonce
                )
            );
            bytes32 prefixedHash = ECDSA.toEthSignedMessageHash(hash);
            require(
                ECDSA.recover(prefixedHash, _signature) == _sender,
                "Wrong signature"
            );
        }

        _transfer(_sender, _recipient, _amount);
        transferNonces[_sender] = oldNonce.add(1);

        emit Transfer(
            mainchainToken,
            _sender,
            _recipient,
            _amount,
            oldNonce,
            _signature
        );
        return true;
    }

    // prettier-ignore
    function transfer(address, uint256) public override returns (bool) {
        revert("Disabled feature");
    }

    // prettier-ignore
    function allowance(address, address) public override view returns (uint256) {
        revert("Disabled feature");
    }

    // prettier-ignore
    function approve(address, uint256) public override returns (bool) {
        revert("Disabled feature");
    }

    // prettier-ignore
    function transferFrom(
        address,
        address,
        uint256
    ) public override returns (bool) {
        revert("Disabled feature");
    }
}
