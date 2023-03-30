import { ethers } from "ethers"
import { Ducky } from "../../../client/logging/ducky"
import collections from "../../../collections"
import { IEuroleagueConfig } from "../../../interfaces"

const FILE_DIR = "titan/forge/clients/Euroleague"

/**
 * Deploy the Euroleague Moments ERC-721 token based on the configuration in the provided IEuroleagueConfig object.
 *
 * @param config The IEuroleagueConfig object containing the configuration for the Euroleague Moments ERC-721 token.
 * @returns A contract object representing the deployed Euroleague Moments ERC-721 token.
 */
const deploy_moments = async (config: IEuroleagueConfig): Promise<ethers.Contract> => {
    // Get the configuration for the Euroleague Moments ERC-721 token.
    const moments_config = config.ERC.Moments

    // Create an object with the arguments needed to deploy the ERC-721 token.
    const { name, symbol, max_supply, uri } = moments_config.cargs

    try {
        // Deploy the Euroleague Moments ERC-721 token and return the contract object.
        const moments = await collections.euroleague.series1.moments.deploy(name, symbol, max_supply, uri)
        return moments
    } catch (error: any) {
        // Log an error message if the deployment fails and re-throw the error.
        Ducky.Error(FILE_DIR, "moments", `Failed to deploy ${name}: ${error.message}`);
        throw new Error(`Failed to deploy ${name}: ${error.message}`);
    }
}

export default deploy_moments