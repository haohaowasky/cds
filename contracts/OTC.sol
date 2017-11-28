pragma solidity ^0.4.4;

library OTC {

    struct book{
        mapping (address => bool) members;
        mapping (address => uint) margin;
    }

    function addMember(book storage self, address addr, uint regisFund) returns(bool){
        if (self.members[addr]){
            return false; // alredy a member
        }

        self.members[addr] = true;
        self.margin[addr] = regisFund;
        return true;
    }

    function checkMember(book storage self, address addr) returns(bool){
        if(self.members[addr]){
            return true;
        }
        return false;
    }

    function delMember(book storage self, address addr) returns(bool){
        if (self.members[addr]){
            return false; // already a member
        }

        self.members[addr] = false;
        return true;
    }

    function checkMargin(book storage self, address addr, uint spread) returns(bool){
        if(self.margin[addr] < (3 * spread)){
            return false;
        }
        else{
            return true;
        }
    }

    function spending(book storage self, address addr, uint purchase) {
        self.margin[addr] -= purchase;
    }

    function addMargin(book storage self, address addr, uint deposit){
        self.margin[addr] += deposit;
    }

    function check(book storage self, address addr) returns(uint){
        return self.margin[addr];
    }

}
