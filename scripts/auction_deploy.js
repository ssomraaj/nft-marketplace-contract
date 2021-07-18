async function main() {
    const Auction = await ethers.getContractFactory("Auction");
    const auction = await Auction.deploy("0x01aBD704087A6251D47Dabbf6c76506ebCD12204","0x95477E438a54017753532aA549e5FF048053927a");

    console.log("Auction Contract Deployed at :", auction.address);
}

main()
.then(()=>{process.exit(0)})
.catch(error => {
    console.log("Deployment Error: ", error);
    process.exit(1);
});