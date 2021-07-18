async function main() {
    const FixedPrice = await ethers.getContractFactory("FixedPriceSale");
    const fixedPrice = await FixedPrice.deploy("0x01aBD704087A6251D47Dabbf6c76506ebCD12204","0x95477E438a54017753532aA549e5FF048053927a");

    console.log("Fixed Price Contract Deployed at :", fixedPrice.address);
}

main()
.then(()=>{process.exit(0)})
.catch(error => {
    console.log("Deployment Error: ", error);
    process.exit(1);
});