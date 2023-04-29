import nonClient from ".";
import { VALID_CONTRACTS } from "../../config/constants";
import { ContractContainer } from "../../types";
import utility from "../../utility"
import deploy from "./deploy";
import getContractsFromDb from "./getContractsFromDb";

/**
 * Executes non-client functions such as deployment, coordination, and marketplace setting
 * @param {any} inputArgs - The input arguments for non-client functions
 * @returns {Promise<void>}
 */
const main = async (inputArgs: any): Promise<void> => {
    utility.printFancy("Non-Client Functions", true, 1);

    // Allow user to read the console
    await new Promise((resolve) => setTimeout(resolve, 5000));

    // Non-package client commands
    let contracts: ContractContainer = await getContractsFromDb({});

    if (inputArgs.deploy) {
        try {
            const deployedContracts: ContractContainer = await deploy(inputArgs.deploy);
            contracts = { ...contracts, ...deployedContracts };
        } catch (error) {
            console.error("Error deploying contracts:", error);
            throw error;
        }
    }

    if (inputArgs.coordinate) {
        const validContracts: string[] = inputArgs.coordinate;
        if (validContracts.length < 1) throw new Error("No valid coordinator inputs");

        try {
            // Create a new ContractCoordinator instance with the matching inputs as keys
            const contractsToBeCoordinated: ContractContainer = Object.fromEntries(
                Object.entries(contracts).filter(([key]) => validContracts.includes(key))
            );
            // await nonClient.coordinator(contractsToBeCoordinated);
        } catch (error) {
            console.error("Error coordinating contracts:", error);
            throw error;
        }
    }

    if (inputArgs.marketplace) {
        const validContracts: string[] = inputArgs.marketplace;
        if (validContracts.length < 1) throw new Error("No valid coordinator inputs");

        try {
            const contractsToBeCoordinated: ContractContainer = Object.fromEntries(
                Object.entries(contracts).filter(([key]) => validContracts.includes(key))
            );
            await nonClient.coordinator.marketplace.setAllowedContracts(contracts[VALID_CONTRACTS.EscrowERC721], contractsToBeCoordinated, VALID_CONTRACTS.EscrowERC721);
        } catch (error) {
            console.error("Error setting marketplace allowed contracts:", error);
            throw error;
        }
    }
}


export default main