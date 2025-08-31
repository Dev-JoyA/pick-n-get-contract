import { expect } from "chai";
import { network } from "hardhat";
const { networkHelpers } = await network.connect();
import EcoClean from "../ignition/modules/EcoClean.js";

const { ethers } = await network.connect();

describe("EcoClean", function () {
    async function deployEcoClean() {
        const ecoClean = await ethers.getContractFactory("EcoClean");
        const EcoClean = await ecoClean.deploy();
        await EcoClean.waitForDeployment();

        const [owner, user1, user2, user3] = await ethers.getSigners();

        return {EcoClean, owner, user1, user2, user3};
    }
    
    describe("Deployment", function() {
        it("should deploy the contract", async function(){
            const {EcoClean} =  await networkHelpers.loadFixture(deployEcoClean);
            expect(await EcoClean.getAddress()).to.properAddress;
        })
    })

    describe("Register User", function() {
        it("should register user", async function(){
            const {EcoClean, user1} =  await networkHelpers.loadFixture(deployEcoClean);
            await EcoClean.connect(user1).registerUser();
            const userId = await EcoClean.userId;
            expect(userId).to.not.equal(0);
        })
    })

    describe("Register Producer", function() {
        it("should register producer", async function(){
            const {EcoClean, user2} =  await networkHelpers.loadFixture(deployEcoClean);
            let name = "my name";
            let country = "my country";
            let number = 9023333;
            await EcoClean.connect(user2).registerProducer(name, country,number);

            const producerId = await EcoClean.registrationId(user2.address);
            const producer = await EcoClean.ownerDetails(producerId);
            expect(producer.name).to.equal(name);
            expect(producer.country).to.equal(country);
            expect(producer.phoneNumber).to.equal(number);
        })
    })

    describe("Add Product", function () {
        it("should allow a producer to add a product", async function () {
            const { EcoClean, user2 } = await networkHelpers.loadFixture(deployEcoClean);


            // Get producer id (assume your contract stores mapping of address -> producerId)
            const producerId = await EcoClean.registrationId(user2.address);

            // Add product
            const productId = 1;
            const productName = "Eco Soap";
            const productData = ethers.encodeBytes32String("organic ingredients"); // example encoding
            const productAmount = 100;

            await EcoClean.connect(user2).addProduct(producerId, productName, productData, productAmount);

            // Verify from mapping
            const product = await EcoClean.allProductsByProducer(producerId, productId);
            expect(product.name).to.equal(productName);
            expect(product.amount).to.equal(productAmount);
        });
    });

    // describe("Shop Product", function () {
    //     it("should allow a user to shop a product", async function () {
    //         const { EcoClean, user1, user2 } = await networkHelpers.loadFixture(deployEcoClean);

    //         const producerId = await EcoClean.registrationId(user2.address);

    //         //  Add product
    //          const productId = 1;
    //          const productName = "Eco Soap";
    //          const productData = ethers.encodeBytes32String("organic ingredients");
    //          const productAmount = 100;
    //          await EcoClean.connect(user2).addProduct(producerId, productName, productData, productAmount);

    //         // // Register user
    //         // await EcoClean.connect(user1).registerUser();

    //         // Shop product
    //         const shopAmount = 5;
    //         await EcoClean.connect(user1).shopProduct(shopAmount);

    //         // Verify remaining amount
    //         const product = await EcoClean.allProductsByProducer(producerId, productId);
    //         expect(product.amount).to.equal(productAmount - shopAmount);
    //     });
    // });

        describe("Shop Product", function () {
            it("should allow a user to shop a product", async function () {
                const { EcoClean, user1, user2 } = await networkHelpers.loadFixture(deployEcoClean);

                const producerId = await EcoClean.registrationId(user2.address);

                // Add product
                const productId = 1;
                const productName = "Eco Soap";
                const productData = ethers.encodeBytes32String("organic ingredients");
                const productPrice = 100; // Price per unit
                const productQuantity = 50; // Initial stock
                await EcoClean.connect(user2).addProduct(producerId, productName, productData, productPrice);

                // Shop product
                const shopQuantity = 5;
                await EcoClean.connect(user1).shopProduct(productId, shopQuantity);

                // Verify remaining stock
                const product = await EcoClean.allProductsByProducer(producerId, productId);
                expect(product.amount).to.equal(productQuantity - shopQuantity); // Note: Adjust if product.amount is price, not stock
            });
        });
});