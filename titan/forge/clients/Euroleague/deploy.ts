import { ethers } from "ethers";

import { contracts } from "@prisma/client";

import collections from "../../../collections";
import createEthersContractFromDB from "../../../utility/blockchain/createEthersContractFromDB";
import deploy_moments from "./moments";
import deploy_series1_case from "./series1case";
import Ducky from "../../../utility/logging/ducky";
import getActiveEnv from "../../env";
import pgsql from "../../../pgsql";
import utility from "../../../utility";
import { ContractContainer } from "../../../types";
import { EOAS, VALID_CONTRACTS } from "../../../config/constants";
import createWalletWithPrivateKey from "../../../utility/blockchain/createWalletWithPrivateKey";

/**
 * Deploy the Euroleague collection of ERC-721 tokens.
 */
const deploy = async () => {
    utility.printFancy(`Euroleague - ${getActiveEnv().env}`, true);

    const marketplace_db: contracts = await pgsql.contracts.get(VALID_CONTRACTS.MarketplaceERC721Escrow_v1)
    const marketplace: ethers.Contract = await createEthersContractFromDB(marketplace_db, createWalletWithPrivateKey(EOAS.DEPLOYMENT_KEY))

    // Get the configuration for the Euroleague collection.
    const euroleagueConfig = utility.getCollectionConfigs().Euroleague

    try {
        // Deploy the Euroleague Moments ERC-721 token.
        const moments = await deploy_moments(euroleagueConfig)
        await collections.clancy.ERC.ClancyERC721.setPublicMintStatus(moments, true)
        await collections.clancy.marketplace.escrow.MarketplaceERC721Escrow_v1.setAllowedContract(marketplace, moments, true)

        // Deploy the series of ERC721 tokens representing Euroleague cases.
        const series1cases: ContractContainer = await deploy_series1_case(euroleagueConfig)

        // For each series1case contract, set the moments contract and the case contract.
        let count = 1;
        for (const series1case of Object.values(series1cases)) {
            Ducky.Debug(__filename, "deploy", `Setting moments contract for series1case #${count++}.`)
            await collections.euroleague.series1.series1case.setMomentsContract(series1case, await moments.getAddress())
            await collections.euroleague.series1.moments.setCaseContract(moments, await series1case.getAddress(), true)
            await collections.clancy.marketplace.escrow.MarketplaceERC721Escrow_v1.setAllowedContract(marketplace, series1case, true)
        }

        // Log a success message indicating that the deployment completed.
        utility.printFancy("Euroleague collection successfully deployed.", true)
    } catch (error: any) {
        // Log an error message if the deployment fails and re-throw the error.
        Ducky.Error(__filename, "deploy", `Failed to deploy Euroleague collection: ${error.message}`);
        throw new Error(`Failed to deploy Euroleague collection: ${error.message}`);
    }
}

export default deploy