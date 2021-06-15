async function main() {
    const Auction = await ethers.getContractFactory("Auction");
    const auction = await Auction.deploy();

    console.log("Auction Contract Deployed at :", auction.address);
}

main()
.then(()=>{process.exit(0)})
.catch(error => {
    console.log("Deployment Error: ", error);
    process.exit(1);
});