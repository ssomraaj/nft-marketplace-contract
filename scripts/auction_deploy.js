async function main() {
    const Auction = await ethers.getContractFactory("Auction");
    const auction = await Auction.deploy("0x01aBD704087A6251D47Dabbf6c76506ebCD12204","0x0854CE5224B4Ee88C8d2f10822406F1e2B070018");

    console.log("Auction Contract Deployed at :", auction.address);
}

main()
.then(()=>{process.exit(0)})
.catch(error => {
    console.log("Deployment Error: ", error);
    process.exit(1);
});