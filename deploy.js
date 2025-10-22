console.clear()

import { createRequire } from "module";
const require = createRequire(import.meta.url);
require("dotenv").config();


import { ethers} from "ethers";
import fs from "fs";

const abi = fs.readFileSync("./contracts/PicknGet.abi").toString();
const bytecode = fs.readFileSync("./contracts/PicknGet.bin").toString();

const network = "testnet";
const explorerURL = `https://hashscan.io/${network}`;

const provider = new ethers.JsonRpcProvider(`https://${network}.hashio.io/api`);
const signer = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
const metadata = fs.readFileSync("./artifacts/contracts/PicknGet.sol/PicknGet.json", "utf8");
const source = fs.readFileSync("./contracts/PicknGet.sol", "utf8");

async function main() {
    console.log("Deploying contract...");
    const factory = new ethers.ContractFactory(abi, bytecode, signer);
    const contract = await factory.deploy(process.env.SUPER_ADMIN_ADDRESS);
    await contract.waitForDeployment();
    const contractAddress = await contract.getAddress();
    const deployTxHash = contract.deploymentTransaction().hash;

    console.log(`PicknGet Contract deployed at: ${contractAddress}`);
    console.log(`PicknGet Deployment Tx Hash: ${deployTxHash}`);
    const body = {
      address: contractAddress,
    chain: "296", 
    files: {
      "metadata.json": metadata,
      "PicknGet.sol": source
    },
    creatorTxHash: deployTxHash,
    chosenContract: "PicknGet"
  };

    console.log(`PicknGet Contract deployed to: ${contractAddress}\n`);
    console.log(`See picknGet details in hashscan : \n ${explorerURL}/address/${contractAddress} \n`);

    
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

