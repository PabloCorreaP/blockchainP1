// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.30;

contract TokenContract {

    address public owner;
    uint256 public constant TOKEN_PRICE = 5 ether;

    struct Receivers {
        string name;
        uint256 tokens;
    }

    mapping(address => Receivers) public users;

    modifier onlyOwner() {
        require(msg.sender == owner, "Solo el owner puede hacer esto");
        _;
    }

    constructor() {
        owner = msg.sender;
        users[owner].tokens = 100;
    }

    function double(uint _value) public pure returns (uint) {
        return _value * 2;
    }

    function register(string memory _name) public {
        users[msg.sender].name = _name;
    }

    function giveToken(address _receiver, uint256 _amount) onlyOwner public {
        require(users[owner].tokens >= _amount, "El owner no tiene suficientes tokens");
        users[owner].tokens -= _amount;
        users[_receiver].tokens += _amount;
    }

    function buyToken(uint256 _amount) public payable {
        require(_amount > 0, "La cantidad debe ser mayor que 0");
        uint256 cost = _amount * TOKEN_PRICE;
        require(msg.value >= cost, "Ether insuficiente: cada token cuesta 5 ether");
        require(users[owner].tokens >= _amount, "El owner no tiene suficientes tokens");

        users[owner].tokens -= _amount;
        users[msg.sender].tokens += _amount;


        uint256 excess = msg.value - cost;
        if (excess > 0) {
            (bool ok, ) = payable(msg.sender).call{value: excess}("");
            require(ok, "Fallo al devolver el exceso");
        }
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}