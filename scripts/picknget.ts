import { network } from "hardhat";
import { execPath, pid } from "process";

const { ethers } = await network.connect({
  network: "hardhatOp",
  chainType: "op",
});

async function main(): Promise<void> {

    const PicknGet = await ethers.getContractFactory("PicknGet");
    const picknget = await PicknGet.deploy();

    await picknget.waitForDeployment();

    console.log(await picknget.getAddress())

    const [user1, user2, admin1, admin2, producer1, producer2] = await ethers.getSigners();

    console.log("///////////////// USER FLOW //////////////////////////////")
    
    const homeAddress ="home address";
    const phoneNumber = 123456789;
    const tx = await picknget.connect(user1).registerUser(homeAddress, phoneNumber);
    await tx.wait();

    const user1id = await picknget.userId(user1.address);
    console.log("Is User1 id ", user1id);

    const userAccount = await picknget.userAccountId(user1id)
    console.log("user Account Details", userAccount)

    const address = "home address";
    const number = 123456789;
    await picknget.connect(user2).registerUser(address, number);
    const user2id = await picknget.userId(user2.address);
    console.log("user2Id before deleting :", user2id)

    const removeUser = await picknget.deleteUserAccount(user2.address);
    await removeUser.wait();

    const user2iid = await picknget.userId(user2);  
    console.log("user2Id after deleting :", user2iid.toString());

    const type = "plastic"
    const weight = 10

    const recycle = await picknget.connect(user1).recycleItem(type, weight)
    await recycle.wait();
    const rid  = await picknget.recycledItemId(user1id);
    console.log("recycled item id : ", rid)

    const recycleItem = await picknget.itemByUserId(user1id, rid)
    console.log("recycled item: ", {
        weight: recycleItem.weight.toString(),
        itemType: recycleItem.itemType.toString(),
    });


    console.log("///////////////// ADMIN FLOW //////////////////////////////")

    await picknget.registerAdmin(admin1);
    const admin = await picknget.adminId(admin1.address);
    console.log("admin id: ", admin)
    const isAdmin = await picknget.isAdminRegistered(admin1.getAddress());
    console.log("is Admin Registered: ", isAdmin)

    await picknget.connect(admin1).setRate(2);
    const rate = await picknget.rate();
    console.log("Current rate: ", rate.toString());


    const hasPaid = await picknget.hasUserReceivedPayment(user1id,rid)
    
    const isReg = await picknget.isAdminRegistered(admin1.getAddress())
    console.log("is reg: ", isReg)

    const fund = await picknget.fundContract({
        value: ethers.parseUnits("50000", 8)
    })

    await fund.wait()
    console.log("contract funded")
    const bal = await picknget.connect(admin1).contractBalance()
    console.log("contract balance: ",bal.toString())

    

    const itemWeight = await picknget.itemByUserId(user1id, rid);
    console.log("Item weight:", itemWeight.toString());
    const amount = 150
    console.log("Amount to pay (before decimals):", amount.toString());
    console.log("Amount to pay (with decimals):", amount * (10 ** 8));


    console.log("user receieved payment before : ",hasPaid)
    await picknget.connect(admin1).payUser(user1id, rid);
    const hasPaid2 = await picknget.hasUserReceivedPayment(user1id,rid)
    console.log("user receieved payment after : ",hasPaid2)


    console.log("///////////////// PRODUCER FLOW //////////////////////////////")

    const producerName  = "T_ja"
    const country = "Nigeria"
    const producerNumber = 234

    await picknget.connect(producer1).registerProducer(producerName,country, producerNumber)

    const ownerId = await picknget.registrationId(producer1.getAddress())
    console.log("producer registration Id", ownerId)
    const p_details = await picknget.ownerDetails(ownerId)
    console.log("producer details", p_details)

    const productName = "Recycled Paper";
    const quantity = 10;
    const data = ethers.toUtf8Bytes("Sample product metadata or description")
    const productAmount = 5;

    await picknget.addProduct(ownerId, productName, quantity, data, productAmount)

    const ownerAddress = await picknget.productOwner(ownerId)
    console.log("producer ownner address: ", ownerAddress)
    console.log("producer address: ", await producer1.getAddress())
    console.log("product count after adding one product ", await picknget.productCount())
    console.log("product count by owner ", await picknget.productCountByOwner(ownerId))

    // // adding another product and producer
    // await picknget.connect(producer2).registerProducer(producerName,country, producerNumber)
    // const pId2 = await picknget.registrationId(producer2.getAddress())
    // await picknget.addProduct(pId2, productName, 5, data, productAmount)
    // console.log("product count after adding two product ", await picknget.productCount())
    // console.log("product count by producer 2 ", await picknget.productCountByOwner(pId2))
    // console.log("product count by by producer 1 ", await picknget.productCountByOwner(pId))

    // //adding another product for producwe two , to increase his product count
     await picknget.addProduct(ownerId, "bag", quantity, data, productAmount)
    // console.log("product count after adding three product ", await picknget.productCount())
    // console.log("product count by producer 2 ", await picknget.productCountByOwner(pId2))
    // console.log("product count by by producer 1 ", await picknget.productCountByOwner(pId))

    const pId = 2;
    const allProduct = await picknget.allProductsByProducer(ownerId,2)

    console.log("product by producer 1, with id: ", "products: ", allProduct)

    const status = allProduct.productStatus;
    console.log("Product status: ", status);

    console.log("valid Pid: ", await picknget.validPid(pId))
    const p = await picknget.products(pId)
    console.log("Product details: ", p.amount)
    const totalCost = p.amount * 2n
    await picknget.shopProduct(pId, 2, { value: totalCost });
    console.log("quantity before purchase: ", quantity)
    const p2 = await picknget.allProductsByProducer(ownerId, pId);
    console.log("quantity after purchase: ", p2.quantity.toString());



    
 



}


main().catch(e => {
    console.error(e)
})