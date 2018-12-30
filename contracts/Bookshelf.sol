pragma solidity ^0.4.24;

contract Bookshelf {
    struct Reader {
        uint bookId;
        bool hasBook;
        uint nowKeepingDays;
        uint mostKeepingDays;
        uint spendDays;
        bool sellerCheck;
        uint getMoney;
        uint beginTime;
        uint lastReadTime;
        uint paragraph;
    }

    mapping(address => Reader) public Readers;
    address internal owner;


    string RightWarn = "This bookshelf is not yours that you have no right to do that";
    string NoBookWarn = "You don't have a book.";

    constructor() public {
        owner = msg.sender;
    }

    function putAbookIn(address own, address reader, uint bookId) public {
        require(owner == own, RightWarn);
        Readers[reader].bookId = bookId;
        Readers[reader].nowKeepingDays = 0;
        Readers[reader].hasBook = true;
        Readers[reader].mostKeepingDays = 0;
        Readers[reader].spendDays = 0;
        Readers[reader].getMoney = 0;
        Readers[reader].beginTime = now;
        Readers[reader].lastReadTime = now;
        Readers[reader].paragraph = 1;
    }

    function clearbookOfReader(address own, address reader) public {
        require(owner == own, RightWarn);
        delete Readers[reader];
    }

    function Reading(address reader) public returns (uint) {
        require(Readers[reader].hasBook, NoBookWarn);
        Readers[reader].spendDays = (now - Readers[reader].beginTime) / 86400 + 1;
        if (Readers[reader].spendDays == 1) {
            Readers[reader].mostKeepingDays = 1;
            Readers[reader].nowKeepingDays = 1;
        }
        uint interval = (now - Readers[reader].lastReadTime) / 86400;
        if (interval < 1) {
            return Readers[reader].paragraph;
        } else if (interval < 2) {
            Readers[reader].nowKeepingDays += 1;
            if (Readers[reader].nowKeepingDays > Readers[reader].mostKeepingDays) {
                Readers[reader].mostKeepingDays = Readers[reader].nowKeepingDays;
            }
        } else {
            Readers[reader].nowKeepingDays = 1;
        }
        Readers[reader].lastReadTime = now;
        Readers[reader].paragraph += 1;
        return Readers[reader].paragraph;
    }

    function GetOwnBookName(address reader) public view returns (uint) {
        require(Readers[reader].hasBook, NoBookWarn);
        return Readers[reader].bookId;
    }

    function GetTheNowKeepDays(address reader) public view returns (uint) {
        return GetTheDays(reader, 0);
    }

    function GetTheMostKeepDays(address reader) public view returns (uint) {
        return GetTheDays(reader, 1);
    }

    function GetAlldaysSpent(address reader) public returns (uint) {
        require(Readers[reader].hasBook, NoBookWarn);
        Readers[reader].spendDays = (now - Readers[reader].beginTime) / 86400 + 1;
        return GetTheDays(reader, 2);
    }

    function GetTheDays(address reader, uint dayType) internal view returns (uint) {
        require(Readers[reader].hasBook, NoBookWarn);
        if (dayType == 2) {
            return Readers[reader].spendDays;
        } else if (dayType == 1) {
            return Readers[reader].mostKeepingDays;
        } else {
            return Readers[reader].nowKeepingDays;
        }
    }

    function CheckTheShelf(address own, address reader, uint money) public {
        require(owner == own, RightWarn);
        Readers[reader].sellerCheck = true;
        Readers[reader].getMoney = money;
    }

    function BeCheckedOrNot(address reader) public view returns (bool) {
        require(Readers[reader].hasBook, NoBookWarn);
        return Readers[reader].sellerCheck;
    }

    function CheckTheMoneyNowCanGet(address reader) public view returns (uint) {
        require(Readers[reader].hasBook, NoBookWarn);
        return Readers[reader].getMoney;
    }
}
