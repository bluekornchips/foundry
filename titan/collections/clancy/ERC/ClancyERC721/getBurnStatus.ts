import { ethers } from "ethers";

import Ducky from "../../../../utility/logging/ducky";

/**
 * Retrieves the public burn status of a contract.
 * @param contract The contract object to retrieve the status from.
 * @returns The public burn status of the contract.
 * @throws If the public burn status could not be retrieved.
 */
const getBurnStatus = async (contract: ethers.Contract): Promise<boolean> => {
    try {
        const isBurningEnabled = await contract.getBurnStatus(); // Retrieve the public burn status of the contract.
        Ducky.Debug(__filename, "getBurnStatus", `${await contract.name()}.publicBurnStatus is ${isBurningEnabled}`);
        return isBurningEnabled;
    } catch (error: any) {
        const message = `Could not getBurnStatus for contract at address ${contract.address}`;
        Ducky.Error(__filename, "getBurnStatus", message);
        throw new Error(message);
    }
}

export default getBurnStatus