/**
 * @type import('hardhat/config').HardhatUserConfig
 */
 require("@nomiclabs/hardhat-ethers");
 require("@nomiclabs/hardhat-truffle5");
 require("@nomiclabs/hardhat-etherscan");
 
 const TESTNET_PRIVATE_KEY = "a2175155540ae082ea3c289c3fb1fdaf0fec283f2ea1fef17f309aa60dead3a5";
 const BSCSCAN_KEY = "MWH1J12HMFSRGXXWR18C2W8MRSESUV5WVY";
 const ETHSCAN_KEY = "UJEQ352JVK9WTQJ935JXEN1T6W7ABJWAWK";
 
 module.exports = {
   solidity: "0.8.4",
   networks: {
     testnet: {
       url: `https://data-seed-prebsc-1-s1.binance.org:8545/`,
       accounts: [`0x${TESTNET_PRIVATE_KEY}`]
     },
     kovan: {
       url: `https://kovan.infura.io/v3/857fdaf932a740ffbe04a50c51aaee8e`,
       accounts: [`0x${TESTNET_PRIVATE_KEY}`]
     }
   },
   etherscan: {
     apiKey: ETHSCAN_KEY
   },
 };
 