pragma solidity ^0.6.6;


interface ISidechainERC20 {
    function transfer(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata signature
    ) external returns (bool);
}
