// SPDX-License-Identifier: ISC

pragma solidity ^0.8.4;

interface ITopTime {
    /**
     * @dev creates an top time based auction for a specific NFT tokenId.
     *
     * Requirement:
     *
     * `_tokenId` represents the NFT token Id to be solved.
     * `_tokenId` should be approved to be spent by the Marketplace SC.
     *
     * `_endsAt` represents the duration of auction from start date represented in seconds.
     * `_price` represents the price in BTC 8-decimal precision.
     *
     * @return bool representing the status of the creation of sale.
     */

    function createAuction(
        uint256 _tokenId,
        uint256 _endsAt,
        uint256 _price
    ) external payable returns (bool);

    /**
     * @dev allows users to bid the auction for a specific NFT.
     * using tokens.
     *
     * Requirement:
     * `_auctionId` representing the auction the user is bidding.
     * `_currency` the ticker of the token the user is using for payments.
     *
     * @return bool representing the status of the bid.
     */
    function bidAuction(uint256 _auctionId, string memory _currency, uint256 _amount) external returns (bool);

    /**
     * @dev releases the auction token to the highest bidder.
     *
     * `_auctionId` is the identifier of the auction you wisg to settle the tokens.
     *
     * @return bool representing the status of the transaction.
     */
    function releaseAuctionToken(uint256 _auctionId) external returns (bool);

    /**
     * @dev calim the auction token if you're the highest bidder.
     *
     * `_auctionId` is the identifier of the auction you wisg to settle the tokens.
     *
     * @return bool representing the status of the transaction.
     */
    function claimAuctionToken(uint256 _auctionId, string memory _hash) external returns (bool);
}