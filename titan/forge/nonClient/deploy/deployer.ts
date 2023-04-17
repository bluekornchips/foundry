import { ethers } from "ethers";

import Ducky from "../../../utility/logging/ducky";
import collections from "../../../collections";
import utility from "../../../utility";
import { ContractContainer } from "../../../types";
import { ICollectionConfigs } from "../../../interfaces";
import { VALID_CONTRACTS } from "../../../config/constants";
import marketplace from "./marketplace";

/**
 * Deploys the specified contracts and returns a container object with the deployed contracts.
 *
 * @param contract_names An array of contract names to deploy.
 * @returns A container object with the deployed contracts.
 * @throws An error if the deployment of one of the contracts fails.
 */
const deployer = async (contract_names: string[]): Promise<ContractContainer> => {
    utility.printFancy(`Contract Deployment - ${contract_names.length} Contracts`, true, 1)

    const contracts: ContractContainer = {}
    for (const contract_name of contract_names) {
        try {
            console.log()
            Ducky.Debug(__filename, "deploy", `Deploying ${contract_name}...`);
            const contract = await deploy_contract(contract_name);
            contracts[contract_name] = contract;
            Ducky.Debug(__filename, "deploy", `${contract_name} deployed at ${await contract.getAddress()}`);
        } catch (error: any) {
            Ducky.Error(__filename, "deploy", `Failed to deploy ${contract_name}: ${error.message}`);
            throw new Error(error.message);
        }
    }

    return contracts;
}

/**
 * Deploys the specified contract.
 * @param contract_name - The name of the contract to deploy.
 * @returns The deployed contract.
 */
const deploy_contract = async (contract_name: string): Promise<ethers.Contract> => {
    const contract_configs: ICollectionConfigs = utility.getCollectionConfigs();
    try {
        switch (contract_name) {
            /**
             * Marketplace
             */
            // Escrow
            case VALID_CONTRACTS.EscrowERC721_v1:
                const escrowERC721_name: string = contract_configs.Clancy.Marketplace.Escrow.name;
                const marketplaceContract: ethers.Contract = await collections.clancy.marketplace.escrow.EscrowERC721_v1.deploy(escrowERC721_name);
                return marketplaceContract;
            // Offers
            case VALID_CONTRACTS.OffersERC721_v1:
                const offersERC721_v1 = await marketplace.OffersERC721_v1();
                return offersERC721_v1;

            /**
             * ERC721
             */
            case VALID_CONTRACTS.ClancyERC721:
                const clancyERC721Args = contract_configs.Clancy.ERC.ClancyERC721.cargs;
                const artifact = utility.artifactFinder(VALID_CONTRACTS.ClancyERC721);
                const erc721: ethers.Contract = await collections.clancy.ERC.ClancyERC721.deploy(clancyERC721Args.name, clancyERC721Args.symbol, clancyERC721Args.max_supply, clancyERC721Args.uri, 0, artifact);
                return erc721;
            case VALID_CONTRACTS.Reels:
                const reelsArgs = contract_configs.Euroleague.ERC.Reels.cargs;
                const reels = await collections.euroleague.series1.reels.deploy(reelsArgs.name, reelsArgs.symbol, reelsArgs.max_supply, reelsArgs.uri, 0)
                return reels;
            default:
                const message = `Contract ${contract_name} not found`;
                Ducky.Error(__filename, "deploy_contract", message);
                throw new Error(message);
        }
    } catch (error: any) {
        Ducky.Error(__filename, "deploy_contract", `Failed to deploy ${contract_name}: ${error.message}`);
        throw new Error(error.message);
    }
}


export default deployer;