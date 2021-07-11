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
        uint256 _listingFee,
        uint8 _platformTax,
        string memory ethWallet,
        string memory bscWallet,
        string memory btcWallet
    ) external returns (bool);

    /**
     * @dev can change the listing features.
     */
    function updateParams(uint256 _proposalId, uint256 _listingFee, uint8 _platformTax, string memory ethWallet, string memory bscWallet, string memory btcWallet) external returns (bool);

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

     /**
     * @dev returns the listing fee of `_merchantAddress`
     */
    function listingFee(address _merchantAddress) external view returns (uint256);

    /**
     * @dev returns the listing fee of `_merchantAddress`
     */
    function platformTax(address _merchantAddress) external view returns (uint8);
}
