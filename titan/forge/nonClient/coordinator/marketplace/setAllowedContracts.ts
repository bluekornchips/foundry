import { ethers } from "ethers";
import utility from "../../../../utility";
import { ContractContainer } from "../../../../types";
import collections from "../../../../collections";

const setAllowedContracts = async (marketplace_contract: ethers.Contract, contracts: ContractContainer, marketplaceName: string) => {
    utility.printFancy("Marketplace", true, 1)
    for (const contract in contracts) {
        await collections.clancy.marketplace.setVendorStatus(marketplace_contract, contracts[contract], true, marketplaceName);
    }
}

export default setAllowedContracts