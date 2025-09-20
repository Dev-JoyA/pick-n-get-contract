// checksize.js
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

// Recreate __dirname in ESM
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Path to Hardhat artifacts folder
const artifactsPath = path.join(__dirname, "artifacts/contracts");

// Recursively get all JSON files inside artifacts
function getAllJsonFiles(dir) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  return entries.flatMap((entry) => {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      return getAllJsonFiles(fullPath);
    } else if (entry.name.endsWith(".json")) {
      return [fullPath];
    }
    return [];
  });
}

// Loop over JSON files and report deployed bytecode size
for (const file of getAllJsonFiles(artifactsPath)) {
  const content = JSON.parse(fs.readFileSync(file, "utf8"));
  if (content.deployedBytecode) {
    const hex = content.deployedBytecode;
    const bytes = hex.length / 2 - 1; // subtract "0x"
    console.log(
      path.basename(file, ".json"),
      "=>",
      bytes,
      "bytes"
    );
  }
}
