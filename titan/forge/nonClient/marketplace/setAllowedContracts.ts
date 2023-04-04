import collections from "../../../collections";
import { ContractContainer } from "../../../types";
import { ethers } from "ethers";
import utility from "../../../utility";

const setAllowedContracts = async (marketplace_contract: ethers.Contract, contracts: ContractContainer) => {
    utility.printFancy("Marketplace", true, 1)
    const configs = utility.getCollectionConfigs()
    for (const contract in contracts) {
        await collections.clancy.marketplace.escrow.MarketplaceERC721Escrow_v1.setAllowedContract(marketplace_contract, contracts[contract], true)
    }
}

export default setAllowedContracts