console.clear()

import { createRequire } from "module";
const require = createRequire(import.meta.url);
require("dotenv").config();


import { ethers} from "ethers";
import fs from "fs";

const abi = fs.readFileSync("./contracts/EcoClean.abi").toString();
const bytecode = fs.readFileSync("./contracts/EcoClean.bin").toString();

const network = "testnet";
const explorerURL = `https://hashscan.io/${network}`;

const provider = new ethers.JsonRpcProvider(`https://${network}.hashio.io/api`);
const signer = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

async function main() {
    const newContract = new ethers.Contract("0x2f15f1b055903a1A07b9b08F6540ea633921Ea77", abi, signer);

    console.log(`Contract deployed to: ${newContract.target}\n`);
    console.log(`See details in hashscan : \n ${explorerURL}/address/${newContract.target} \n`);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

