import { ethers } from "ethers";
import { Ducky } from "../../../../client/logging/ducky";
import getContractOptions from "../../../../utility/getContractOptions";
import getPublicMintStatus from "./getPublicMintStatus";

const FILE_DIR = "titan/collections/clancy/ERC/ClancyERC721";

/**
 * @dev Sets the public mint status of the specified contract to the specified value
 * @param contract The contract instance to set the public mint status for
 * @param options.ClancyERC721.publicMintStatus Whether public minting is allowed or not
 * @throws If there is an error setting the public mint status
 */
const setPublicMintStatus = async (contract: ethers.Contract) => {
    try {
        // First check if this needs to be executed
        const options = getContractOptions()
        const publicMintStatus: boolean = await getPublicMintStatus(contract);
        if (publicMintStatus === options.ClancyERC721.publicMintStatus) {
            Ducky.Debug(FILE_DIR, "setPublicMintStatus", `Public mint status for ${await contract.name()} is already ${options.ClancyERC721.publicMintStatus}`)
            return
        }
        Ducky.Debug(FILE_DIR, "setPublicMintStatus", `Setting public mint status for ${await contract.name()} to ${options.ClancyERC721.publicMintStatus}`)
        const setPublicMintStatus = await contract.setPublicMintStatus(options.ClancyERC721.publicMintStatus)
        await setPublicMintStatus.wait()
        Ducky.Debug(FILE_DIR, "setPublicMintStatus", `Set public mint status for ${await contract.name()} to ${options.ClancyERC721.publicMintStatus}`)
    } catch (error: any) {
        const message = `Could not setPublicMintStatus for ${contract.address}`;
        Ducky.Critical(FILE_DIR, "coordinator", message);
        throw new Error(message);
    }
}

export default setPublicMintStatus