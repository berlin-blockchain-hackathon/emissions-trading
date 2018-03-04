pragma solidity ^0.4.17;

contract ETS {

    struct Firm {
        string name;
        uint allowance;
        uint balance;
        uint used;
    }

    struct GreenEnergy {
        string name;
        uint balance;
    }

    struct PrivatePerson {
        string name;
        uint allowance;
        uint balance;
        uint used;
    }

    mapping (address => Firm) public firms;
    mapping (address => GreenEnergy) public greens;
    mapping (address => PrivatePerson) public privats;

    address public creator;

    uint public expensivePrice = 0.3 ether;
    uint public cheapPrice = 0.1 ether;
    uint public circulation = 1;
    uint public returnPrice = this.balance / circulation;

    event CheapCreditsBought(address buyer, uint amount);
    event ExpensiveCreditsBought(address buyer, uint amount);

    function registerFirm(address a, string name, uint allowance) public {
        require(creator == msg.sender);
        firms[a] = Firm(name, allowance, 0, 0);
    }

    function registerPrivate(address a, string name, uint allowance) public {
        require(creator == msg.sender);
        privats[a] = PrivatePerson(name, allowance, 0, 0);
    }

    function registerRenewable(address a, string name) public {
        require(creator == msg.sender);
        greens[a] = GreenEnergy(name, 0);
    }

    function getMyBalance()view public returns (uint) { return this.balance; }

    function burnCredits(uint amount)public{
        require(keccak256(firms[msg.sender].name) != 0);
        require(firms[msg.sender].balance>=amount);

        firms[msg.sender].balance -= amount;
        circulation -= amount;
        returnPrice = this.balance / circulation;
    }
    function returnCredits(uint amount)public{
        require(keccak256(greens[msg.sender].name) != 0);
        require(greens[msg.sender].balance>=amount);

        greens[msg.sender].balance -= amount;
        msg.sender.transfer(amount*returnPrice);
        circulation -= amount;
        returnPrice = this.balance / circulation;
    }

    function ETS() public {
        creator = msg.sender;
    }

    function setUsed(address a, uint amount) public {
        require(creator == msg.sender);
        firms[a].used = amount;
    }

    // should we check that they only buy if used > allowance?
    function buyCredits() payable public {
        require(keccak256(firms[msg.sender].name) != 0);

        if (msg.value <= (firms[msg.sender].allowance - firms[msg.sender].used) * cheapPrice) {

            uint creditsBoughtCheap = msg.value / cheapPrice;

            firms[msg.sender].balance += creditsBoughtCheap;
            firms[msg.sender].used += creditsBoughtCheap;
            circulation += creditsBoughtCheap;
            returnPrice = this.balance / circulation;

            CheapCreditsBought(msg.sender, creditsBoughtCheap);
        } else {
            uint input = msg.value;
            input -= (firms[msg.sender].allowance-firms[msg.sender].used)*cheapPrice;
            uint maxCheap = firms[msg.sender].allowance-firms[msg.sender].used;
            firms[msg.sender].balance += maxCheap;
            firms[msg.sender].used += maxCheap;
            circulation += maxCheap;

            uint creditsBoughtExp = input / expensivePrice;

            firms[msg.sender].balance += creditsBoughtExp;
            firms[msg.sender].used += creditsBoughtExp;
            circulation += creditsBoughtExp;
            returnPrice = this.balance / circulation;

            ExpensiveCreditsBought(msg.sender, creditsBoughtExp+maxCheap);
        }
    }

    // Testing function.
    function defaultFirm() public {
        firms[msg.sender] = Firm("foo", 100, 0, 0);
    }

    function tradeCredits(address firm, uint amount) public {
        require(keccak256(firms[msg.sender].name) != 0);
        require(firms[msg.sender].balance >= amount);
        firms[msg.sender].balance -= amount;
        firms[firm].balance += amount;
    }
    function buyRenewable(address renew, uint amount) public {
        require(firms[msg.sender].balance >= amount || privats[msg.sender].balance >= amount);
        if (firms[msg.sender].balance >= amount) {
            firms[msg.sender].balance -= amount;
            greens[renew].balance += amount;
        } else {
            privats[msg.sender].balance -= amount;
            greens[renew].balance += amount;
        }

    }
}
