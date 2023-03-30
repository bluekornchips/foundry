import collections from "../../../collections";
import { VALID_CONTRACTS } from "../../../config/constants";
import { ContractContainer } from "../../../types"
import { ethers } from "ethers";
import utility from "../../../utility";

/**
 * Orchestrates the coordination logic between contracts.
 *
 * @param contracts - The contracts to coordinate.
 */
const coordinate = async (contracts: ContractContainer) => {
    utility.printFancy("Coordinator", true, 1)
    for (const contract_name in contracts) {
        switch (contract_name) {
            case VALID_CONTRACTS.ClancyERC721:
                await clancyERC721(contracts[contract_name])
                break;
            case VALID_CONTRACTS.MarketplaceERC721Escrow_v1:
                // await marketplaceERC721Escrow_v1(contracts[contract_name], contracts)
                break;
            default:
                break;
        }
    }
}

/**
 * Sets the public mint status of the ClancyERC721 contract.
 *
 * @param contract - The ClancyERC721 contract instance.
 */
const clancyERC721 = async (contract: ethers.Contract) => {
    const mintStatus = utility.getCollectionConfigs().Clancy.ERC.ClancyERC721.publicMintStatus
    await collections.clancy.ERC.ClancyERC721.setPublicMintStatus(contract, mintStatus)
}


export default coordinate