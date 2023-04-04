import { ethers } from "ethers";
import getPublicMintStatus from "./getPublicMintStatus";
import Ducky from "../../../../utility/logging/ducky";

/**
 * Sets the public mint status of a contract to the specified value.
 * @param contract The contract object to set the status for.
 * @param status The desired public mint status of the contract.
 * @throws If the public mint status could not be set.
 */
const setPublicMintStatus = async (contract: ethers.Contract, status: boolean) => {
    try {
        const isPublicMintingEnabled: boolean = await getPublicMintStatus(contract); // Retrieve the current public mint status of the contract.
        if (isPublicMintingEnabled === status) {
            Ducky.Debug(__filename, "setPublicMintStatus", `Public mint status for ${await contract.name()} is already ${status}`);
            return;
        }
        Ducky.Debug(__filename, "setPublicMintStatus", `Setting public mint status for ${await contract.name()} to ${status}`);
        const setPublicMintStatusTx = await contract.setPublicMintStatus(status); // Set the public mint status of the contract to the desired value.
        await setPublicMintStatusTx.wait(); // Wait for the transaction to be confirmed.
        Ducky.Debug(__filename, "setPublicMintStatus", `Set public mint status for ${await contract.name()} to ${await getPublicMintStatus(contract)}`);
    } catch (error: any) {
        const message = `Could not setPublicMintStatus for contract at address ${contract.address}`;
        Ducky.Error(__filename, "setPublicMintStatus", message);
        throw new Error(message);
    }
}

export default setPublicMintStatus