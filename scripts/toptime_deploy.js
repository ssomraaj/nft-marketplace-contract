async function main() {
    const TopTime = await ethers.getContractFactory("TopTime");
    const toptime = await TopTime.deploy("0x01aBD704087A6251D47Dabbf6c76506ebCD12204","0xd2084b8F1a5e77e6478a5A1Ed595BaA944E3C3C4");

    console.log("TopTime Contract Deployed at :", toptime.address);
}

main()
.then(()=>{process.exit(0)})
.catch(error => {
    console.log("Deployment Error: ", error);
    process.exit(1);
});