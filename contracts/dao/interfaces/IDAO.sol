//SPDX-License-Identifier: ISC

pragma solidity ^0.8.4;

interface IDAO {
    /**
     * @dev receives the listing for adding new merchants to the marketplace.
     *
     *`hash` is the ipfs hash of the company-info JSON. To reduce gas usuage we're following this approach.
     */
    function createMerchant(
        string memory hash,
        uint256 listingFee,
        uint8 platformTax
    ) external returns (bool);

    /**
     * @dev vote for the approval of merchants.
     *
     * `proposalId` will be the listing Id of the proposal.
     */
    function vote(uint256 proposalId) external returns (bool);

    /**
     * @dev returns if an address is a valid `merchant`
     */
    function isMerchant(address _merchantAddress) external view returns (bool);
}
