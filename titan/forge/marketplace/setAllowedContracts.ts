import collections from "../../collections";
import { ContractContainer } from "../../types";
import utility from "../../utility";
import { ethers } from "ethers";

const setAllowedContracts = async (marketplace_contract: ethers.Contract, contracts: ContractContainer) => {
    console.log(utility.printRepeated("="))
    console.log(utility.printFancy("Marketplace", true))
    console.log(utility.printRepeated("="))
    // Collect all contracts in contractContainer with a validForSale value of true
    const contract_options = utility.getContractOptions()
    for (const contract in contracts) {
        if (contract_options[contract].validForSale)
            await collections.clancy.marketplace.escrow.MarketplaceERC721Escrow_v1.setAllowedContract(marketplace_contract, contracts[contract], true)
    }
}

export default setAllowedContracts