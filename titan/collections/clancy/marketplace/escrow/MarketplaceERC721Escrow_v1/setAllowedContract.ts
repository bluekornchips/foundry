import { ethers } from "ethers"
import { Ducky } from "../../../../../client/logging/ducky/ducky";

const FILE_DIR = "titan/collections/clancy/marketplace/escrow/MarketplaceERC721Escrow_v1"

/**
 * @dev Sets the allowed state of a given contract in the specified marketplace contract
 * @param marketplace_contract The marketplace contract instance
 * @param contract The contract instance to set the allowed state for
 * @param allowed Whether the contract is allowed or not
 * @return A boolean indicating whether the operation was successful or not
 * @throws If there is an error setting the allowed state of the contract in the marketplace contract
 */
const setAllowedContract = async (marketplace_contract: ethers.Contract, contract: ethers.Contract, allowed: boolean): Promise<boolean> => {
    try {
        const setAllowedContractResponse = await marketplace_contract.setAllowedContract(contract, allowed);
        Ducky.Debug(FILE_DIR, "setAllowedContract", `setAllowedContractResponse: ${setAllowedContractResponse}`);
        return true;
    } catch (error: any) {
        Ducky.Error(FILE_DIR, "setAllowedContract", error.message)
        throw new Error(error.message);
    }
}

export default setAllowedContract;