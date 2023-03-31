import { ethers } from "ethers";
import Ducky from "../../../../utility/logging/ducky";

const FILE_DIR = "titan/collections/clancy/ERC/ClancyERC721";

/**
 * Retrieves the public mint status of a contract.
 * @param contract The contract object to retrieve the status from.
 * @returns The public mint status of the contract.
 * @throws If the public mint status could not be retrieved.
 */
const getPublicMintStatus = async (contract: ethers.Contract): Promise<boolean> => {
    try {
        const isPublicMintingEnabled = await contract.getPublicMintStatus(); // Retrieve the public mint status of the contract.
        Ducky.Debug(FILE_DIR, "getPublicMintStatus", `${await contract.name()}.publicMintStatus is ${isPublicMintingEnabled}`);
        return isPublicMintingEnabled;
    } catch (error: any) {
        const message = `Could not getPublicMintStatus for contract at address ${contract.address}`;
        Ducky.Error(FILE_DIR, "getPublicMintStatus", message);
        throw new Error(message);
    }
}


export default getPublicMintStatus