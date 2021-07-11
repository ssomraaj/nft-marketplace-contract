//SPDX-License-Identifier: ISC

pragma solidity ^0.8.4;

import "./interfaces/IDAO.sol";
import "../utils/Context.sol";
import "../token/interfaces/IBEP20.sol";

contract DAO is Context, IDAO {
    struct Proposal {
        bytes hash;
        address merchant;
        uint8 platformTax;
        uint256 listingFee;
        uint256 votes;
        bool approved;
    }

    address private _token;
    address private _admin;

    uint256 private _merchantsCount;
    uint256 private _proposalsCount;

    mapping(address => bool) private _merchant;
    mapping(uint256 => Proposal) private _proposal;
    mapping(address => bool) private _listed;
    mapping(address => string) public ethWallet;
    mapping(address => string) public bscWallet;
    mapping(address => string) public btcWallet;
    mapping(address => uint256) public override listingFee;
    mapping(address => uint8) public override platformTax;

    event CreateMerchant(
        bytes hash,
        address merchant,
        uint256 listingFee,
        uint8 platformTax,
        uint256 proposalId
    );

    event Vote(uint256 proposalId, address voter, uint256 znftShares);

    modifier onlyOwner() {
        require(_msgSender() == _admin, "DAO Error: caller not admin");
        _;
    }

    constructor(address _tokenContract) {
        _token = _tokenContract;
        _admin = _msgSender();
    }

    function createMerchant(
        string memory hash,
        uint256 _listingFee,
        uint8 _platformTax,
        string memory _ethWallet,
        string memory _bscWallet,
        string memory _btcWallet
    ) public virtual override returns (bool) {
        require(!_listed[_msgSender()], "DAO Error: already proposed");
        require(
            _platformTax > 0 && _platformTax < 100,
            "DAO Error: invalid platform tax value"
        );
        _proposalsCount += 1;

        _proposal[_proposalsCount] = Proposal(
            bytes(hash),
            _msgSender(),
            _platformTax,
            _listingFee,
            0,
            false
        );
        emit CreateMerchant(
            bytes(hash),
            _msgSender(),
            _listingFee,
            _platformTax,
            _proposalsCount
        );
        _listed[_msgSender()] = true;
        ethWallet[_msgSender()] = _ethWallet;
        btcWallet[_msgSender()] = _btcWallet;
        bscWallet[_msgSender()] = _bscWallet;
        listingFee[_msgSender()] = _listingFee;
        platformTax[_msgSender()] = _platformTax;
        return true;
    }

    function updateParams(
        uint256 _proposalId,
        uint256 _listingFee,
        uint8 _platformTax,
        string memory _ethWallet,
        string memory _bscWallet,
        string memory _btcWallet
    ) public virtual override returns (bool) {
        Proposal storage p = _proposal[_proposalId];
        require(_listed[_msgSender()], "DAO Error: unregistered merchant");
        require(
            _platformTax > 0 && _platformTax < 100,
            "DAO Error: invalid platform tax value"
        );

        p.listingFee = _listingFee;
        p.platformTax = _platformTax;
        p.votes = 0;
        p.approved = false;

        emit CreateMerchant(
            bytes(p.hash),
            _msgSender(),
            _listingFee,
            _platformTax,
            _proposalId
        );
        ethWallet[_msgSender()] = _ethWallet;
        btcWallet[_msgSender()] = _btcWallet;
        bscWallet[_msgSender()] = _bscWallet;

        listingFee[_msgSender()] = _listingFee;
        platformTax[_msgSender()] = _platformTax;
        return true;
    }

    function vote(uint256 proposalId) public virtual override returns (bool) {
        uint256 balance = IBEP20(_token).balanceOf(_msgSender());
        uint256 totalSupply = IBEP20(_token).totalSupply();

        require(balance > 0, "Error: voter should have ZNFT Shares");
        require(
            proposalId > 0 && proposalId <= _proposalsCount,
            "Error: Invalid Proposal ID"
        );

        Proposal storage p = _proposal[proposalId];
        require(!p.approved, "Error: proposal already approved");

        p.votes += balance;
        if (p.votes > totalSupply / 2) {
            p.approved = true;
            _merchantsCount += 1;
            _merchant[p.merchant] = true;
        }
        emit Vote(proposalId, _msgSender(), balance);
        return true;
    }

    function updateTokenContract(address _newTokenContract)
        public
        virtual
        returns (bool)
    {
        require(
            _newTokenContract != address(0),
            "Error: New token contract can never be zero"
        );
        _token = _newTokenContract;
        return true;
    }

    function isMerchant(address _merchantAddress)
        public
        view
        virtual
        override
        returns (bool)
    {
        return _merchant[_merchantAddress];
    }

    function totalProposals() public view virtual returns (uint256) {
        return _proposalsCount;
    }

    function totalMerchants() public view virtual returns (uint256) {
        return _merchantsCount;
    }

    function proposal(uint256 proposalId)
        public
        view
        virtual
        returns (
            string memory hash,
            address merchant,
            uint256 totalVotes,
            bool approved
        )
    {
        require(
            proposalId > 0 && proposalId <= _proposalsCount,
            "Error: invalid proposal id"
        );

        Proposal storage p = _proposal[proposalId];
        return (string(p.hash), p.merchant, p.votes, p.approved);
    }
}
