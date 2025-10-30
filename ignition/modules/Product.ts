import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";


const pickngetContract = "0x82B63E09E740302eb91116d7CC0E7039946Db134";
export default buildModule("ProductModule", (m) => {

  const picknget = m.getParameter("pickngetContract", pickngetContract)
  const product = m.contract("Product", [picknget]);

  return { product };
});
