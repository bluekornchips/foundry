import { Ducky } from "../../../client/logging/ducky";
import collections from "../../../collections";
import { IEuroleagueConfig } from "../../../interfaces";
import { ContractContainer } from "../../../types";
import utility from "../../../utility";
import { ethers } from "ethers";
import deploy_moments from "./moments";
import deploy_series1_case from "./series1case";

const FILE_DIR = "titan/forge/clients/Euroleague"

/**
 * Deploy the Euroleague collection of ERC-721 tokens.
 */
const deploy = async () => {
    // Print a fancy header indicating which collection is being deployed.
    utility.printFancy("Euroleague", true, 1);

    // Get the configuration for the Euroleague collection.
    const euroleagueConfig = utility.getCollectionConfigs().Euroleague

    try {
        // Deploy the Euroleague Moments ERC-721 token.
        const moments = await deploy_moments(euroleagueConfig)

        // Deploy the series of ERC-721 tokens representing Euroleague cases.
        const series1case = await deploy_series1_case(euroleagueConfig)

        // Log a success message indicating that the deployment completed.
        console.log("Euroleague collection successfully deployed.")
    } catch (error: any) {
        // Log an error message if the deployment fails and re-throw the error.
        Ducky.Error(FILE_DIR, "deploy", `Failed to deploy Euroleague collection: ${error.message}`);
        throw new Error(`Failed to deploy Euroleague collection: ${error.message}`);
    }
}







export default deploy