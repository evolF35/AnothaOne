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

    let u = await lock.createPool("0x57241A37733983F97C4Ab06448F244A1E0Ca0ba8",2000,170000000)
    
    console.log(u);

    // contractBal = await hre.ethers.provider.getBalance(lock.address);
    // console.log(contractBal);

    // let txn1 = await lock.depositToPOS({value:lockedAmount});
    // let txn2 = await lock.depositToNEG({value:lockedAmount});

    // contractBal = await hre.ethers.provider.getBalance(lock.address);
    // console.log(contractBal);

    // let txn3 = await lock.depositToNEG({value:lockedAmount});
    // contractBal = await hre.ethers.provider.getBalance(lock.address);
    // console.log(contractBal);

    // let settle = await lock.pastSettlementDate();
    // console.log(settle);

    // await lock.changeSettlementDate();

    // settle = await lock.pastSettlementDate();
    // console.log(settle);

    // let pos = await lock.getAllowancePOS();
    // console.log(pos);

    // await lock.approveWithPOS();

    // pos = await lock.getAllowancePOS();
    // console.log(pos);

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
