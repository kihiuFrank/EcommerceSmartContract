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

    //errors
    error Ecommerce__PriceMustBeGreater0();
    error Ecommerce__PriceNotMet();
    error Ecommerce__SellerCannotBeBuyer();

    // events
    event Registered(string title, uint productId, address seller);
    event Bought(uint productId, address buyer);
    event Delivered(uint productId);

    constructor() {}

    function registerProduct(
        string memory _title,
        string memory _description,
        uint _price
    ) public {
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

    function buy(uint _productId) public payable {
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

    function delivery(uint _productId) public {
        require(
            products[_productId - 1].buyer == msg.sender,
            "only the buyer can call this fuction"
        );
        products[_productId - 1].delivered = true;
        products[_productId - 1].seller.transfer(
            products[_productId - 1].price // we can charge a fee for the buyer's using our platform at this point eg. (price * 98%)
        );

        emit Delivered(_productId);
    }
}
