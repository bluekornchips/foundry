import { ethers } from "ethers";
import publicMintEnabled from "./publicMintEnabled";
import Ducky from "../../../../utility/logging/ducky";

/**
 * Sets the public mint status of a contract to the specified value.
 * @param contract The contract object to set the status for.
 * @param status The desired public mint status of the contract.
 * @throws If the public mint status could not be set.
 */
const setPublicMintEnabled = async (contract: ethers.Contract, status: boolean) => {
    try {
        const isPublicMintingEnabled: boolean = await publicMintEnabled(contract); // Retrieve the current public mint status of the contract.
        if (isPublicMintingEnabled === status) {
            Ducky.Debug(__filename, "setPublicMintEnabled", `Public mint status for ${await contract.name()} is already ${status}`);
            return;
        }
        Ducky.Debug(__filename, "setPublicMintEnabled", `Setting public mint status for ${await contract.name()} to ${status}`);
        const setPublicMintEnabledTx = await contract.setPublicMintEnabled(status); // Set the public mint status of the contract to the desired value.
        await setPublicMintEnabledTx.wait(); // Wait for the transaction to be confirmed.
        Ducky.Debug(__filename, "setPublicMintEnabled", `Set public mint status for ${await contract.name()} to ${await publicMintEnabled(contract)}`);
    } catch (error: any) {
        const message = `Could not setPublicMintEnabled for contract at address ${contract.address}`;
        Ducky.Error(__filename, "setPublicMintEnabled", message);
        throw new Error(message);
    }
}

export default setPublicMintEnabled