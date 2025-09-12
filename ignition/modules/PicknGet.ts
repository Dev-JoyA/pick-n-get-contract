import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("PicknGetModule", (m) => {

  const picknget = m.contract("PicknGet");

  return { picknget };
});
