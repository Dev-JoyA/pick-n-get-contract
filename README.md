# 🌍Product Smart Contract

### 🧾 A decentralized marketplace for transparent and direct product sales between producers and buyers.

---

## 💡 What It Does

The **Product Smart Contract** is a blockchain-based system that allows **producers** to register their business, **add products**, and **sell them directly** to buyers — **without middlemen**.

Every product, payment, and ownership record is stored securely on the blockchain, ensuring **trust, transparency, and traceability**.

---

## 🧱 How It Works

| Step | Description |
|------|--------------|
| 🧍‍♂️ **1. Register as a Producer** | A producer/product-owner registers with their name, country, and phone number. |
| 📦 **2. Add Products** | Once registered, the producer can list products for sale with a name, description, quantity, and price. |
| 💳 **3. Buyers Purchase** | Buyers can browse and buy available products by sending the exact payment in cryptocurrency (HBAR). |
| 💰 **4. Automatic Payment** | Once the buyer pays, the smart contract transfers 10% to the Picknget contract and transfer the balance directly to the producer instantly and securely. |
| 🔒 **5. Transparency Ensured** | Every transaction and product update (e.g., sold out) is recorded publicly on the blockchain. |

---

## 🚀 Why It Matters

### 🌐 **No Middlemen**
Producers sell directly to consumers reducing costs and increasing profit margins.

### 🔍 **Trust Through Transparency**
All transactions and product details are permanently stored on the blockchain, eliminating fraud or hidden changes.

### 💸 **Instant Payments**
Producers receive payments instantly after each purchase, with no third-party delays or processing fees.

### 📊 **Proven Authenticity**
Buyers can verify a product’s origin and owner before making a purchase.

---

## 🧩 Main Features

✅ **Producer Registration**  
Each producer must register before listing any product ensuring verified sellers.

✅ **Product Management**  
Producers can create and track their own product listings.

✅ **Automated Sales & Payment**  
The smart contract handles payment verification and transfers funds automatically.

✅ **Stock Tracking**  
When a product’s quantity hits zero, it is automatically marked as *Not Available*.

✅ **Blockchain Security**  
All records (registrations, listings, purchases) are transparent and tamper-proof.

---

## 🧠 Example Scenario

### 🎯 1. Producer Registration
Joy, a honey producer, registers her details on the blockchain:

```solidity
registerProductOwner(
    0xAbC123...,  *Wallet Address gotten from contract interaction*
    "Joy Aruku",
    "Nigeria",
    8123456789
);
```

### 2. Add Product

Joy adds her product “Recyled Gym Mat”:
```solidity
addProducts(
    "Recyled Gym Mat",
    50, *quantity*
    "Gym mat from Nigeria made from recycled textiles",
    "0x1234...",   *product image hash*
    0.01 hbar
);

```
✅ The product is now live for buyers to purchase.

### 🛒 3. Buyer Makes a Purchase

A customer buys 2 pieces of “Gym Mat”:
```solidity
_shopProduct(
    1, *producer id*
    2 *quantity*
    ) payable
```
✅ The hbar cost of the item is removed from the buyer's account, 10% goes to the main contract *picknget* and the balance is automatically transferred to Joy’s wallet.
✅ The product’s stock is reduced by 2.
✅ If it sells out, it’s automatically marked as Not Available.

## 📦 Product Status

| Status | Meaning |
|--------|----------|
| 🟢 **Available** | Product is in stock and can be purchased. |
| 🔴 **NotAvailable** | Product is sold out or unavailable. |

---

## 🔐 Built-In Protections

- ❌ Prevents duplicate producer registrations  
- 🚫 Disallows unregistered producers from adding products  
- 💵 Rejects incorrect payment amounts  
- 🔁 Blocks repeated payment for the same product  
- 🧮 Automatically manages stock levels  

---


## 🧰 Technical Summary

| Item | Description |
|------|--------------|
| **Language** | Solidity |
| **Compiler Version** | ^0.8.28 |
| **License** | UNLICENSED |
| **Distributed Ledger** | HEDERA|
| **Payment** | HBAR |
| **Data Storage** | On-chain mappings (no off-chain dependency) |

---

## 💬 Events

```solidity
event ProductAdded(uint256 indexed id, address owner);
```
Emitted whenever a producer successfully adds a new product.



To set the `SEPOLIA_PRIVATE_KEY` config variable using `hardhat-keystore`:

```shell
npx hardhat keystore set SEPOLIA_PRIVATE_KEY
```

After setting the variable, you can run the deployment with the Sepolia network:

## command to deploy the contract

```shell
npx hardhat ignition deploy --network testnet ignition/modules/PicknGet.ts
```

```shell
Deployed txn hash:
0x7e28dcc10fad7b6b66a8fc76f74881f52407fbfa20ccdd7b330c882deaef630d
```

## contract address
```shell
contract deployed to: 0x82B63E09E740302eb91116d7CC0E7039946Db134
```

```shell
See details in hashscan : 
 https://hashscan.io/testnet/address/0x82B63E09E740302eb91116d7CC0E7039946Db134
 ```


## command to get the metadata
```shell
solc --bin --abi --metadata -o ./contracts ./contracts/PicknGet.sol ./contracts/Admin.sol ./contracts/Product.sol ./contracts/User.sol ./contracts/library/ItemLib.sol
```

## command to get the metadata for stack too deep error
```shell
solc --bin --abi --metadata --via-ir -o ./contracts ./contracts/PicknGet.sol ./contracts/Admin.sol ./contracts/Product.sol ./contracts/User.sol ./contracts/library/ItemLib.sol 
```

## contract abi
```shell
https://hashscan.io/testnet/contract/0.0.7110475/abi
```

##
```shell
Deploying contract...
Product contract deployed at: 0xBB5eD93236774816D11ba68D80923a8eCf27C484
Product Deployment Tx Hash: 0x7da18a40cc71243d1aa07a50b655572b7cac996f9c835e6623a48a12bd024039

See product details in hashscan : 
 https://hashscan.io/testnet/address/0xBB5eD93236774816D11ba68D80923a8eCf27C484 
 ```

 ## Product contract abi
 ```shell
 https://hashscan.io/testnet/contract/0.0.7110490/abi
 ```



