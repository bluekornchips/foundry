import { ethers } from "ethers";

import getBurnStatus from "./getBurnStatus";
import Ducky from "../../../../utility/logging/ducky";

/**
 * Sets the public burn status of a contract to the specified value.
 * @param contract The contract object to set the status for.
 * @param status The desired public burn status of the contract.
 * @throws If the public burn status could not be set.
 */
const setBurnStatus = async (contract: ethers.Contract, status: boolean) => {
    try {
        const isBurningEnabled: boolean = await getBurnStatus(contract); // Retrieve the current public burn status of the contract.
        if (isBurningEnabled === status) {
            Ducky.Debug(__filename, "setBurnStatus", ` burn status for ${await contract.name()} is already ${status}`);
            return;
        }
        Ducky.Debug(__filename, "setBurnStatus", `Setting public burn status for ${await contract.name()} to ${status}`);
        const setBurnStatusTx = await contract.setBurnStatus(status); // Set the public burn status of the contract to the desired value.
        await setBurnStatusTx.wait(); // Wait for the transaction to be confirmed.
        Ducky.Debug(__filename, "setBurnStatus", `Set public burn status for ${await contract.name()} to ${await getBurnStatus(contract)}`);
    } catch (error: any) {
        const message = `Could not setBurnStatus for contract at address ${contract.address}`;
        Ducky.Error(__filename, "setBurnStatus", message);
        throw new Error(message);
    }
}

export default setBurnStatus