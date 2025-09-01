import { network } from "hardhat";

const { ethers } = await network.connect({
  network: "hardhatOp",
  chainType: "op",
});

async function main(): Promise<void> {

    const EcoClean = await ethers.getContractFactory("EcoClean");
    const ecoClean = await EcoClean.deploy();

    await ecoClean.waitForDeployment();

    console.log(await ecoClean.getAddress())

    const [user1, user2, admin1, admin2, producer1, producer2] = await ethers.getSigners();

    console.log("///////////////// USER FLOW //////////////////////////////")
    
    const tx = await ecoClean.connect(user1).registerUser();
    const receipt = await tx.wait();

    const user1id = await ecoClean.userId(user1);
    console.log("Is User1 id ", user1id);

    const userAccount = await ecoClean.userAccountId(user1id)
    console.log("user Account Details", userAccount)

    await ecoClean.connect(user2).registerUser();
    const user2id = await ecoClean.userId(user2);
    console.log("user2Id before deleting :", user2id)

    const removeUser = await ecoClean.deleteUserAccount(user2.address);
    await removeUser.wait();

    const user2iid = await ecoClean.userId(user2);  
    console.log("user2Id after deleting :", user2iid.toString());

    console.log("///////////////// ADMIN FLOW //////////////////////////////")

    await ecoClean.registerAdmin(admin1);
    const admin = await ecoClean.adminId(admin1.getAddress());
    console.log("admin id: ", admin)
    const isAdmin = await ecoClean.isAdminRegistered(admin1.getAddress());
    console.log("is Admin Registered: ", isAdmin)


    
 



}


main().catch(e => {
    console.error(e)
})