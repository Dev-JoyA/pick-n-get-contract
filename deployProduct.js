console.clear()

import { createRequire } from "module";
const require = createRequire(import.meta.url);
require("dotenv").config();


import { ethers} from "ethers";
import fs from "fs";

const abi = fs.readFileSync("./contracts/Product.abi").toString();
const bytecode = fs.readFileSync("./contracts/Product.bin").toString();

const network = "testnet";
const explorerURL = `https://hashscan.io/${network}`;

const provider = new ethers.JsonRpcProvider(`https://${network}.hashio.io/api`);
const signer = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
const metadata = fs.readFileSync("./artifacts/contracts/Product.sol/Product.json", "utf8");
const source = fs.readFileSync("./contracts/Product.sol", "utf8");

async function main() {
    console.log("Deploying contract...");
    const factory = new ethers.ContractFactory(abi, bytecode, signer);
    const contract = await factory.deploy();
    await contract.waitForDeployment();
    const contractAddress = await contract.getAddress();
    const deployTxHash = contract.deploymentTransaction().hash;

    console.log(`Product contract deployed at: ${contractAddress}`);
    console.log(`Product Deployment Tx Hash: ${deployTxHash}`);
    const body = {
      address: contractAddress,
    chain: "296", 
    files: {
      "metadata.json": metadata,
      "Product.sol": source
    },
    creatorTxHash: deployTxHash,
    chosenContract: "Product"
  };

    console.log(`Product Contract deployed to: ${contractAddress}\n`);
    console.log(`See product details in hashscan : \n ${explorerURL}/address/${contractAddress} \n`);

    
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

