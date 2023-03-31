import { ethers } from "ethers"
import { EOAS, RPC } from "../../../../../config/constants";
import pgsql from "../../../../../pgsql";
import artifact_finder from "../../../../../utility/artifactFinder";
import createWalletWithPrivateKey from "../../../../../utility/blockchain/createWalletWithPrivateKey";
import Ducky from "../../../../../utility/logging/ducky";

const FILE_DIR = "titan/collections/clancy/marketplace/escrow/MarketplaceERC721Escrow_v1"

/**
 * Deploys a contract with the specified name and adds it to PostgreSQL.
 * @param name The name of the contract to deploy.
 * @returns The deployed contract object.
 * @throws If the contract could not be deployed or added to PostgreSQL.
 */
const deploy = async (name: string): Promise<ethers.Contract> => {
    const artifact = artifact_finder(name);

    Ducky.Debug(FILE_DIR, "deploy", `Deploying ${name} to ${RPC.NAME}`);
    try {
        const factory = new ethers.ContractFactory(artifact.abi, artifact.bytecode, createWalletWithPrivateKey(EOAS.DEPLOYMENT_KEY));

        const contract = await factory.deploy(); // Deploy the contract using the specified artifact.
        await contract.waitForDeployment(); // Wait for the contract to be deployed.

        const contract_address: string = await contract.getAddress(); // Get the address of the deployed contract.

        Ducky.Debug(FILE_DIR, "deploy", `${name} deployed to ${contract_address}`);

        // Add the contract to PostgreSQL.
        const upsertResponse = await pgsql.contracts.upsert(name, contract as ethers.Contract, 0, artifact);
        if (!upsertResponse) {
            const message = `Could not add ${name} to PostgreSQL`;
            Ducky.Error(FILE_DIR, "deploy", message);
            throw new Error(message);
        }

        return contract as ethers.Contract;
    } catch (error: any) {
        const message = `Could not deploy or add ${name} to PostgreSQL: ${error.message}`;
        Ducky.Error(FILE_DIR, "deploy", message);
        throw new Error(message);
    }
};


export default deploy;