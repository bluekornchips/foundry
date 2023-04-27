import { ethers } from "ethers"

import Ducky from "../../../utility/logging/ducky";

/**
 * Sets the allowed state of a token contract on a Marketplace contract.
 * @param marketplace_contract The Marketplace contract object.
 * @param token_contract The token contract object to set the allowed state for.
 * @param allowed The desired allowed state of the token contract.
 * @returns `true` if the allowed state was set successfully.
 * @throws If the allowed state could not be set.
 */
const setVendorStatus = async (marketplace_contract: ethers.Contract, token_contract: ethers.Contract, allowed: boolean, marketplace_name: string): Promise<boolean> => {
    Ducky.Debug(__filename, "setVendorStatus", `Setting allowed state of ${await token_contract.name()} ${await token_contract.getAddress()} to ${allowed} on ${marketplace_name}: ${await marketplace_contract.getAddress()}`);
    try {
        const setAllowedContractResponse = await marketplace_contract.setVendorStatus(await token_contract.getAddress(), allowed); // Set the allowed state of the token contract on the Marketplace contract.
        await setAllowedContractResponse.wait(); // Wait for the transaction to be confirmed.
        const allowedStatus: boolean = await marketplace_contract.vendors(await token_contract.getAddress()); // Get the allowed state of the token contract on the Marketplace contract.
        Ducky.Debug(__filename, "setVendorStatus", `Allowed state of ${await token_contract.name()} set to ${allowedStatus} on ${marketplace_name}: ${await marketplace_contract.getAddress()}`);
        return true;
    } catch (error: any) {
        const message = `Could not set allowed state of ${await token_contract.name()} to ${allowed} on ${marketplace_name} at address ${await marketplace_contract.getAddress()}`;
        Ducky.Error(__filename, "setVendorStatus", error);
        throw new Error(message);
    }
}


export default setVendorStatus;