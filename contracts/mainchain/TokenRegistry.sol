pragma solidity ^0.6.6;

import "openzeppelin-solidity/contracts/access/Ownable.sol";


contract TokenRegistry is Ownable {
    mapping(address => uint256) public tokenAddressToTokenIndex;
    mapping(uint256 => address) public tokenIndexToTokenAddress;
    uint256 numTokens = 0;

    event TokenRegistered(
        address indexed tokenAddress,
        uint256 indexed tokenIndex
    );

    function registerToken(address _tokenAddress) external onlyOwner {
        // Register token with an index if it isn't already
        if (
            _tokenAddress != address(0) &&
            tokenAddressToTokenIndex[_tokenAddress] == 0
        ) {
            tokenAddressToTokenIndex[_tokenAddress] = numTokens;
            tokenIndexToTokenAddress[numTokens] = _tokenAddress;
            emit TokenRegistered(_tokenAddress, numTokens);
            numTokens++;
        }
    }
}
