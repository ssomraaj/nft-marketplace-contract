async function main() {
    const TopTime = await ethers.getContractFactory("TopTime");
    const toptime = await TopTime.deploy();

    console.log("TopTime Contract Deployed at :", toptime.address);
}

main()
.then(()=>{process.exit(0)})
.catch(error => {
    console.log("Deployment Error: ", error);
    process.exit(1);
});