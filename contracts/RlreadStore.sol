pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

import "./Bookshelf.sol";

contract RlreadStore {

    struct Reader {
        address addr;
        bool enter;
        uint has_books;
    }

    //初始化卖家和书籍
    address internal seller;
    uint[] public books = [1,2,3,4,5,6,7,8];
    string  notEnterWarn = "you haven't entered this bookstore yet!";

    //用来保管用户买书的钱
    uint public lockAmount;

    //卖家可以取出的钱
    uint public unlockAmount;

    //记录用户买书的情况。
    Bookshelf public bookshelf;
    address[] public reader_addresses;
    //记录读者信息
    mapping(address => Reader) public Readers;
    mapping(uint => uint) public book_price;

    constructor() public {
        seller = msg.sender;
        InitailThePriceOfBooks();
    }

    function getSeller() public view returns (address) {
      require(msg.sender == seller);
      return seller;
    }

    function InitailThePriceOfBooks() internal {
        book_price[1] = 10000;
        book_price[2] = 20000;
        book_price[3] = 30000;
        book_price[4] = 30000;
        book_price[5] = 10000;
        book_price[6] = 20000;
        book_price[7] = 30000;
        book_price[8] = 30000;
    }

    function EnterBookshop() public {
        Readers[msg.sender].addr = msg.sender;
        Readers[msg.sender].enter = true;
    }

    function LeaveBookshop() public {
        Readers[msg.sender].enter = false;
    }

    function ListBooks() public view returns (uint[]) {
        // if (!Readers[msg.sender].enter) {
        //     revert(notEnterWarn);
        // }
        require(msg.sender == seller || Readers[msg.sender].enter, notEnterWarn);
        return books;
    }

    function getBooksoldCount() public view returns (uint) {
      require(msg.sender == seller);
      return reader_addresses.length;
    }

    function GetThePriceofTheBook(uint bookId) public view returns (uint) {
        require(msg.sender == seller || Readers[msg.sender].enter, notEnterWarn);
        return book_price[bookId];
    }

    /* 100: "Boss, the books are all yours."
       200: "You have bought this book successfully!
    */
    function BuyTheBook(uint bookId) public payable returns (uint)  {
        if (msg.sender == seller)
            return 100;
        lockAmount += msg.value;
        bookshelf.putAbookIn(seller, msg.sender, bookId);
        Readers[msg.sender].has_books = bookId;
        reader_addresses.push(msg.sender);
        return 200;
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
        Readers[reader_addresses[length - 1]].has_books = 0;
        delete reader_addresses[length - 1];
        reader_addresses.length--;
    }

    function calculateTheMoneyReaderCanGet(uint mostKeepDays, uint bookId) internal view returns (uint) {
        return mostKeepDays * book_price[bookId] / 80;
    }

    /* 101: "The days spent in this book is less than 80 days so that you can't get the money."
       200: "you have taken some money back based on your most keeping days to read this book!"
    */
    function ReaderGetMoney(uint bookId) public returns (uint) {
        require(Readers[msg.sender].enter, notEnterWarn);
        require(msg.sender != seller, "Boss, you are the seller not the reader.");
        if (bookshelf.GetAlldaysSpent(msg.sender) < 80) {
            return 101;
        } else if (bookshelf.BeCheckedOrNot(msg.sender)) {
            uint money = bookshelf.CheckTheMoneyNowCanGet(msg.sender);
            msg.sender.transfer(money);
            lockAmount -= money;
        } else {
            uint mostKeepDays = bookshelf.GetTheMostKeepDays(msg.sender);
            uint moneyReaderCanGet = calculateTheMoneyReaderCanGet(mostKeepDays, bookId);
            msg.sender.transfer(moneyReaderCanGet);
            unlockAmount += book_price[bookId] - moneyReaderCanGet;
            lockAmount -= book_price[bookId];
        }
        //删除用户
        bookshelf.clearbookOfReader(seller, msg.sender);
        deleteReaderByAddress(msg.sender);
        return 200;
    }

    function SellerGetMoney() public returns (uint) {
        require(msg.sender == seller, "You don't have the right to do that.");
        for (uint i = 0; i < reader_addresses.length; ++i) {
            if (bookshelf.GetAlldaysSpent(reader_addresses[i]) == 80) {
                uint mostKeepDays = bookshelf.GetTheMostKeepDays(reader_addresses[i]);
                uint bookId = bookshelf.GetOwnBookName(reader_addresses[i]);
                uint moneyReaderCanGet = calculateTheMoneyReaderCanGet(mostKeepDays, bookId);
                bookshelf.CheckTheShelf(seller, reader_addresses[i], moneyReaderCanGet);
                unlockAmount += book_price[bookId] - moneyReaderCanGet;
                lockAmount -= book_price[bookId] - moneyReaderCanGet;
            }
        }
        uint get = unlockAmount;
        seller.transfer(unlockAmount);
        unlockAmount = 0;
        return get;
    }

}
