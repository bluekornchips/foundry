import utility from "../../../utility";
import deploy_moments from "./moments";
import deploy_series1_case from "./series1case";
import Ducky from "../../../utility/logging/ducky";
import { ContractContainer } from "../../../types";
import collections from "../../../collections";
import getActiveEnv from "../../env";

const FILE_DIR = "titan/forge/clients/Euroleague"

/**
 * Deploy the Euroleague collection of ERC-721 tokens.
 */
const deploy = async () => {
    utility.printFancy(`Euroleague - ${getActiveEnv().env}`, true);

    // Get the configuration for the Euroleague collection.
    const euroleagueConfig = utility.getCollectionConfigs().Euroleague

    try {
        // Deploy the Euroleague Moments ERC-721 token.
        const moments = await deploy_moments(euroleagueConfig)
        await collections.clancy.ERC.ClancyERC721.setPublicMintStatus(moments, true)

        // Deploy the series of ERC-721 tokens representing Euroleague cases.
        const series1cases: ContractContainer = await deploy_series1_case(euroleagueConfig)

        // For each series1case contract, set the moments contract and the case contract.
        for (const series1case of Object.values(series1cases)) {
            await collections.euroleague.series1.series1case.setMomentsContract(series1case, await moments.getAddress())
            await collections.euroleague.series1.moments.setCaseContract(moments, await series1case.getAddress(), true)
        }

        // Log a success message indicating that the deployment completed.
        utility.printFancy("Euroleague collection successfully deployed.", true)
    } catch (error: any) {
        // Log an error message if the deployment fails and re-throw the error.
        Ducky.Error(FILE_DIR, "deploy", `Failed to deploy Euroleague collection: ${error.message}`);
        throw new Error(`Failed to deploy Euroleague collection: ${error.message}`);
    }
}







export default deploy