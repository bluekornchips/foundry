import { ethers } from "ethers";
import { Ducky } from "../../client/logging/ducky";
import collections from "../../collections";
import { VALID_CONTRACTS } from "../../config/constants";
import utility from "../../utility";
import { ContractContainer } from "../../types";

const deploy = async (contract_names: string[]): Promise<ContractContainer> => {
    console.log(utility.printRepeated("="))
    console.log(utility.printFancy("Deployment", true))
    console.log(utility.printRepeated("="))

    const contracts: ContractContainer = {}

    for (const contract_name of contract_names) {
        contracts[contract_name] = await deploy_contract(contract_name)
    }

    return contracts
}

const deploy_contract = async (contract_name: string): Promise<ethers.Contract> => {
    switch (contract_name) {
        case VALID_CONTRACTS.MarketplaceERC721Escrow_v1:
            const marketplace: ethers.Contract = await collections.clancy.marketplace.escrow.MarketplaceERC721Escrow_v1.deploy();
            return marketplace;
        case VALID_CONTRACTS.ClancyERC721:
            const erc721: ethers.Contract = await collections.clancy.ERC.ClancyERC721.deploy();
            return erc721;
        default:
            const message = `Contract ${contract_name} not found`;
            Ducky.Error("Deployment", "main", message);
            throw new Error(message);
    }
}

export default deploy;