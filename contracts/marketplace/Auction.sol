// SPDX-License-Identifier: ISC

pragma solidity ^0.8.4;

import "./interfaces/IAuction.sol";
import "../payments/ProcessPayments.sol";
import "../security/ReentrancyGuard.sol";
import "../token/interfaces/IBEP721Receiver.sol";
import "../token/interfaces/IBEP721.sol";

contract Auction is
    IAuction,
    ProcessPayments,
    ReentrancyGuard,
    IBEP721Receiver
{
    address public nftContract;

    // enumerator to represent the sale status.
    enum AuctionStatus {ENDED, LIVE, COMPLETED, FAILED}

    // represents the total auctions created
    uint256 private _auctions;

    struct AuctionInfo {
        uint256 tokenId;
        uint256 askingPrice;
        uint256 currentPrice;
        address winner;
        AuctionStatus status;
        uint256 endsAt;
        uint256 createdAt;
        uint256 modifiedAt;
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
            "Marketplace Error: token not approved for sale"
        );
        _;
    }

    /**
     * @dev creates an auction for a specific NFT tokenId.
     *
     * Requirement:
     *
     * `_tokenId` represents the NFT token Id to be solved.
     * `_tokenId` should be approved to be spent by the Marketplace SC.
     *
     * `_endsAt` represents the duration of auction from start date represented in seconds.
     * `_price` represents the price in USD 8-decimal precision.
     *
     * @return bool representing the status of the creation of sale.
     */

    function createAuction(
        uint256 _tokenId,
        uint256 _endsAt,
        uint256 _price
    ) public virtual override Approved(_tokenId) returns (bool) {
        _auctions += 1;
        _auction[_auctions] = AuctionInfo(
            _tokenId,
            _price,
            _price,
            address(0),
            AuctionStatus.LIVE,
            _endsAt,
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
     * @dev allows users to bid the auction for a specific NFT.
     *
     * Requirement:
     * `_auctionId` representing the auction the user is bidding.
     * `_currency` the ticker of the token the user is using for payments.
     * `_amount` representing the bid amount in USD 8-precision.
     */
    function bidAuction(uint256 _auctionId, string memory _currency, uint256 _amount) public virtual override returns (bool) {
        AuctionInfo storage a = _auction[_auctionId];
        require(a.endsAt >= block.timestamp, "Auction Error: auction already ended");
        require(a.status != AuctionStatus.COMPLETED, "Auction Error: auction already ended");
        require(a.currentPrice < _amount, "Auction Error: bid with a higher value");

        return true;
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
