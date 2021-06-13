// SPDX-License-Identifier: ISC

pragma solidity ^0.8.4;

/**
 * Features of Marketplace.
 */

interface IFixedPriceSale {
 
 /**
  * @dev creates a sale for a specific NFT tokenId.
  * Sale ends when someone pays the asking price and it is not ended by time. Runs indefinitely.
  * 
  * Requirement:
  * 
  * `tokenId` represents the NFT token Id to be solved.
  * `tokenId` should be approved to be spent by the Marketplace SC.
  *
  * `price` represents the price in USD 8-decimal precision.
  * 
  * @return bool representing the status of the creation of sale.
  */
  function createSale(uint256 tokenId, uint256 price) external returns (bool);

   /**
     * @dev buy sale with a valid acceptable asset (Tokens Not Stablecoins).
     *
     * Requirements:
     * 
     * `_saleId` represents the identifier for each sale.
     * `_currency` represents the TICKER of the currency. 
     * Eg., BTC for bitcoin.
     */
    function buySaleWithTokens(uint256 _saleId, string memory _currency) external returns (bool);


    /**
     * @dev buy sale with a valid acceptable stablecoin.
     *
     * Requirements:
     * 
     * `_saleId` represents the identifier for each sale.
     * `_currency` represents the TICKER of the currency. 
     * Eg., BTC for bitcoin.
     */
    function buySaleWithStableCoins(uint256 _saleId, string memory _currency) external returns (bool);
  
}