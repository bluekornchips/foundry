import { ethers } from "ethers"
import { Ducky } from "../../../../client/logging/ducky";
import { EOAS, RPC } from "../../../../config/constants";
import pgsql from "../../../../pgsql";
import createWalletWithPrivateKey from "../../../../utility/blockchain/createWalletWithPrivateKey";

const FILE_DIR = "titan/collections/clancy/ERC/ClancyERC721"

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
const deploy = async (name: string, symbol: string, max_supply: number, uri: string, artifact: any): Promise<ethers.Contract> => {
    Ducky.Debug(FILE_DIR, "deploy", `Deploying ${name} to ${RPC.NAME}`);
    const deployedContract = await deployToBlockchain(name, symbol, max_supply, uri, artifact);
    await addToPostgres(name, deployedContract, artifact); // Add the deployed contract and its artifact to PostgreSQL.
    return deployedContract;
};

const deployToBlockchain = async (contractName: string, contractSymbol: string, maxSupply: number, metadataURI: string, artifact: any): Promise<ethers.Contract> => {
    try {
        const contractFactory = new ethers.ContractFactory(artifact.abi, artifact.bytecode, createWalletWithPrivateKey(EOAS.DEPLOYMENT_KEY))
        const deployedContract = await contractFactory.deploy(contractName, contractSymbol, maxSupply, metadataURI)
        await deployedContract.waitForDeployment(); // Wait for the contract deployment to complete.

        Ducky.Debug(FILE_DIR, "deployToBlockchain", `${contractName} deployed to ${await deployedContract.getAddress()}`);

        return deployedContract as ethers.Contract; // Return the deployed contract instance.
    } catch (error: any) {
        Ducky.Error(FILE_DIR, "deployToBlockchain", error.message)
        throw error;
    }
}


const addToPostgres = async (name: string, contract: ethers.Contract, artifact: any) => {
    try {
        const upsertResult = await pgsql.contracts.upsert(name, contract, artifact);
        if (!upsertResult) {
            const message = `Could not add ${name} to PostgreSQL.`;
            Ducky.Error(FILE_DIR, "addToPostgres", message);
            throw new Error(message);
        }
    } catch (error: any) {
        const message = `Could not add ${name} to PostgreSQL: ${error.message}`;
        Ducky.Error(FILE_DIR, "addToPostgres", message);
        throw error;
    }
}


export default deploy;