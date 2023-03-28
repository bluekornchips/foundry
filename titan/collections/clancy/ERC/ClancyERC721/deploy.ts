import { ethers } from "ethers"
import { Ducky } from "../../../../client/logging/ducky";
import { EOAS, RPC } from "../../../../config/constants";
import pgsql from "../../../../pgsql";
import artifact_finder from "../../../../utility/artifactFinder";
import createWalletWithPrivateKey from "../../../../utility/blockchain/createWalletWithPrivateKey";
import getContractOptions from "../../../../utility/getContractOptions";

const FILE_DIR = "titan/collections/clancy/ERC/ClancyERC721"

/**
 * @dev Deploys the ClancyERC721 contract to the EVM network and adds it to PostgreSQL
 * @return A Promise resolving to the deployed contract
 * @throws If there is an error deploying the contract, adding it to PostgreSQL, or if the ClancyERC721 contract is not found
 */
const deploy = async (): Promise<ethers.Contract> => {
    const options = getContractOptions()

    Ducky.Debug(FILE_DIR, options.ClancyERC721.cargs.name, `Deploying ${options.ClancyERC721.cargs.name} to ${RPC.NAME}`);
    try {
        const artifact = artifact_finder(options.ClancyERC721.cargs.name)

        const factory = new ethers.ContractFactory(artifact.abi, artifact.bytecode, createWalletWithPrivateKey(EOAS.DEPLOYMENT_KEY))
        const contract = await factory.deploy(options.ClancyERC721.cargs.name, options.ClancyERC721.cargs.symbol, options.ClancyERC721.cargs.max_supply, options.ClancyERC721.cargs.uri)
        await contract.waitForDeployment();

        Ducky.Debug(FILE_DIR, "deploy", `${options.ClancyERC721.cargs.name} deployed to ${await contract.getAddress()}`);

        // Add the contract to PostgreSQL.
        const contract_pgsql_response = await pgsql.contracts.upsert(options.ClancyERC721.cargs.name, contract as ethers.Contract, artifact);
        if (!contract_pgsql_response) {
            const message = `Could not add ${options.ClancyERC721.cargs.name} to PostgreSQL`;
            Ducky.Error(FILE_DIR, "deploy", message);
            throw new Error(message);
        }

        Ducky.Debug(FILE_DIR, "deploy", `Successfully deployed ${options.ClancyERC721.cargs.name} contract to ${RPC.NAME}`);

        return contract as ethers.Contract;
    } catch (error: any) {
        Ducky.Error(FILE_DIR, "ClancyERC721", error.message)
        throw new Error(error.message);
    }
};

export default deploy;