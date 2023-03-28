import { ethers } from "ethers"
import { Ducky } from "../../../../../client/logging/ducky/ducky";

const FILE_DIR = "titan/collections/clancy/marketplace/escrow/MarketplaceERC721Escrow_v1"

/**
 * @dev Sets the allowed state of a given contract in the specified marketplace contract
 * @param marketplace_contract The marketplace contract instance
 * @param token_contract The contract instance to set the allowed state for
 * @param allowed Whether the contract is allowed or not
 * @return A boolean indicating whether the operation was successful or not
 * @throws If there is an error setting the allowed state of the contract in the marketplace contract
 */
const setAllowedContract = async (marketplace_contract: ethers.Contract, token_contract: ethers.Contract, allowed: boolean): Promise<boolean> => {
    Ducky.Debug(FILE_DIR, "setAllowedContract", `Setting allowed state of ${await token_contract.name()} to ${allowed} on MarketplaceERC721Escrow_V1: ${await marketplace_contract.getAddress()}`);
    try {
        const setAllowedContractResponse = await marketplace_contract.setAllowedContract(await token_contract.getAddress(), allowed);
        await setAllowedContractResponse.wait();
        Ducky.Debug(FILE_DIR, "setAllowedContract", `Allowed state of ${await token_contract.name()} set to ${allowed} on MarketplaceERC721Escrow_V1: ${await marketplace_contract.getAddress()}`)
        return true;
    } catch (error: any) {
        Ducky.Error(FILE_DIR, "setAllowedContract", error.message)
        throw new Error(error.message);
    }
}

export default setAllowedContract;