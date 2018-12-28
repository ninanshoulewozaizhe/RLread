pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

import "./Bookshelf.sol";

contract RlreadStore {

    struct Reader {
        address addr;
        bool enter;
        bool has_books;
    }

    //初始化卖家和书籍
    address internal seller;
    string[] books = ["Harry Potter", "Island", "The shadow thief", "The Kite Runner"];
    string  notEnterWarn = "you haven't entered this bookstore yet!";

    //用来保管用户买书的钱
    uint internal lockAmount;

    //卖家可以取出的钱
    uint internal unlockAmount;

    //记录用户买书的情况。
    Bookshelf internal bookshelf;
    address[] reader_addresses;
    //记录读者信息
    mapping(address => Reader) Readers;
    mapping(string => uint) book_price;

    constructor() public {
        seller = msg.sender;
        InitailThePriceOfBooks();
    }

    function getSeller() public view returns (address) {
      require(msg.sender == seller);
      return seller;
    }

    function InitailThePriceOfBooks() internal {
        book_price["Harry Potter"] = 10000;
        book_price["Island"] = 20000;
        book_price["The shadow thief"] = 30000;
        book_price["The Kite Runner"] = 30000;
    }

    function EnterBookshop() public {
        Readers[msg.sender].enter = true;
    }

    function LeaveBookshop() public {
        Readers[msg.sender].enter = false;
    }

    function ListBooks() public view returns (string[]) {
        // if (!Readers[msg.sender].enter) {
        //     revert(notEnterWarn);
        // }
        require(msg.sender == seller || Readers[msg.sender].enter, notEnterWarn);
        return books;
    }

    function GetThePriceofTheBook(string bookname) public view returns (uint) {
        require(msg.sender == seller || Readers[msg.sender].enter, notEnterWarn);
        return book_price[bookname];
    }

    function BuyTheBook(string bookname) public payable returns (string)  {
        if (msg.sender == seller)
            return "Boss, the books are all yours.";
        require(Readers[msg.sender].enter, notEnterWarn);
        require(!Readers[msg.sender].has_books, "You have a book already.");
        require(msg.value == book_price[bookname], "The money you pay is not equal to the price of the book.");
        lockAmount += msg.value;
        bookshelf.putAbookIn(seller, msg.sender, bookname);
        reader_addresses.push(msg.sender);
        return "You have bought this book successfully!";
    }

    function SetBookshelf(Bookshelf _bookshelf) public {
        require(msg.sender == seller, "You don't have the right to do that");
        bookshelf = _bookshelf;
    }

    function deleteReaderByAddress(address reader) internal {
        uint i = 0;
        uint length = reader_addresses.length;
        for ( ; i < length; ++i) {
            if (reader_addresses[i] == reader)
                break;
        }
        for ( ; i < length - 1; ++i) {
            reader_addresses[i] = reader_addresses[i + 1];
        }
        delete reader_addresses[length - 1];
        reader_addresses.length--;
    }

    function calculateTheMoneyReaderCanGet(uint mostKeepDays, string bookname) internal view returns (uint) {
        return mostKeepDays * book_price[bookname] / 80;
    }

    function ReaderGetMoney(string bookname) public returns (string) {
        require(Readers[msg.sender].enter, notEnterWarn);
        require(msg.sender != seller, "Boss, you are the seller not the reader.");
        if (bookshelf.GetAlldaysSpent(msg.sender) < 80) {
            return "The days spent in this book is less than 80 days so that you can't get the money.";
        } else if (bookshelf.BeCheckedOrNot(msg.sender)) {
            uint money = bookshelf.CheckTheMoneyNowCanGet(msg.sender);
            msg.sender.transfer(money);
            lockAmount -= money;
        } else {
            uint mostKeepDays = bookshelf.GetTheMostKeepDays(msg.sender);
            uint moneyReaderCanGet = calculateTheMoneyReaderCanGet(mostKeepDays, bookname);
            msg.sender.transfer(moneyReaderCanGet);
            unlockAmount += book_price[bookname] - moneyReaderCanGet;
            lockAmount -= book_price[bookname];
        }
        //删除用户
        bookshelf.clearbookOfReader(seller, msg.sender);
        deleteReaderByAddress(msg.sender);
        return "you have taken some money back based on your most keeping days to read this book!";
    }

    function SellerGetMoney() public returns (string) {
        require(msg.sender == seller, "You don't have the right to do that.");
        for (uint i = 0; i < reader_addresses.length; ++i) {
            if (bookshelf.GetAlldaysSpent(reader_addresses[i]) == 80) {
                uint mostKeepDays = bookshelf.GetTheMostKeepDays(reader_addresses[i]);
                string memory bookname = bookshelf.GetOwnBookName(reader_addresses[i]);
                uint moneyReaderCanGet = calculateTheMoneyReaderCanGet(mostKeepDays, bookname);
                bookshelf.CheckTheShelf(seller, reader_addresses[i], moneyReaderCanGet);
                unlockAmount += book_price[bookname] - moneyReaderCanGet;
                lockAmount -= book_price[bookname] - moneyReaderCanGet;
            }
        }
        seller.transfer(unlockAmount);
        unlockAmount = 0;
        return "You have got all the money you can get now.";

    }

}
