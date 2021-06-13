// SPDX-License-Identifier: ISC

pragma solidity ^0.8.4;

interface IAuction {
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
    ) external returns (bool);

    /**
     * @dev allows users to bid the auction for a specific NFT.
     *
     * Requirement:
     * `_auctionId` representing the auction the user is bidding.
     * `_currency` the ticker of the token the user is using for payments.
     *
     * @return bool representing the status of the bid.
     */
    function bidAuction(uint256 _auctionId, string memory _currency, uint256 _amount) external returns (bool);
}