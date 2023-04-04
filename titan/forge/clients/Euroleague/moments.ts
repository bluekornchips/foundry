import { ethers } from "ethers"

import collections from "../../../collections"
import Ducky from "../../../utility/logging/ducky"
import { IEuroleagueConfig } from "../../../interfaces"

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
        const moments = await collections.euroleague.series1.moments.deploy(name, symbol, max_supply, uri, 0)
        return moments
    } catch (error: any) {
        // Log an error message if the deployment fails and re-throw the error.
        Ducky.Error(__filename, "moments", `Failed to deploy ${name}: ${error.message}`);
        throw new Error(`Failed to deploy ${name}: ${error.message}`);
    }
}

export default deploy_moments