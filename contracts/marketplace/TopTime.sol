// SPDX-License-Identifier: ISC

pragma solidity ^0.8.4;

import "./interfaces/ITopTime.sol";
import "../payments/ProcessPayments.sol";
import "../security/ReentrancyGuard.sol";
import "../token/interfaces/IBEP721Receiver.sol";
import "../token/interfaces/IBEP721.sol";
import "../dao/interfaces/IDAO.sol";

contract TopTime is
    ITopTime,
    ProcessPayments,
    ReentrancyGuard,
    IBEP721Receiver
{
    address public nftContract;
    address public daoContract;

    // enumerator to represent the sale status.
    enum AuctionStatus {ENDED, LIVE, COMPLETED, FAILED}

    // represents the total auctions created
    uint256 private _auctions;

    struct AuctionInfo {
        uint256 tokenId;
        uint256 askingPrice;
        uint256 currentPrice;
        uint256 amountPaid;
        bytes offChainHash;
        uint256 start;
        uint256 toptime;
        address creator;
        address winner;
        AuctionStatus status;
    }

    struct BidInfo {
        bytes currency;
        uint256 amount;
        uint256 createdAt;
    }

    mapping(uint256 => AuctionInfo) private _auction;
    mapping(address => mapping(uint256 => BidInfo)) private _bid;

    modifier Approved(uint256 _tokenId) {
        require(
            IBEP721(nftContract).getApproved(_tokenId) == address(this) ||
                IBEP721(nftContract).isApprovedForAll(
                    _msgSender(),
                    address(this)
                ),
            "TopTime Error: token not approved for sale"
        );
        _;
    }

    modifier Elligible() {
        require(
            IDAO(daoContract).isMerchant(_msgSender()),
            "TopTime Error: merchant not approved"
        );
        _;
    }

    event ListItem(
        uint256 tokenId,
        uint256 auctionId,
        address owner,
        uint256 price,
        uint256 toptime
    );
    event UpdateAuction(uint256 auctionId);
    event Bid(
        uint256 auctionId,
        string currency,
        uint256 bidValue,
        uint256 amountPaid
    );
    event Settle(uint256 auctionId);
    event UpdateHash(uint256 auctionId, string hash);

    constructor(address _nft, address _dao) {
        nftContract = _nft;
        daoContract = _dao;
    }

    /**
     * @dev creates an auction for a specific NFT tokenId.
     *
     * Requirement:
     *
     * `_tokenId` represents the NFT token Id to be solved.
     * `_tokenId` should be approved to be spent by the TopTime SC.
     *
     * `_endsAt` represents the duration of auction from start date represented in seconds.
     * `_price` represents the price in BTC 8-decimal precision.
     *
     * @return bool representing the status of the creation of sale.
     */

    function createAuction(
        uint256 _tokenId,
        uint256 _toptime,
        uint256 _price
    )
        public
        payable
        virtual
        override
        Approved(_tokenId)
        Elligible
        returns (bool)
    {
        uint256 fee = listingFee();
        require(msg.value == fee, "TopTime Error: listing fee is not equal");

        _auctions += 1;
        _auction[_auctions] = AuctionInfo(
            _tokenId,
            _price,
            _price,
            0,
            bytes("0"),
            block.timestamp,
            _toptime,
            _msgSender(),
            address(0),
            AuctionStatus.LIVE
        );

        IBEP721(nftContract).safeTransferFrom(
            _msgSender(),
            address(this),
            _tokenId
        );
        payable(daoContract).transfer(msg.value);
        emit ListItem(_tokenId, _auctions, _msgSender(), _price, _toptime);
        return true;
    }

    function listingFee() public view returns (uint256) {
        return IDAO(daoContract).listingFee(_msgSender());
    }

    /**
     * @dev allows users to bid the auction for a specific NFT.
     *
     * Requirement:
     * `_auctionId` representing the auction the user is bidding.
     * `_currency` the ticker of the token the user is using for payments.
     * `_amount` representing the bid amount in BTC 8-precision.
     */
    function bidAuction(
        uint256 _auctionId,
        string memory _currency,
        uint256 _amount
    ) public virtual override nonReentrant returns (bool) {
        AuctionInfo storage a = _auction[_auctionId];
        BidInfo storage wBid = _bid[a.winner][_auctionId];

        uint256 time = block.timestamp - wBid.createdAt;
        require(time >= a.toptime, "TopTime Error: toptime already reached");
        require(
            a.currentPrice < _amount,
            "TopTime Error: bid with a higher value"
        );

        uint8 merchantTax = IDAO(daoContract).platformTax(a.creator);
        uint256 bidValue = (_amount * 100) / merchantTax;

        if (a.winner != address(0)) {
            BidInfo storage b = _bid[a.winner][_auctionId];
            settle(string(b.currency), b.amount, a.winner);
        }

        (bool status, uint256 tokens) = payment(_currency, _amount);
        _bid[_msgSender()][_auctionId] = BidInfo(
            bytes(_currency),
            tokens,
            block.timestamp
        );
        a.winner = _msgSender();
        a.currentPrice = bidValue;
        a.amountPaid = _amount;

        emit Bid(_auctionId, _currency, bidValue, _amount);
        return status;
    }

    /**
     * @dev releases the auction token to the highest bidder.
     *
     * `_auctionId` is the identifier of the auction you wisg to settle the tokens.
     *
     * @return bool representing the status of the transaction.
     */
    function releaseAuctionToken(uint256 _auctionId)
        public
        virtual
        override
        nonReentrant
        returns (bool)
    {
        AuctionInfo storage a = _auction[_auctionId];
        BidInfo storage wBid = _bid[a.winner][_auctionId];
        uint256 time = block.timestamp - wBid.createdAt;

        require(a.creator == _msgSender(), "TopTime Error: caller not creator");
        require(time >= a.toptime, "TopTime Error: toptime not ended");

        BidInfo storage b = _bid[a.winner][_auctionId];
        bool status = settle(string(b.currency), b.amount, a.creator);

        IBEP721(nftContract).transferFrom(address(this), a.winner, a.tokenId);

        emit Settle(_auctionId);
        return status;
    }

    /**
     * @dev can restart the auction with a new endtime.
     */
    function restartAuction(uint256 _auctionId)
        public
        virtual
        nonReentrant
        returns (bool)
    {
        AuctionInfo storage a = _auction[_auctionId];
        BidInfo storage wBid = _bid[a.winner][_auctionId];
        uint256 time = block.timestamp - wBid.createdAt;

        require(a.creator == _msgSender(), "TopTime Error: caller not creator");
        require(time >= a.toptime, "TopTime Error: toptime not ended");

        a.winner = address(0);
        a.currentPrice = 0;
        a.amountPaid = 0;
        a.offChainHash = bytes("0");

        a.start = block.timestamp;

        a.winner = address(0);
        a.status = AuctionStatus.LIVE;

        emit UpdateAuction(_auctionId);
        return true;
    }

    /**
     * @dev calim the auction token if you're the highest bidder.
     *
     * `_auctionId` is the identifier of the auction you wisg to settle the tokens.
     *
     * @return bool representing the status of the transaction.
     */
    function claimAuctionToken(uint256 _auctionId, string memory _hash)
        public
        virtual
        override
        nonReentrant
        returns (bool)
    {
        AuctionInfo storage a = _auction[_auctionId];
        BidInfo storage wBid = _bid[a.winner][_auctionId];
        uint256 time = block.timestamp - wBid.createdAt;

        require(a.winner == _msgSender(), "TopTime Error: caller not winner");
        require(time >= a.toptime, "TopTime Error: toptime not ended");

        a.offChainHash = bytes(_hash);

        emit UpdateHash(_auctionId, _hash);
        return true;
    }

    /**
     * @dev sets the NFT token smart contract.
     *
     * `_contractAddress` represents the BEP721 contract address.
     * `_contractAddress` cannot be a zero address.
     */
    function setNftContract(address _contractAddress)
        public
        virtual
        returns (bool)
    {
        require(
            _contractAddress != address(0),
            "Auction Error: cannot be zero address"
        );
        nftContract = _contractAddress;
        return true;
    }

    /**
     * @dev sets the DAO smart contract.
     *
     * `_contractAddress` represents the BEP721 contract address.
     * `_contractAddress` cannot be a zero address.
     */
    function setDAOContract(address _contractAddress)
        public
        virtual
        returns (bool)
    {
        require(
            _contractAddress != address(0),
            "Auction Error: cannot be zero address"
        );
        daoContract = _contractAddress;
        return true;
    }

    /**
     * @dev returns the information of every auction with auctionId.
     *
     * `auctionId` represents the Id of the auction you wish to query.
     */
    function auctionInfo(uint256 _auctionId)
        public
        view
        returns (AuctionInfo memory)
    {
        return _auction[_auctionId];
    }

    /**
     * @dev returns the information of every auction with auctionId.
     *
     * `auctionId` represents the Id of the auction you wish to query.
     */
    function bidInfo(address _user, uint256 _auctionId)
        public
        view
        returns (BidInfo memory)
    {
        return _bid[_user][_auctionId];
    }

    /**
     * To make sure TopTime smart contract supports BEP721.
     *
     * @return a bytes4 interface Id for the TopTime SC.
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
