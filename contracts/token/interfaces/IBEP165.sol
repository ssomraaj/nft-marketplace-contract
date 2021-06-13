// SPDX-License-Identifier: ISC

pragma solidity ^0.8.4;

/**
 * @dev implements the IBEP165 interface according
 * to EIP standards.
 *
 * For implementation see {BEP165}
 */

interface IBEP165 {
    /**
     * @dev returns true if this contracts implements the
     * interface defined by `interfaceId`.
     *
     * Must use less than 30,000 GAS.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
