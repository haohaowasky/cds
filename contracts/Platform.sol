pragma solidity ^0.4.4;

import './OTC.sol';

contract Platform{
    OTC.book book;
    struct swap{
        address writer;
        address buyer;
        uint8 spread;
        uint8 status; // 0 for pre, 1 for open , 2 for executed;
    }


    address public admin ;
    mapping (address => swap) public swapbook;
    address[] public swaps;


    function Platform() {
        admin = msg.sender;
    }
    // recovery rate
    // Discounted Factor

    function registration() payable returns(bool){
        uint regiscapital;
        address paticipants;
        regiscapital = msg.value;
        paticipants = msg.sender;
        if(OTC.addMember(book, paticipants,regiscapital) == false){
            revert();
        }
        else{
            return true;
        }
    }


    function createCDS(uint8 Recovery, uint8 Df, uint8 Probability, uint8 maturity )returns(bool){
        if(OTC.checkMember(book, msg.sender) != true){  // if not registed, cannot write contract
            return false;
        }
        uint8 spread;
        spread = 100 + Recovery; // for now use this, it will be a math function in the future, or client will do the calculation.
        if(OTC.checkMargin(book, msg.sender, spread ) != true){
            return false;
        }
        CreditDefaultSwap theswap = new CreditDefaultSwap (Recovery, Df, Probability, maturity, spread );
        swapbook[theswap].writer = msg.sender; // who writes the contract
        swapbook[theswap].status = 0;
        swapbook[theswap].spread = spread;
        swaps.push(theswap);
        return true;
    }

    function monitor() returns(address[]){
        return swaps;
    }


    function buyCDS(address order) returns(bool){
        if(OTC.checkMember(book, msg.sender) != true){  // if not registed, cannot write contract
            return false;
        }

        if(OTC.checkMargin(book, msg.sender, swapbook[order].spread ) != true){ // if you dont have money you can't buy this
            return false;
        }
        swapbook[order].buyer = msg.sender;
        return true;
    }

    function pay(address order) returns(bool){
        OTC.spending(book, msg.sender, swapbook[order].spread);
        OTC.addMargin(book, swapbook[order].writer, swapbook[order].spread);
        CreditDefaultSwap con = CreditDefaultSwap(order);
        if(con.annualpay()){
            return true;
        }
        else{
            return false;
        }
    }

    function getAdmin() returns(address){
            return admin;
    }


    function getBalance() returns(uint){
       return OTC.check(book, msg.sender);

    }

    function addMoney() payable returns(bool){
        OTC.addMargin(book, msg.sender, msg.value);
    }
}





// the contrct itself does not hold value, a netting will be done later.
contract CreditDefaultSwap{
    uint8 public recr;
    uint8 public df;
    uint8 public probability;
    uint8 public maturity; // times of payments
    uint8 public spread;
    address key;

    function CreditDefaultSwap(uint8 _revovery, uint8 _df, uint8 _probability, uint8 _maturity, uint8 _spread){
        key = msg.sender;
        recr = _revovery;
        df = _df;
        probability = _probability;
        maturity = _maturity;
        spread = _spread;
    }

    function annualpay() returns(bool){
        if(key != msg.sender){
            return false;
    }
        else{ // add check it is the right amount
            maturity -= 1;
            return true;
        }
    }
    function balance() returns(uint8){
        return maturity;
    }


}
