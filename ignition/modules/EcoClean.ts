import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("EcoCleanModule", (m) => {
    
  const ecoClean = m.contract("EcoClean");

  return { ecoClean };
});
