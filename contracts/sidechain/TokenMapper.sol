pragma solidity ^0.6.6;

import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "./SidechainERC20.sol";


contract TokenMapper is Ownable {
    mapping(address => address) public mainchainTokenToSidechainToken;
    mapping(address => address) public sidechainTokenToMainchainToken;

    event TokenMapped(
        address indexed mainchainToken,
        address indexed sidechainToken
    );

    function mapToken(
        address _mainchainToken,
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) public onlyOwner returns (address token) {
        require(
            mainchainTokenToSidechainToken[_mainchainToken] == address(0x0),
            "Token already mapped"
        );

        address sidechainToken = address(
            new SidechainERC20(_mainchainToken, _name, _symbol, _decimals)
        );

        mainchainTokenToSidechainToken[_mainchainToken] = sidechainToken;
        sidechainTokenToMainchainToken[sidechainToken] = _mainchainToken;

        emit TokenMapped(_mainchainToken, sidechainToken);

        return sidechainToken;
    }
}
