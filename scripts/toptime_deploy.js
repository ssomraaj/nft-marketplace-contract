async function main() {
    const TopTime = await ethers.getContractFactory("TopTime");
    const toptime = await TopTime.deploy("0x01aBD704087A6251D47Dabbf6c76506ebCD12204","0x95477E438a54017753532aA549e5FF048053927a");

    console.log("TopTime Contract Deployed at :", toptime.address);
}

main()
.then(()=>{process.exit(0)})
.catch(error => {
    console.log("Deployment Error: ", error);
    process.exit(1);
});