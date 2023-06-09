
import { ethers } from "ethers"

import Ducky from "../../../../../utility/logging/ducky";
import artifact_finder from "../../../../../utility/artifactFinder";
import createWalletWithPrivateKey from "../../../../../utility/blockchain/createWalletWithPrivateKey";
import pgsql from "../../../../../pgsql";
import { EOAS, RPC } from "../../../../../config/constants";
import { contract_type_db } from "../../../../../types";

/**
 * Deploys a contract with the specified name and adds it to PostgreSQL.
 * @param name The name of the contract to deploy.
 * @returns The deployed contract object.
 * @throws If the contract could not be deployed or added to PostgreSQL.
 */
const deploy = async (name: string): Promise<ethers.Contract> => {
    const artifact = artifact_finder(name);

    Ducky.Debug(__filename, "deploy", `Deploying ${name} to ${RPC.URL}`);
    try {
        const factory = new ethers.ContractFactory(artifact.abi, artifact.bytecode, createWalletWithPrivateKey(EOAS.DEPLOYMENT_KEY));

        const contract = await factory.deploy(); // Deploy the contract using the specified artifact.
        await contract.waitForDeployment(); // Wait for the contract to be deployed.

        const contract_address: string = await contract.getAddress(); // Get the address of the deployed contract.

        Ducky.Debug(__filename, "deploy", `${name} deployed to ${contract_address}`);

        // Add the contract to PostgreSQL.
        const upsertResponse = await pgsql.contracts.upsert(name, contract as ethers.Contract, 0, contract_type_db.Marketplace, artifact);
        if (!upsertResponse) {
            const message = `Could not add ${name} to PostgreSQL`;
            Ducky.Error(__filename, "deploy", message);
            throw new Error(message);
        }

        return contract as ethers.Contract;
    } catch (error: any) {
        const message = `Could not deploy or add ${name} to PostgreSQL: ${error.message}`;
        Ducky.Error(__filename, "deploy", message);
        throw new Error(message);
    }
};


export default deploy;