async function main() {
    const FixedPrice = await ethers.getContractFactory("FixedPriceSale");
    const fixedPrice = await FixedPrice.deploy("0x01aBD704087A6251D47Dabbf6c76506ebCD12204","0xd2084b8F1a5e77e6478a5A1Ed595BaA944E3C3C4");

    console.log("Fixed Price Contract Deployed at :", fixedPrice.address);
}

main()
.then(()=>{process.exit(0)})
.catch(error => {
    console.log("Deployment Error: ", error);
    process.exit(1);
});