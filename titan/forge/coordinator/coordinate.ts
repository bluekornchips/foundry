import collections from "../../collections";
import { VALID_CONTRACTS } from "../../config/constants";
import { ContractContainer } from "../../types"
import { ethers } from "ethers";

const coordinate = async (contracts: ContractContainer): Promise<ContractContainer> => {
    for (const contract_name in contracts) {
        switch (contract_name) {
            case VALID_CONTRACTS.ClancyERC721:
                await clancyERC721(contracts[contract_name])
                break;
            case VALID_CONTRACTS.MarketplaceERC721Escrow_v1:

            default:
                break;
        }
    }
    return contracts
}

const clancyERC721 = async (contract: ethers.Contract) => {
    // Set the public mint status
    await collections.clancy.ERC.ClancyERC721.setPublicMintStatus(contract)
}

const marketplaceERC721Escrow_v1 = async (contract: ethers.Contract, contracts: ContractContainer) => {
}


export default coordinate