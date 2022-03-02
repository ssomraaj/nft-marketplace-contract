/**
 * @type import('hardhat/config').HardhatUserConfig
 */
 require("@nomiclabs/hardhat-ethers");
 require("@nomiclabs/hardhat-truffle5");
 require("@nomiclabs/hardhat-etherscan");
 
 const TESTNET_PRIVATE_KEY = "";
 const BSCSCAN_KEY = "";
 const ETHSCAN_KEY = "";
 
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
 
