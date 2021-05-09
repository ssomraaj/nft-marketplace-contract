/**
 * @type import('hardhat/config').HardhatUserConfig
 */
 require("@nomiclabs/hardhat-ethers");
 require("@nomiclabs/hardhat-truffle5");
 require("@nomiclabs/hardhat-etherscan");
 
 const TESTNET_PRIVATE_KEY = "e837b3ce27609e5241b37e510b4ef9251f6991a45ac1ea8174a2b878e993296b";
 const BSCSCAN_KEY = "MWH1J12HMFSRGXXWR18C2W8MRSESUV5WVY";
 
 module.exports = {
   solidity: "0.8.4",
   networks: {
     testnet: {
       url: `https://data-seed-prebsc-1-s1.binance.org:8545/`,
       accounts: [`0x${TESTNET_PRIVATE_KEY}`]
     }
   },
   etherscan: {
     apiKey: BSCSCAN_KEY
   },
 };
 