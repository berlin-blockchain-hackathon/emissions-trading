pragma solidity ^0.4.17;

contract ETS {
    struct Firm {
        bytes32 name;
        uint allowance;
        uint balance;
        uint used;
    }

    mapping (address => Firm) public firms;
    mapping (bytes32 => address) public names;

    address public creator;

    uint expensivePrice = 10;
    uint cheapPrice = 2;

    function registerFirm(address a, bytes32 name, uint allowance) public {
        require(creator == msg.sender);
        firms[a] = Firm(name, allowance, 0, 0);
        names[name] = a;
    }

    function ETS() public {
        creator = msg.sender;
    }

    function setUsed(address a, uint amount) public {
        require(creator == msg.sender);
        firms[a].used = amount;
    }

    // should we check that they only buy if used > allowance?
    function buyCheapCredits() payable public {
        // TODO: Is there a better way to check for presence in mapping?
        require(firms[msg.sender].name != 0);
        
        require(msg.value <=(firms[msg.sender].allowance-firms[msg.sender].used)*cheapPrice);
        
        firms[msg.sender].balance += msg.value / cheapPrice;
        firms[msg.sender].used += msg.value / cheapPrice;
    }

    function buyExpensiveCredits() payable public {
        // TODO: Is there a better way to check for presence in mapping?
        require(firms[msg.sender].name != 0);

        // require(msg.value <=(firms[msg.sender].allowance-firms[msg.sender].used)*expensivePrice);

        firms[msg.sender].balance += msg.value / expensivePrice;
        firms[msg.sender].used += msg.value / expensivePrice;
    }

    // Testing function.
    function defaultFirm() public {
        firms[msg.sender] = Firm("foo", 100, 0, 0);
    }
}
