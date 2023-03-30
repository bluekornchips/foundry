import { Ducky } from "../../../client/logging/ducky"
import collections from "../../../collections"
import { IEuroleagueConfig } from "../../../interfaces"
import { ContractContainer } from "../../../types"

const FILE_DIR = "forge/clients/Euroleague"

/**
 * Deploy a series of ERC-721 tokens representing Euroleague cases, based on the configurations in the provided IEuroleagueConfig object.
 *
 * @param config The IEuroleagueConfig object containing configurations for the ERC-721 tokens to be deployed.
 * @returns An object containing the deployed ERC-721 tokens.
 */
const deploy_series1_case = async (config: IEuroleagueConfig): Promise<ContractContainer> => {
    // Get the configurations for the ERC-721 tokens to be deployed.
    const series1cases_configs = config.ERC.Series1Cases

    // Create an empty object to hold the deployed ERC-721 tokens.
    let series1case_contracts: ContractContainer = {}

    // Loop through each configuration and deploy the corresponding ERC-721 token.
    for (const series1case of series1cases_configs) {
        try {
            // Get the name of the ERC-721 token to be deployed.
            const series1caseName = series1case.cargs.name

            // Create an object with the arguments needed to deploy the ERC-721 token.
            const { name, symbol, max_supply, uri } = series1case.cargs

            // Deploy the ERC-721 token and store it in the object of deployed tokens.
            const series1case_contract = await collections.euroleague.series1.series1case.deploy(name, symbol, max_supply, uri)
            series1case_contracts[name] = series1case_contract
        } catch (error: any) {
            // Log an error message if the deployment fails and re-throw the error.
            Ducky.Error(FILE_DIR, "series1case", `Failed to deploy ${series1case.name}: ${error.message}`);
            throw new Error(`Failed to deploy ${series1case.name}: ${error.message}`);
        }
    }

    // Return the object containing the deployed ERC-721 tokens.
    return series1case_contracts
}

export default deploy_series1_case