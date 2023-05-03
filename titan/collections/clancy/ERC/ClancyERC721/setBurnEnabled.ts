import { ethers } from "ethers";

import burnEnabled from "./burnEnabled";
import Ducky from "../../../../utility/logging/ducky";

/**
 * Sets the public burn status of a contract to the specified value.
 * 
 * @param contract  The contract object to set the status for.
 * @param status    The desired public burn status of the contract.
 * @throws          If the public burn status could not be set.
 */
const setBurnEnabled = async (contract: ethers.Contract, status: boolean) => {
    try {
        const isBurningEnabled: boolean = await burnEnabled(contract); // Retrieve the current public burn status of the contract.
        if (isBurningEnabled === status) {
            Ducky.Debug(__filename, "setBurnEnabled", ` burn status for ${await contract.name()} is already ${status}`);
            return;
        }
        Ducky.Debug(__filename, "setBurnEnabled", `Setting public burn status for ${await contract.name()} to ${status}`);
        const setBurnEnabledTx = await contract.setBurnEnabled(status); // Set the public burn status of the contract to the desired value.
        await setBurnEnabledTx.wait(); // Wait for the transaction to be confirmed.
        Ducky.Debug(__filename, "setBurnEnabled", `Set public burn status for ${await contract.name()} to ${await burnEnabled(contract)}`);
    } catch (error: any) {
        const message = `Could not setBurnEnabled for contract at address ${contract.address}`;
        Ducky.Error(__filename, "setBurnEnabled", message);
        throw new Error(message);
    }
}

export default setBurnEnabled