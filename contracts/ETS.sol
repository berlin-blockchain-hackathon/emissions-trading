pragma solidity ^0.4.17;

contract ETS {
    struct Firm {
        bytes32 name;
        uint allowance;
        uint balance;
        uint real;
    }
    
    mapping (address => Firm) public firms;
    mapping (bytes32 => address) public names;
    
    address public creator;
    
    function registerFirm(address a, bytes32 name, uint allowance) public {
        require(creator == msg.sender);
        firms[a] = Firm(name, allowance, 0, 0);
        names[name] = a;
    }
    
    function ETS() public {
        creator = msg.sender;
    }
    
    function setReal(address a, uint amount) public {
        require(creator == msg.sender);
        firms[a].real = amount;
    }
    
    //function getFirmByName(bytes32 name) view public returns (address) {
    //    return names[name];
    //}
}
