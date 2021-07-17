// SPDX-License-Identifier: ISC

pragma solidity ^0.8.4;

import "./interfaces/IProcessPayments.sol";
import "./interfaces/IAggregatorV3.sol";
import "../token/interfaces/IBEP20.sol";
import "../utils/Context.sol";
import "../utils/Ownable.sol";

contract ProcessPayments is IProcessPayments, Ownable {
    address public settlement;
    /**
     * Mapping of bytes string representing token ticker to an oracle address.
     */
    mapping(bytes => address) private _oracles;

    /**
     * Mapping of bytes string representing token ticker to token smart contract.
     */
    mapping(bytes => address) private _contracts;

    /**
     *
     */
    mapping(bytes => uint8) private _isStable;

    /**
     * @dev verifies whether a contract address is configured for a specific ticker.
     */
    modifier Available(string memory _ticker) {
        require(
            _contracts[bytes(_ticker)] != address(0),
            "PoS Error: contract address for ticker not available"
        );
        _;
    }

    /**
     * @dev validates whether the given asset is a stablecoin.
     */
    modifier Stablecoin(string memory _ticker) {
        require(
            _isStable[bytes(_ticker)] == 1,
            "PoS Error: token doesn't represent a stablecoin"
        );
        _;
    }

    /**
     * @dev sets the owners in the Ownable Contract.
     */
    constructor() Ownable() {}

    /**
     * @dev sets the address of the oracle for the token ticker.
     *
     * Requirements:
     * `_oracleAddress` is the chainlink oracle address for price.
     * `_ticker` is the TICKER for the asset. Eg., BTC for Bitcoin.
     */
    function setOracle(address _oracleAddress, string memory _ticker)
        public
        virtual
        override
        onlyOwner
        returns (bool)
    {
        require(
            _oracleAddress != address(0),
            "PoS Error: oracle cannot be a zero address"
        );
        bytes memory ticker = bytes(_ticker);

        if (_oracles[ticker] == address(0)) {
            _oracles[ticker] = _oracleAddress;
            return true;
        } else {
            revert("PoS Error: oracle address already found");
        }
    }

    /**
     * @dev sets the address of the contract for token ticker.
     *
     * Requirements:
     * `_ticker` is the TICKER of the asset.
     * `_contractAddress` is the address of the token smart contract.
     * `_contractAddress` should follow BEP20/ERC20 standards.
     *
     * @return bool representing the status of the transaction.
     */
    function setContract(address _contractAddress, string memory _ticker)
        public
        virtual
        override
        onlyOwner
        returns (bool)
    {
        require(
            _contractAddress != address(0),
            "PoS Error: contract cannot be a zero address"
        );
        bytes memory ticker = bytes(_ticker);

        if (_contracts[ticker] == address(0)) {
            _contracts[ticker] = _contractAddress;
            return true;
        } else {
            revert("PoS Error: contract already initialized.");
        }
    }

    /**
     * @dev replace the oracle for an existing ticker.
     *
     * Requirements:
     * `_newOracle` is the chainlink oracle source that's changed.
     * `_ticker` is the TICKER of the asset.
     */
    function replaceOracle(address _newOracle, string memory _ticker)
        public
        virtual
        override
        onlyOwner
        returns (bool)
    {
        require(
            _newOracle != address(0),
            "PoS Error: oracle cannot be a zero address"
        );
        bytes memory ticker = bytes(_ticker);

        if (_oracles[ticker] != address(0)) {
            _oracles[ticker] = _newOracle;
            return true;
        } else {
            revert("PoS Error: set oracle to replace.");
        }
    }

    /**
     * @dev sets the address of the contract for token ticker.
     *
     * Requirements:
     * `_ticker` is the TICKER of the asset.
     * `_contractAddress` is the address of the token smart contract.
     * `_contractAddress` should follow BEP20/ERC20 standards.
     *
     * @return bool representing the status of the transaction.
     */
    function replaceContract(address _newAddress, string memory _ticker)
        public
        virtual
        override
        onlyOwner
        returns (bool)
    {
        require(
            _newAddress != address(0),
            "PoS Error: contract cannot be a zero address"
        );
        bytes memory ticker = bytes(_ticker);

        if (_contracts[ticker] != address(0)) {
            _contracts[ticker] = _newAddress;
            return true;
        } else {
            revert("PoS Error: contract not initialized yet.");
        }
    }

    /**
     * @dev replaces the settlement address.
     */
    function replaceSettlementAddress(address _newAddress)
        public
        virtual
        onlyOwner
        returns (bool)
    {
        require(
            _newAddress != address(0),
            "PoS Error: settlement address cannot be zero"
        );
        settlement = _newAddress;
        return true;
    }

    /**
     * @dev marks a specific asset as stablecoin.
     *
     * Requirements:
     * `_ticker` - TICKER of the token that's contract address is already configured.
     *
     * @return bool representing the status of the transaction.
     */
    function markAsStablecoin(string memory _ticker)
        public
        virtual
        override
        Available(_ticker)
        onlyOwner
        returns (bool)
    {
        _isStable[bytes(_ticker)] = 1;
        return true;
    }

    /**
     * @dev process payments with ticker & btc value
     */
    function payment(string memory _ticker, uint256 _btc)
        internal
        virtual
        Available(_ticker)
        returns (bool, uint256)
    {
        if (_isStable[bytes(_ticker)] == 1) {
            return sPayment(_ticker, _btc);
        } else {
            return tPayment(_ticker, _btc);
        }
    }

    /**
     * @dev process payments for stablecoins.
     *
     * Requirements:
     * `_ticker` is the name of the token to be processed.
     * `_btc` is the amount of BTC to be processed in 8-decimals.
     *
     * 1 Stablecoin is considered as 1 USD.
     */
    function sPayment(string memory _ticker, uint256 _btc)
        internal
        virtual
        Available(_ticker)
        Stablecoin(_ticker)
        returns (bool, uint256)
    {
        address spender = _msgSender();
        uint256 amount = sAmount(_ticker, _btc);
        address contractAddress = _contracts[bytes(_ticker)];

        require(
            approval(_ticker, spender) >= amount,
            "PoS Error: insufficient allowance for spender"
        );

        return (
            IBEP20(contractAddress).transferFrom(spender, settlement, amount),
            amount
        );
    }

    /**
     @dev estimates the amount of tokens in eq.btc.
     */
    function sAmount(string memory _ticker, uint256 _btc)
        public
        view
        returns (uint256)
    {
        address contractAddress = _contracts[bytes(_ticker)];
        uint256 decimals = IBEP20(contractAddress).decimals();
        require(decimals <= 18, "Pos Error: asset class not supported");
        // decimals = x
        uint256 price = btcPrice();
        // price - 8 decimal; _btc - 8 decimal;
        uint256 usd = price * _btc * 10**2;

        uint256 amount = usd / 10**(18 - decimals);
        return amount;
    }

    /**
     * @dev process payments for tokens.
     *
     * Requirements:
     * `_ticker` of the token.
     * `_btc` is the amount of BTC to be processed.
     *
     * Price of token is fetched from Chainlink.
     */
    function tPayment(string memory _ticker, uint256 _btc)
        internal
        virtual
        Available(_ticker)
        returns (bool, uint256)
    {
        uint256 amount = tAmount(_ticker, _btc);
        address user = _msgSender();

        require(
            approval(_ticker, user) >= amount,
            "PoS Error: Insufficient Approval"
        );
        address contractAddress = _contracts[bytes(_ticker)];
        return (
            IBEP20(contractAddress).transferFrom(user, settlement, amount),
            amount
        );
    }

    /**
     * @dev resolves the amount of tokens to be paid for the amount of usd.
     *
     * Requirements:
     * `_ticker` represents the token to be accepted for payments.
     * `_btc` represents the value in BTC.
     */
    function tAmount(string memory _ticker, uint256 _btc)
        public
        view
        returns (uint256)
    {
        uint256 price = btcPrice();
        uint256 usd = price * _btc * 10**10;

        uint256 targetPrice = fetchPrice(_ticker);
        uint256 amount = usd / targetPrice;

        address contractAddress = _contracts[bytes(_ticker)];
        uint256 decimal = IBEP20(contractAddress).decimals();

        require(decimal <= 18, "PoS Error: asset class cannot be supported");
        uint256 decimalCorrection = 18 - decimal;

        return amount / 10**decimalCorrection;
    }

    /**
     * @dev used for settle a tokens from the contract
     * to a user.
     *
     * Requirements:
     * `_ticker` of the token.
     * `_value` is the amount of tokens (decimals not handled)
     * `_to` is the address of the user.
     *
     * @return bool representing the status of the transaction.
     */
    function settle(
        string memory _ticker,
        uint256 _value,
        address _to
    ) internal virtual Available(_ticker) returns (bool) {
        address contractAddress = _contracts[bytes(_ticker)];
        return IBEP20(contractAddress).transfer(_to, _value);
    }

    /**
     * @dev checks the approval value of each token.
     *
     * Requirements:
     * `_ticker` is the name of the token to check approval.
     * '_holder` is the address of the account to be processed.
     *
     * @return the approval of any stablecoin in 18-decimal.
     */
    function approval(string memory _ticker, address _holder)
        private
        view
        returns (uint256)
    {
        address contractAddress = _contracts[bytes(_ticker)];
        return IBEP20(contractAddress).allowance(_holder, address(this));
    }

    /**
     * @dev returns the contract address.
     */
    function contractOf(string memory _ticker) public view returns (address) {
        return _contracts[bytes(_ticker)];
    }

    /**
     * @dev returns the latest round price from chainlink oracle.
     *
     * Requirements:
     * `_oracleAddress` the address of the oracle.
     *
     * @return the current latest price from the oracle.
     */
    function fetchPrice(string memory _ticker) public view returns (uint256) {
        address oracleAddress = _oracles[bytes(_ticker)];
        (, int256 price, , , ) = IAggregatorV3(oracleAddress).latestRoundData();
        return uint256(price);
    }

    /**
     * @dev returns the latest BTC-USD price from chainlink oracle.
     *
     * BTC-USD
     * Kovan: 0x6135b13325bfC4B00278B4abC5e20bbce2D6580e
     */
    function btcPrice() public view returns (uint256) {
        (, int256 price, , , ) =
            IAggregatorV3(0x6135b13325bfC4B00278B4abC5e20bbce2D6580e)
                .latestRoundData();
        return uint256(price);
    }
}
