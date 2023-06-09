import { ethers } from "ethers"
import { EOAS, RPC } from "../../../../config/constants";
import pgsql from "../../../../pgsql";
import createWalletWithPrivateKey from "../../../../utility/blockchain/createWalletWithPrivateKey";
import Ducky from "../../../../utility/logging/ducky";
import { contract_type_db } from "../../../../types";



/**
 * Deploys a new instance of a contract with the specified parameters to the blockchain and adds it to a PostgreSQL database.
 * @param name The name of the contract.
 * @param symbol The symbol of the contract.
 * @param max_supply The maximum supply of the contract.
 * @param uri The URI of the contract.
 * @param artifact The artifact associated with the contract.
 * @returns The deployed contract instance.
 * @throws If the contract deployment or addition to PostgreSQL fails.
 */
const deploy = async (name: string, symbol: string, max_supply: number, uri: string, odoo_token_id: number, artifact: any): Promise<ethers.Contract> => {
    Ducky.Debug(__filename, "deploy", `Deploying ClancyERC721: ${name} to ${RPC.URL}`);
    const deployedContract = await deployToBlockchain(name, symbol, max_supply, uri, artifact);
    await addToPostgres(name, deployedContract, odoo_token_id, artifact); // Add the deployed contract and its artifact to PostgreSQL.
    return deployedContract;
};

const deployToBlockchain = async (contractName: string, contractSymbol: string, maxSupply: number, metadataURI: string, artifact: any): Promise<ethers.Contract> => {
    try {
        const contractFactory = new ethers.ContractFactory(artifact.abi, artifact.bytecode, createWalletWithPrivateKey(EOAS.DEPLOYMENT_KEY))
        const deployedContract = await contractFactory.deploy(contractName, contractSymbol, maxSupply, metadataURI)
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
        const upsertResult = await pgsql.contracts.upsert(name, contract, odoo_token_id, contract_type_db.ERC721, artifact);
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