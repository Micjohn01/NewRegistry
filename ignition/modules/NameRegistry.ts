import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const MicjohnModule = buildModule("MicjohnModule", (m) => {

    const name = m.contract("NameRegistry");

    return { name };
});

export default MicjohnModule;