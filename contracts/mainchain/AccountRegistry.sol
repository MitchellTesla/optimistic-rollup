pragma solidity ^0.6.6;

import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "openzeppelin-solidity/contracts/cryptography/ECDSA.sol";


contract AccountRegistry is Ownable {
    mapping(address => bool) public registeredAccounts;

    event AccountRegistered(address account);

    function registerAccount(address _account, bytes calldata _signature)
        external
    {
        require(!registeredAccounts[_account], "Account already registered");
        bytes32 messageHash = keccak256(
            abi.encodePacked(address(this), "registerAccount")
        );
        bytes32 prefixedHash = ECDSA.toEthSignedMessageHash(messageHash);
        require(
            ECDSA.recover(prefixedHash, _signature) == _account,
            "Register signature is invalid!"
        );
        registeredAccounts[_account] = true;
        emit AccountRegistered(_account);
    }
}
