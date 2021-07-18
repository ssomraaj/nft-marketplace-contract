//SPDX-License-Identifier: ISC

pragma solidity ^0.8.4;

import "./interfaces/IDAO.sol";
import "../utils/Context.sol";
import "../token/interfaces/IBEP20.sol";

contract DAO is Context, IDAO {
    struct Proposal {
        address merchant;
        bytes hash;
        bool approved;
        uint8 platformTax;
        uint256 listingFee;
        uint256 votes;
    }

    struct Distribution {
        address[] earners;
        bool approved;
        bool rejected;
        bool settled;
        uint256[] percentages;
        uint256 voteFor;
        uint256 voteAgainst;
        uint256 createdAt;
    }

    address private _token;
    address private _admin;

    uint256 private _merchantsCount;
    uint256 private _proposalsCount;
    uint256 private _distributionCount;

    mapping(address => bool) private _merchant;
    mapping(address => bool) private _listed;
    mapping(address => string) public ethWallet;
    mapping(address => string) public bscWallet;
    mapping(address => string) public btcWallet;
    mapping(address => uint256) public override listingFee;
    mapping(address => uint8) public override platformTax;

    mapping(uint256 => Proposal) private _proposal;
    mapping(address => mapping(uint256 => bool)) private _voted;
    mapping(address => mapping(uint256 => bool)) private _dVoted;
    mapping(uint256 => Distribution) private _distribution;

    event CreateMerchant(
        bytes hash,
        address merchant,
        uint256 listingFee,
        uint8 platformTax,
        uint256 proposalId
    );

    event CreateDistribution(
        uint256 distributionId,
        address[] earners,
        uint256[] percentages
    );

    event Vote(uint256 proposalId, address voter, uint256 znftShares);

    event VoteDistribution(uint256 distributionId, uint256 votes, bool support);

    event Distribute(uint256 distributionId);

    modifier onlyOwner() {
        require(_msgSender() == _admin, "DAO Error: caller not admin");
        _;
    }

    constructor(address _tokenContract) {
        _token = _tokenContract;
        _admin = _msgSender();
    }

    receive() external payable {}

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
            _msgSender(),
            bytes(hash),
            false,
            _platformTax,
            _listingFee,
            0
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
        require(
            !_voted[_msgSender()][proposalId],
            "Error: voter already voted"
        );

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

        _voted[_msgSender()][proposalId] = true;

        emit Vote(proposalId, _msgSender(), balance);
        return true;
    }

    function createDistribution(
        address[] memory _earners,
        uint256[] memory _percentages
    ) public virtual override returns (bool) {
        require(
            _earners.length == _percentages.length,
            "DAO Error: invalid inputs"
        );

        uint256 balance = IBEP20(_token).balanceOf(_msgSender());
        uint256 distributionId = _distributionCount + 1;
        require(balance > 0, "DAO Error: znft share holder only can create");

        Distribution storage d = _distribution[distributionId];
        require(
            validatePercentages(_percentages),
            "DAO Error: invalid percentages"
        );

        d.earners = _earners;
        d.percentages = _percentages;
        _distributionCount += 1;

        emit CreateDistribution(distributionId, _earners, _percentages);
        return true;
    }

    function validatePercentages(uint256[] memory _percentages)
        private
        pure
        returns (bool)
    {
        uint256 sum;
        for (uint256 i = 0; i < _percentages.length; i++) {
            sum += _percentages[i];
        }
        return sum == 100;
    }

    function voteDistribution(uint256 _distributionId, bool _support)
        public
        virtual
        override
        returns (bool)
    {
        uint256 balance = IBEP20(_token).balanceOf(_msgSender());
        uint256 totalSupply = IBEP20(_token).totalSupply();

        require(
            !_dVoted[_msgSender()][_distributionId],
            "Error: user already voted"
        );
        require(
            _distributionId <= _distributionCount,
            "Error: invalid distribution id"
        );
        require(balance > 0, "Error: znft share holders can only vote");

        Distribution storage d = _distribution[_distributionId];
        require(
            !d.approved && !d.rejected && !d.settled,
            "Error: distribution already resolved"
        );

        if (_support) {
            d.voteFor += balance;
        } else {
            d.voteAgainst += balance;
            if (d.voteAgainst > totalSupply / 20) {
                d.rejected = true;
            }
        }

        _dVoted[_msgSender()][_distributionId] = true;
        emit VoteDistribution(_distributionId, balance, _support);
        return true;
    }

    function distribute(uint256 _distributionId)
        public
        virtual
        override
        returns (bool)
    {
        Distribution storage d = _distribution[_distributionId];
        uint256 totalSupply = IBEP20(_token).totalSupply();

        if (
            (d.voteFor > totalSupply / 2) &&
            block.timestamp > d.createdAt + 24 hours
        ) {
            d.approved = true;
        }

        require(
            !d.settled && d.approved,
            "Error: already settled (or) not approved"
        );

        uint256 ethBalance = address(this).balance;
        uint256 wBtcBalance =
            IBEP20(0xA4aBDaE0C0f861c11b353f7929fe6dB48535eaB3).balanceOf(
                address(this)
            );
        uint256 wETHBalance =
            IBEP20(0x24Cc33eBd310f9cBd12fA3C8E72b56fF138CA434).balanceOf(
                address(this)
            );

        for (uint256 i = 0; i < d.earners.length; i++) {
            payable(d.earners[i]).transfer(
                (ethBalance * d.percentages[i]) / 100
            );
            IBEP20(0xA4aBDaE0C0f861c11b353f7929fe6dB48535eaB3).transfer(
                d.earners[i],
                (wBtcBalance * d.percentages[i]) / 100
            );
            IBEP20(0x24Cc33eBd310f9cBd12fA3C8E72b56fF138CA434).transfer(
                d.earners[i],
                (wETHBalance * d.percentages[i]) / 100
            );
        }

        d.settled = true;
        emit Distribute(_distributionId);
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

    function distribution(uint256 _distributionId)
        public
        view
        virtual
        returns (Distribution memory)
    {
        require(
            _distributionId <= _distributionCount,
            "Error: invalid distribution ID"
        );
        return _distribution[_distributionId];
    }

    function totalDistributions() public view virtual returns (uint256) {
        return _distributionCount;
    }
}
