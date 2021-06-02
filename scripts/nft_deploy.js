async function main() {
    const BEP = await ethers.getContractFactory('BEP1155');
    const contract = await BEP.deploy('https://ipfs.io/ipfs/', '0x833bA1Ab69309Dc6202826800968921F0fdc168C');

    console.log("Token Contract Deployed at :", contract.address);
}

main()
.then(()=>{process.exit(0)})
.catch(error => {
    console.log("Deployment Error: ", error);
    process.exit(1);
});