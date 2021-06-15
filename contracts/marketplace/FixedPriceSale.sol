// SPDX-License-Identifier: ISC

pragma solidity ^0.8.4;

import "./interfaces/IFixedPriceSale.sol";
import "../payments/ProcessPayments.sol";
import "../security/ReentrancyGuard.sol";
import "../token/interfaces/IBEP721Receiver.sol";
import "../token/interfaces/IBEP721.sol";

/**
 * The Implmenetation of `IMarketplace`
 */

contract FixedPriceSale is
    IFixedPriceSale,
    ProcessPayments,
    ReentrancyGuard,
    IBEP721Receiver
{
    // ZNFT token Contract
    address public nftContract;

    // enumerator to represent the sale status.
    enum SaleStatus {COMPLETED, ONGOING, FAILED}

    // represents the total sales created.
    uint256 private _sales;

    modifier Approved(uint256 tokenId) {
        require(
            IBEP721(nftContract).getApproved(tokenId) == address(this) ||
                IBEP721(nftContract).isApprovedForAll(
                    _msgSender(),
                    address(this)
                ),
            "Marketplace Error: token not approved for sale"
        );
        _;
    }

    struct Sale {
        uint256 tokenId;
        uint256 price;
        address creator;
        SaleStatus status;
        uint256 createdAt;
        uint256 modifiedAt;
    }

    struct Buyer {
        bytes method;
        uint256 amount;
        uint256 boughtAt;
    }

    mapping(uint256 => Sale) private _sale;
    mapping(uint256 => Buyer) private _buyer;

    /**
     * @dev initializes the ProcessPayments Child SC inside Marketplace
     *
     * Payments in marketplace is handled by process payments SC
     */
    constructor() ProcessPayments() {}

    /**
     * @dev creates a sale for a specific NFT tokenId.
     *
     * Requirement:
     *
     * `_tokenId` represents the NFT token Id to be solved.
     * `_tokenId` should be approved to be spent by the Marketplace SC.
     *
     * `_price` represents the price in USD 8-decimal precision.
     *
     * @return bool representing the status of the creation of sale.
     */

    function createSale(uint256 _tokenId, uint256 _price)
        public
        virtual
        override
        Approved(_tokenId)
        nonReentrant
        returns (bool)
    {
        _sales += 1;

        _sale[_sales] = Sale(
            _tokenId,
            _price,
            _msgSender(),
            SaleStatus.ONGOING,
            block.timestamp,
            block.timestamp
        );
        IBEP721(nftContract).safeTransferFrom(
            _msgSender(),
            address(this),
            _tokenId
        );

        return true;
    }

    /**
     * @dev buy sale with a valid acceptable asset.
     *
     * Requirements:
     *
     * `_saleId` represents the identifier for each sale.
     * `_currency` represents the TICKER of the currency.
     * Eg., BTC for bitcoin.
     * @return bool representing the status of purchase.
     */
    function buySaleWithTokens(uint256 _saleId, string memory _currency)
        public
        virtual
        override
        nonReentrant
        returns (bool)
    {
        Sale storage s = _sale[_saleId];
        require(
            s.status == SaleStatus.ONGOING,
            "Marketplace Error: sale not active"
        );
        s.modifiedAt = block.timestamp;
        s.status = SaleStatus.COMPLETED;
        (bool status, uint256 tokens) = tPayment(_currency, s.price);
        settle(_currency, tokens, s.creator);
        _buyer[_saleId] = Buyer(bytes(_currency), tokens, block.timestamp);
        return status;
    }

    /**
     * @dev buy sale with a valid acceptable asset.
     *
     * Requirements:
     *
     * `_saleId` represents the identifier for each sale.
     * `_currency` represents the TICKER of the currency.
     * Eg., BTC for bitcoin.
     * @return bool representing the status of purchase.
     */
    function buySaleWithStableCoins(uint256 _saleId, string memory _currency)
        public
        virtual
        override
        returns (bool)
    {
        Sale storage s = _sale[_saleId];
        require(
            s.status == SaleStatus.ONGOING,
            "Marketplace Error: sale not active"
        );
        s.modifiedAt = block.timestamp;
        s.status = SaleStatus.COMPLETED;
        (bool status, uint256 tokens) = sPayment(_currency, s.price);
        settle(_currency, tokens, s.creator);
        _buyer[_saleId] = Buyer(bytes(_currency), tokens, block.timestamp);
        return status;
    }

    /**
     * To make sure marketplace smart contract supports BEP721.
     *
     * @return a bytes4 interface Id for the marketplace SC.
     */
    function onBEP721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) external pure override returns (bytes4) {
        _operator;
        _from;
        _tokenId;
        _data;
        return 0x150b7a02;
    }
}
