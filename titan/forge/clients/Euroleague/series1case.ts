import collections from "../../../collections"
import Ducky from "../../../utility/logging/ducky"
import getActiveEnv from "../../env"
import { ContractContainer } from "../../../types"
import { IClancyERC721ContractConfig, IEuroleagueConfig } from "../../../interfaces"

/**
 * Deploy a series of ERC-721 tokens representing Euroleague cases, based on the configurations in the provided IEuroleagueConfig object.
 *
 * @param config The IEuroleagueConfig object containing configurations for the ERC-721 tokens to be deployed.
 * @returns An object containing the deployed ERC-721 tokens.
 */
const series1Case = async (config: IEuroleagueConfig): Promise<ContractContainer> => {
    // Get the configurations for the ERC-721 tokens to be deployed.
    const series1cases_configs: IClancyERC721ContractConfig[] = config.ERC.Series1Cases
    // Create an empty object to hold the deployed ERC-721 tokens.
    let series1case_contracts: ContractContainer = {}

    // Loop through each configuration and deploy the corresponding ERC-721 token.
    for (const series1case of series1cases_configs) {
        try {
            // Create an object with the arguments needed to deploy the ERC-721 token.
            const { name, symbol, max_supply, uri } = series1case.cargs
            // Find the matching configuration for the ERC-721 token.
            const config = series1cases_configs.find((config: IClancyERC721ContractConfig) => config.cargs.name === name)
            if (!config) {
                throw new Error(`No configuration found for ${name}`)
            }

            // Get the odoo token id for the ERC-721 token.
            const odoo_token_ids = getActiveEnv().euroleague.odoo_token_ids
            const odoo_token_id = odoo_token_ids[name.toLocaleUpperCase()]
            if (!odoo_token_id) {
                throw new Error(`No odoo token id found for ${name}`)
            }

            // Deploy the ERC-721 token and store it in the object of deployed tokens.
            const series1case_contract = await collections.euroleague.series1.series1case.deploy(name, symbol, max_supply, uri, odoo_token_id)
            await collections.clancy.ERC.ClancyERC721.setPublicMintStatus(series1case_contract, config.publicMintStatus)
            await collections.clancy.ERC.ClancyERC721.setPublicBurnStatus(series1case_contract, config.publicBurnStatus)
            series1case_contracts[name] = series1case_contract
        } catch (error: any) {
            // Log an error message if the deployment fails and re-throw the error.
            Ducky.Error(__filename, "series1case", `Failed to deploy ${series1case.name}: ${error.message}`);
            throw new Error(`Failed to deploy ${series1case.name}: ${error.message}`);
        }
    }

    // Return the object containing the deployed ERC-721 tokens.
    return series1case_contracts
}

export default series1Case