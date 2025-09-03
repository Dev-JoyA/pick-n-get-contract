import { network } from "hardhat";
import { execPath, pid } from "process";

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
    await tx.wait();

    const user1id = await ecoClean.userId(user1.address);
    console.log("Is User1 id ", user1id);

    const userAccount = await ecoClean.userAccountId(user1id)
    console.log("user Account Details", userAccount)

    await ecoClean.connect(user2).registerUser();
    const user2id = await ecoClean.userId(user2.address);
    console.log("user2Id before deleting :", user2id)

    const removeUser = await ecoClean.deleteUserAccount(user2.address);
    await removeUser.wait();

    const user2iid = await ecoClean.userId(user2);  
    console.log("user2Id after deleting :", user2iid.toString());

    const type = "plastic"
    const weight = 10

    const recycle = await ecoClean.connect(user1).recycleItem(type, weight)
    await recycle.wait();
    const rid  = await ecoClean.recycledItemId(user1id);
    console.log("recycled item id : ", rid)

    const recycleItem = await ecoClean.itemByUserId(user1id, rid)
    console.log("recycled item: ", {
        weight: recycleItem.weight.toString(),
        itemType: recycleItem.itemType.toString(),
    });


    console.log("///////////////// ADMIN FLOW //////////////////////////////")

    await ecoClean.registerAdmin(admin1);
    const admin = await ecoClean.adminId(admin1.address);
    console.log("admin id: ", admin)
    const isAdmin = await ecoClean.isAdminRegistered(admin1.getAddress());
    console.log("is Admin Registered: ", isAdmin)

    await ecoClean.connect(admin1).setRate(2);
    const rate = await ecoClean.rate();
    console.log("Current rate: ", rate.toString());


    const hasPaid = await ecoClean.hasUserReceivedPayment(user1id,rid)
    
    const isReg = await ecoClean.isAdminRegistered(admin1.getAddress())
    console.log("is reg: ", isReg)

    const fund = await ecoClean.fundContract({
        value: ethers.parseUnits("50000", 8)
    })

    await fund.wait()
    console.log("contract funded")
    const bal = await ecoClean.connect(admin1).contractBalance()
    console.log("contract balance: ",bal.toString())

    

    const itemWeight = await ecoClean.itemByUserId(user1id, rid);
    console.log("Item weight:", itemWeight.toString());
    const amount = 150
    console.log("Amount to pay (before decimals):", amount.toString());
    console.log("Amount to pay (with decimals):", amount * (10 ** 8));


    console.log("user receieved payment before : ",hasPaid)
    await ecoClean.connect(admin1).payUser(user1id, rid);
    const hasPaid2 = await ecoClean.hasUserReceivedPayment(user1id,rid)
    console.log("user receieved payment after : ",hasPaid2)


    console.log("///////////////// PRODUCER FLOW //////////////////////////////")

    const producerName  = "T_ja"
    const country = "Nigeria"
    const producerNumber = 234

    await ecoClean.connect(producer1).registerProducer(producerName,country, producerNumber)

    const ownerId = await ecoClean.registrationId(producer1.getAddress())
    console.log("producer registration Id", ownerId)
    const p_details = await ecoClean.ownerDetails(ownerId)
    console.log("producer details", p_details)

    const productName = "Recycled Paper";
    const quantity = 10;
    const data = ethers.toUtf8Bytes("Sample product metadata or description")
    const productAmount = 5;

    await ecoClean.addProduct(ownerId, productName, quantity, data, productAmount)

    const ownerAddress = await ecoClean.productOwner(ownerId)
    console.log("producer ownner address: ", ownerAddress)
    console.log("producer address: ", await producer1.getAddress())
    console.log("product count after adding one product ", await ecoClean.productCount())
    console.log("product count by owner ", await ecoClean.productCountByOwner(ownerId))

    // // adding another product and producer
    // await ecoClean.connect(producer2).registerProducer(producerName,country, producerNumber)
    // const pId2 = await ecoClean.registrationId(producer2.getAddress())
    // await ecoClean.addProduct(pId2, productName, 5, data, productAmount)
    // console.log("product count after adding two product ", await ecoClean.productCount())
    // console.log("product count by producer 2 ", await ecoClean.productCountByOwner(pId2))
    // console.log("product count by by producer 1 ", await ecoClean.productCountByOwner(pId))

    // //adding another product for producwe two , to increase his product count
     await ecoClean.addProduct(ownerId, "bag", quantity, data, productAmount)
    // console.log("product count after adding three product ", await ecoClean.productCount())
    // console.log("product count by producer 2 ", await ecoClean.productCountByOwner(pId2))
    // console.log("product count by by producer 1 ", await ecoClean.productCountByOwner(pId))

    const pId = 2;
    const allProduct = await ecoClean.allProductsByProducer(ownerId,2)

    console.log("product by producer 1, with id: ", "products: ", allProduct)

    const status = allProduct.productStatus;
    console.log("Product status: ", status);

    console.log("valid Pid: ", await ecoClean.validPid(pId))
    const p = await ecoClean.products(pId)
    console.log("Product details: ", p.amount)
    const totalCost = p.amount * 2n
    await ecoClean.shopProduct(pId, 2, { value: totalCost });
    console.log("quantity before purchase: ", quantity)
    const p2 = await ecoClean.allProductsByProducer(ownerId, pId);
    console.log("quantity after purchase: ", p2.quantity.toString());



    
 



}


main().catch(e => {
    console.error(e)
})