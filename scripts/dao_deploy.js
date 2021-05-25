async function main() {
    const DAO = await ethers.getContractFactory("DAO");
    const contract = await DAO.deploy("0x45743228d93C9Ce6A8738A58E1d632F8270C12Ac");

    console.log("Token Contract Deployed at :", contract.address);
}

main()
.then(()=>{process.exit(0)})
.catch(error => {
    console.log("Deployment Error: ", error);
    process.exit(1);
});