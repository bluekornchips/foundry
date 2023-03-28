import { ethers } from "ethers";
import { Ducky } from "../../../../client/logging/ducky";

const FILE_DIR = "titan/collections/clancy/ERC/ClancyERC721";

/**
 * @dev Gets the public mint status of the specified contract
 * @param contract The contract instance to get the public mint status for
 * @return A Promise resolving to a boolean indicating whether public minting is allowed or not
 * @throws If there is an error getting the public mint status
 */
const getPublicMintStatus = async (contract: ethers.Contract): Promise<boolean> => {
    try {
        const publicMintStatus = await contract.getPublicMintStatus()
        Ducky.Debug(FILE_DIR, "getPublicMintStatus", `${await contract.name()}.publicMintStatus is ${publicMintStatus}`)
        return publicMintStatus
    } catch (error: any) {
        const message = `Could not getPublicMintStatus for ${contract.address}`;
        Ducky.Critical(FILE_DIR, "coordinator", message);
        throw new Error(message);
    }
}

export default getPublicMintStatus