async function main() {
    const ZNFT_SHARES = await ethers.getContractFactory("ZNFTShares");
    const ZNFTShares = await ZNFT_SHARES.deploy("ZNFT Shares", "ZNFTS");

    console.log("Token Contract Deployed at :", ZNFTShares.address);
}

main()
.then(()=>{process.exit(0)})
.catch(error => {
    console.log("Deployment Error: ", error);
    process.exit(1);
});