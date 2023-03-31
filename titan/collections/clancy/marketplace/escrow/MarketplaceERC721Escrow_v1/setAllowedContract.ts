import { ethers } from "ethers"
import Ducky from "../../../../../utility/logging/ducky";

const FILE_DIR = "titan/collections/clancy/marketplace/escrow/MarketplaceERC721Escrow_v1"

/**
 * Sets the allowed state of a token contract on a MarketplaceERC721Escrow_V1 contract.
 * @param marketplace_contract The MarketplaceERC721Escrow_V1 contract object.
 * @param token_contract The token contract object to set the allowed state for.
 * @param allowed The desired allowed state of the token contract.
 * @returns `true` if the allowed state was set successfully.
 * @throws If the allowed state could not be set.
 */
const setAllowedContract = async (marketplace_contract: ethers.Contract, token_contract: ethers.Contract, allowed: boolean): Promise<boolean> => {
    Ducky.Debug(FILE_DIR, "setAllowedContract", `Setting allowed state of ${await token_contract.name()} to ${allowed} on MarketplaceERC721Escrow_V1: ${await marketplace_contract.getAddress()}`);
    try {
        const setAllowedContractResponse = await marketplace_contract.setAllowedContract(await token_contract.getAddress(), allowed); // Set the allowed state of the token contract on the MarketplaceERC721Escrow_V1 contract.
        await setAllowedContractResponse.wait(); // Wait for the transaction to be confirmed.
        Ducky.Debug(FILE_DIR, "setAllowedContract", `Allowed state of ${await token_contract.name()} set to ${allowed} on MarketplaceERC721Escrow_V1: ${await marketplace_contract.getAddress()}`);
        return true;
    } catch (error: any) {
        const message = `Could not set allowed state of ${await token_contract.name()} to ${allowed} on MarketplaceERC721Escrow_V1 at address ${await marketplace_contract.getAddress()}`;
        Ducky.Error(FILE_DIR, "setAllowedContract", message);
        throw new Error(message);
    }
}


export default setAllowedContract;