// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Ecommerce {
    // properties of a product
    struct Product {
        string title;
        string description;
        uint price;
        uint productId;
        address payable seller;
        address buyer;
        bool delivered;
    }

    Product[] public products;
    uint counter = 1;
    address payable public manager;
    bool isDestroyed = false;

    //errors
    error Ecommerce__PriceMustBeGreater0();
    error Ecommerce__PriceNotMet();
    error Ecommerce__SellerCannotBeBuyer();
    error Ecommerce__NotBuyer();
    error Ecommerce__NotManager();

    // events
    event Registered(string title, uint productId, address seller);
    event Bought(uint productId, address buyer);
    event Delivered(uint productId);

    modifier isNotDestroyed() {
        require(!isDestroyed, "Contract does not exist");
        _;
    }

    constructor() {
        manager = payable(msg.sender);
    }

    function registerProduct(
        string memory _title,
        string memory _description,
        uint _price
    ) public isNotDestroyed {
        //require(_price > 0, "Price has to be greater than 0!");
        if (_price <= 0) {
            revert Ecommerce__PriceMustBeGreater0();
        }

        Product memory tempProduct;
        tempProduct.title = _title;
        tempProduct.description = _description;
        tempProduct.price = _price;
        tempProduct.seller = payable(msg.sender);
        tempProduct.productId = counter;
        products.push(tempProduct);
        counter++;

        //products[tempProduct.productId - 1].seller = payable(msg.sender);

        emit Registered(_title, tempProduct.productId, msg.sender);
    }

    function buy(uint _productId) public payable isNotDestroyed {
        /* require(
            products[_productId - 1].price == msg.value,
            "Please pay the exact price"
        ); */

        if (products[_productId - 1].price != msg.value) {
            revert Ecommerce__PriceNotMet();
        }

        /* require(
            products[_productId - 1].seller != msg.sender,
            "You can't buy your own products!"
        ); */

        if (products[_productId - 1].seller == msg.sender) {
            revert Ecommerce__SellerCannotBeBuyer();
        }
        products[_productId - 1].buyer = msg.sender;

        emit Bought(_productId, msg.sender);
    }

    function delivery(uint _productId) public isNotDestroyed {
        /* require(
            products[_productId - 1].buyer == msg.sender,
            "only the buyer can call this fuction"
        ); */

        if (products[_productId - 1].buyer != msg.sender) {
            revert Ecommerce__NotBuyer();
        }

        products[_productId - 1].delivered = true;
        products[_productId - 1].seller.transfer(
            products[_productId - 1].price // we can charge a fee for the buyer's using our platform at this point eg. (price * 98%)
        );

        emit Delivered(_productId);
    }

    /* function destroy() public {
        // require(manager == msg.sender, "Only manager can call this fuction");
        if (manager != msg.sender) {
            revert Ecommerce__NotManager();
        }
        selfdestruct(manager);
    } */

    // solution 1 to avoid users losing money due to sending money to a destroyed contract
    function destroy() public isNotDestroyed {
        // require(manager == msg.sender, "Only manager can call this fuction");
        if (manager != msg.sender) {
            revert Ecommerce__NotManager();
        }
        manager.transfer(address(this).balance);
        // now destroy
        isDestroyed = true;
        selfdestruct(manager);
    }

    // solution 2
    fallback() external payable {
        //we send the ether back to their account since the contract is destroyed
        payable(msg.sender).transfer(msg.value);
    }

    receive() external payable {
        payable(msg.sender).transfer(msg.value);
    }

    //////////////////
    // Getter Functions
    //////////////////
    function getBalance(address seller) external view returns (uint256) {
        return seller.balance;
    }
}
