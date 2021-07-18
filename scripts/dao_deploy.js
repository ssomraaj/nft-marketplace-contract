const hre = require("hardhat");

async function main() {
    const DAO = await hre.ethers.getContractFactory("DAO");
    const contract = await DAO.deploy("0x833bA1Ab69309Dc6202826800968921F0fdc168C");

    console.log("DAO Contract Deployed at :", contract.address);
}

main()
.then(()=>{process.exit(0)})
.catch(error => {
    console.log("Deployment Error: ", error);
    process.exit(1);
});