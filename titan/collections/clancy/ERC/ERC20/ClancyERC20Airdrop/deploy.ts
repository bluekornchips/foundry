import { ethers } from "ethers"
import { EOAS, RPC } from "../../../../../config/constants";
import pgsql from "../../../../../pgsql";
import createWalletWithPrivateKey from "../../../../../utility/blockchain/createWalletWithPrivateKey";
import Ducky from "../../../../../utility/logging/ducky";

const deploy = async (name: string, odoo_token_id: number, artifact: any): Promise<ethers.Contract> => {
    Ducky.Debug(__filename, "deploy", `Deploying ClancyERC20Airdrop: ${name} to ${RPC.URL}`);
    const deployedContract = await deployToBlockchain(name, artifact);
    await addToPostgres(name, deployedContract, odoo_token_id, artifact); // Add the deployed contract and its artifact to PostgreSQL.
    return deployedContract;
};

const deployToBlockchain = async (contractName: string, artifact: any): Promise<ethers.Contract> => {
    try {
        const contractFactory = new ethers.ContractFactory(artifact.abi, artifact.bytecode, createWalletWithPrivateKey(EOAS.DEPLOYMENT_KEY))
        const deployedContract = await contractFactory.deploy()
        await deployedContract.waitForDeployment(); // Wait for the contract deployment to complete.

        Ducky.Debug(__filename, "deployToBlockchain", `${contractName} deployed to ${await deployedContract.getAddress()}`);

        return deployedContract as ethers.Contract; // Return the deployed contract instance.
    } catch (error: any) {
        Ducky.Error(__filename, "deployToBlockchain", error.message)
        throw error;
    }
}


const addToPostgres = async (name: string, contract: ethers.Contract, odoo_token_id: number, artifact: any) => {
    try {
        const upsertResult = await pgsql.contracts.upsert(name, contract, odoo_token_id, artifact);
        if (!upsertResult) {
            const message = `Could not add ${name} to PostgreSQL.`;
            Ducky.Error(__filename, "addToPostgres", message);
            throw new Error(message);
        }
    } catch (error: any) {
        const message = `Could not add ${name} to PostgreSQL: ${error.message}`;
        Ducky.Error(__filename, "addToPostgres", message);
        throw error;
    }
}


export default deploy;