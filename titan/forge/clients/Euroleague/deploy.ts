import { ethers } from "ethers";

import collections from "../../../collections";
import deploy_reels from "./reels";
import series1Case from "./series1case";
import Ducky from "../../../utility/logging/ducky";
import getActiveEnv from "../../env";
import utility from "../../../utility";
import { ContractContainer } from "../../../types";
import { VALID_CONTRACTS } from "../../../config/constants";

/**
 * Deploy the Euroleague collection of ERC-721 tokens.
 */
const deploy = async () => {
    utility.printFancy(`Euroleague - ${getActiveEnv().env}`, true);

    // Get the configuration for the Euroleague collection and validate it.
    const euroleagueConfig = utility.getCollectionConfigs().Euroleague
    if (!euroleagueConfig) throw new Error(`Failed to find Euroleague configuration in the config file.`)

    try {
        // Deploy a new EscrowERC721 contract.
        const marketplace: ethers.Contract = await collections.clancy.marketplace.escrow.EscrowERC721.deploy(VALID_CONTRACTS.Clancy.Marketplace.EscrowERC721)

        // Deploy the Euroleague Reels ERC-721 token.
        const reels = await deploy_reels(euroleagueConfig)
        await collections.clancy.ERC.ClancyERC721.setPublicMintEnabled(reels, true)
        await collections.clancy.marketplace.setVendorStatus(marketplace, reels, true, VALID_CONTRACTS.Clancy.Marketplace.EscrowERC721)

        // Deploy the series of ERC721 tokens representing Euroleague cases.
        const series1cases: ContractContainer = await series1Case(euroleagueConfig)

        // For each series1case contract, set the reels contract and the case contract.
        let count = 1;
        for (const series1case of Object.values(series1cases)) {
            Ducky.Debug(__filename, "deploy", `Setting reels contract for series1case #${count++}.`)
            await collections.euroleague.series1.series1case.setReelsContract(series1case, await reels.getAddress())
            await collections.euroleague.series1.reels.setCaseContract(reels, await series1case.getAddress(), true)
            await collections.clancy.marketplace.setVendorStatus(marketplace, series1case, true, VALID_CONTRACTS.Clancy.Marketplace.EscrowERC721)
        }

        // Log a success message indicating that the deployment completed.
        utility.printFancy(`Euroleague collection successfully deployed to ${getActiveEnv().env}`, true)
    } catch (error: any) {
        // Log an error message if the deployment fails and re-throw the error.
        Ducky.Error(__filename, "deploy", `Failed to deploy Euroleague collection: ${error.message}`);
        throw new Error(`Failed to deploy Euroleague collection: ${error.message}`);
    }
}

export default deploy