//SPDX-License-Identifier: ISC 

pragma solidity ^0.8.4;

import "./interfaces/IDAO.sol";
import "./utils/Context.sol";
import "./interfaces/IBEP20.sol";

contract DAO is Context, IDAO{
    struct Proposal{
      bytes hash;
      address merchant;
      uint256 votes;
      bool approved;
    }
    
    address private _token;

    uint256 private _merchantsCount;
    uint256 private _proposalsCount;

    mapping(address => bool) private _merchant;
    mapping(uint256 => Proposal) private _proposal;

    constructor(address _tokenContract) {
        _token = _tokenContract;
    }

    function createMerchant(string memory hash) public virtual override returns (bool) {
        _proposalsCount += 1;

        _proposal[_proposalsCount] = Proposal(
            bytes(hash),
            _msgSender(),
            0,
            false
        );
        return true;
    }    

    function vote(uint256 proposalId) public virtual override returns (bool) {
        uint256 balance = IBEP20(_token).balanceOf(_msgSender());
        uint256 totalSupply = IBEP20(_token).totalSupply();

        require(balance > 0, "Error: Voter should have ZNFT Shares");
        require(proposalId > 0 && proposalId <= _proposalsCount, "Error: Invalid Proposal ID");

        Proposal storage p = _proposal[proposalId];
        require(!p.approved, "Error: Proposal already approved");

        p.votes += balance;
        if(p.votes > totalSupply / 2) {
            p.approved = true;
            _merchantsCount += 1;
            _merchant[p.merchant] = true;
        }
        return true;
    }

    function isMerchant(address _merchantAddress) public virtual view returns (bool) {
        return _merchant[_merchantAddress];
    }

    function totalProposals() public virtual view returns (uint256) {
        return _proposalsCount;
    }

    function totalMerchants() public virtual view returns (uint256) {
        return _merchantsCount;
    }

    function proposal(uint256 proposalId) public virtual view returns (string memory hash, address merchant, uint256 totalVotes, bool approved) {
        require(proposalId > 0 && proposalId <= _proposalsCount, "Error: Invalid Proposal ID");

        Proposal storage p = _proposal[proposalId];
        return(
          string(p.hash),
          p.merchant,
          p.votes,
          p.approved
        );
    }
}