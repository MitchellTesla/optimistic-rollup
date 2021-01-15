pragma solidity ^0.6.6;

import {ISidechainERC20} from "./ISidechainERC20.sol";


contract DummyApp {
    address token;
    uint256 amount;

    constructor(address _token) public {
        token = _token;
        amount = 1;
    }

    function playerOneDeposit(bytes memory signature) public {
        ISidechainERC20(token).transfer(
            msg.sender,
            address(this),
            amount,
            signature
        );
    }

    function playerTwoWithdraw() public {
        ISidechainERC20(token).transfer(address(this), msg.sender, amount, "");
    }
}
