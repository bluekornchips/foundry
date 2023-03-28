import { ethers } from "ethers"
import { Ducky } from "../../../../../client/logging/ducky/ducky";
import { EOAS, RPC } from "../../../../../config/constants";
import pgsql from "../../../../../pgsql";
import artifact_finder from "../../../../../utility/artifactFinder";
import createWalletWithPrivateKey from "../../../../../utility/blockchain/createWalletWithPrivateKey";
import getContractOptions from "../../../../../utility/getContractOptions";

const FILE_DIR = "titan/collections/clancy/marketplace/escrow/MarketplaceERC721Escrow_v1"

/**
 * @dev Deploys the specified contract artifact to the configured EVM network
 * @param artifact The contract artifact containing the ABI and bytecode for the contract to deploy
 * @return The deployed contract instance as an ethers.Contract
 */
const deploy = async (): Promise<ethers.Contract> => {
    const options = getContractOptions()
    const artifact = artifact_finder(options.MarketplaceERC721Escrow_v1.name);

    Ducky.Debug(FILE_DIR, "deploy", `Deploying ${options.MarketplaceERC721Escrow_v1.name} to ${RPC.NAME}`);
    try {
        const factory = new ethers.ContractFactory(artifact.abi, artifact.bytecode, createWalletWithPrivateKey(EOAS.DEPLOYMENT_KEY))

        const contract = await factory.deploy()
        await contract.waitForDeployment();

        const contract_address: string = await contract.getAddress();

        Ducky.Debug(FILE_DIR, "deploy", `${options.MarketplaceERC721Escrow_v1.name} deployed to ${contract_address}`);

        // Add the contract to PostgreSQL.
        const contract_pgsql_response = await pgsql.contracts.upsert(options.MarketplaceERC721Escrow_v1.name, contract as ethers.Contract, artifact);
        if (!contract_pgsql_response) {
            const message = `Could not add ${options.MarketplaceERC721Escrow_v1.name} to PostgreSQL`;
            Ducky.Error(FILE_DIR, "deploy", message);
            throw new Error(message);
        }

        return contract as ethers.Contract;
    } catch (error: any) {
        Ducky.Error(FILE_DIR, "deploy", error.message)
        throw new Error(error.message);
    }
};

export default deploy;