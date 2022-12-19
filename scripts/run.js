const { ethers } = require("hardhat");
const hre = require("hardhat");
require("@nomiclabs/hardhat-web3");



async function main() {

    const [owner, randomPerson] = await hre.ethers.getSigners();
    const lockedAmount = hre.ethers.utils.parseEther("0.01");

    const Lock = await hre.ethers.getContractFactory("deploy");
    const lock = await Lock.deploy();    

    await lock.deployed();

    console.log(
      `deployed to ${lock.address}`
      );

    //let u = await lock.createPool("0x57241A37733983F97C4Ab06448F244A1E0Ca0ba8",2000,170200000,100,2,170000000,"LOL","OP");
    

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
