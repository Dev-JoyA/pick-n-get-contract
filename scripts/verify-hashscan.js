import fs from "fs";
import path from "path";

const buildInfoPath = path.resolve(
  "./artifacts/build-info/solc-0_8_28-93d9eb994af19b1b650006f1be0c9ac329e1193d.json"
);

const buildInfo = JSON.parse(fs.readFileSync(buildInfoPath, "utf8"));

// Pick your contract (match exact path from Hardhat)
const contractPath = "contracts/EcoClean.sol"; // usually relative to the root of your project
const contractName = "EcoClean";

// Hardhat stores metadata in buildInfo.output.contracts[contractPath][contractName].metadata
const metadataStr = buildInfo.contracts[contractPath][contractName].metadata;

fs.writeFileSync("metadata.json", metadataStr);

console.log("✅ metadata.json created successfully");
