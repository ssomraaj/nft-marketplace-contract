// SPDX-License-Identifier: ISC

pragma solidity ^0.8.4;

import "./IBEP1155.sol";

/**
 * @dev Interface of the optional BEP1155MetadataExtension interface, as defined
 *
 */
interface IBEP1155MetadataURI is IBEP1155 {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
}
