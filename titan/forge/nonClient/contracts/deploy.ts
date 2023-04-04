import { ethers } from "ethers";

import Ducky from "../../../utility/logging/ducky";
import collections from "../../../collections";
import utility from "../../../utility";
import { ContractContainer } from "../../../types";
import { ICollectionConfigs } from "../../../interfaces";
import { VALID_CONTRACTS } from "../../../config/constants";

/**
 * Deploys the specified contracts and returns a container object with the deployed contracts.
 *
 * @param contract_names An array of contract names to deploy.
 * @returns A container object with the deployed contracts.
 * @throws An error if the deployment of one of the contracts fails.
 */
const deploy = async (contract_names: string[]): Promise<ContractContainer> => {
    utility.printFancy("Contract Deployment", true, 1)

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
            case VALID_CONTRACTS.MarketplaceERC721Escrow_v1:
                const name: string = contract_configs.Clancy.Marketplace.MarketplaceERC721Escrow.name;
                const marketplace: ethers.Contract = await collections.clancy.marketplace.escrow.MarketplaceERC721Escrow_v1.deploy(name);
                return marketplace;
            case VALID_CONTRACTS.ClancyERC721:
                const clancyERC721Args = contract_configs.Clancy.ERC.ClancyERC721.cargs;
                const artifact = utility.artifactFinder(VALID_CONTRACTS.ClancyERC721);
                const erc721: ethers.Contract = await collections.clancy.ERC.ClancyERC721.deploy(clancyERC721Args.name, clancyERC721Args.symbol, clancyERC721Args.max_supply, clancyERC721Args.uri, 0, artifact);
                return erc721;
            case VALID_CONTRACTS.Moments:
                const momentsArgs = contract_configs.Euroleague.ERC.Moments.cargs;
                const moments = await collections.euroleague.series1.moments.deploy(momentsArgs.name, momentsArgs.symbol, momentsArgs.max_supply, momentsArgs.uri, 0)
                return moments;
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

export default deploy;