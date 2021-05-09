// SPDX-License-Identifier: ISC

pragma solidity ^0.8.4;

import "./interfaces/IBEP165.sol";

contract BEP165 is IBEP165 {
    /**
     * @dev See {IBEP165-supportsInterface} 
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IBEP165).interfaceId;
    }
}
