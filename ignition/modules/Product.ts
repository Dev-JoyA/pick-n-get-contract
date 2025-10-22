import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("ProductModule", (m) => {

  const product = m.contract("Product");

  return { product };
});
