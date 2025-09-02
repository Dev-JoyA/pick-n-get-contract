import { network } from "hardhat";
import { pid } from "process";

const { ethers } = await network.connect({
  network: "hardhatOp",
  chainType: "op",
});

async function main() {
  // ERC20 ABI fragment for balanceOf
  const abi = [
    "function balanceOf(address) view returns (uint256)"
  ];

  // Create an Interface
  const iface = new ethers.Interface(abi);

  // Encode calldata for balanceOf(user)
  const user = "0x61B2Aa17C1c1114E7583bB31F777FF4bDc7AB717";
  const calldata = iface.encodeFunctionData("balanceOf", [user]);

  const bal = "0x0000000000000000000000000000000000000000000000000000b5e620f48000"
  const decode = iface.decodeFunctionResult("balanceOf", bal);
  const humanBalance = ethers.formatUnits(decode[0], 6);
  
  console.log("Human-readable balance:", humanBalance, "USDT");

  console.log("Calldata:", calldata);
  console.log("Decoded:", decode);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
