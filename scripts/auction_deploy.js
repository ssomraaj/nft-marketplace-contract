async function main() {
    const Auction = await ethers.getContractFactory("Auction");
    const auction = await Auction.deploy("0x01aBD704087A6251D47Dabbf6c76506ebCD12204","0xd2084b8F1a5e77e6478a5A1Ed595BaA944E3C3C4");

    console.log("Auction Contract Deployed at :", auction.address);
}

main()
.then(()=>{process.exit(0)})
.catch(error => {
    console.log("Deployment Error: ", error);
    process.exit(1);
});