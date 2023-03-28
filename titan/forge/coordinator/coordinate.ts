import collections from "../../collections";
import { VALID_CONTRACTS } from "../../config/constants";
import { ContractContainer } from "../../types"
import { ethers } from "ethers";
import utility from "../../utility";

const coordinate = async (contracts: ContractContainer) => {
    console.log(utility.printRepeated("="))
    console.log(utility.printFancy("Coordinator", true))
    console.log(utility.printRepeated("="))
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

const clancyERC721 = async (contract: ethers.Contract) => {
    await collections.clancy.ERC.ClancyERC721.setPublicMintStatus(contract)
}



export default coordinate