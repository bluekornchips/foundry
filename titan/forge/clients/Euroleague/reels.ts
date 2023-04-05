import { ethers } from "ethers"

import collections from "../../../collections"
import Ducky from "../../../utility/logging/ducky"
import { IEuroleagueConfig } from "../../../interfaces"

/**
 * Deploy the Euroleague Reels ERC-721 token based on the configuration in the provided IEuroleagueConfig object.
 *
 * @param config The IEuroleagueConfig object containing the configuration for the Euroleague Reels ERC-721 token.
 * @returns A contract object representing the deployed Euroleague Reels ERC-721 token.
 */
const deploy_Reels = async (config: IEuroleagueConfig): Promise<ethers.Contract> => {
    // Get the configuration for the Euroleague Reels ERC-721 token.
    const Reels_config = config.ERC.Reels

    // Create an object with the arguments needed to deploy the ERC-721 token.
    const { name, symbol, max_supply, uri } = Reels_config.cargs

    try {
        // Deploy the Euroleague Reels ERC-721 token and return the contract object.
        const Reels = await collections.euroleague.series1.reels.deploy(name, symbol, max_supply, uri, 0)
        return Reels
    } catch (error: any) {
        // Log an error message if the deployment fails and re-throw the error.
        Ducky.Error(__filename, "Reels", `Failed to deploy ${name}: ${error.message}`);
        throw new Error(`Failed to deploy ${name}: ${error.message}`);
    }
}

export default deploy_Reels