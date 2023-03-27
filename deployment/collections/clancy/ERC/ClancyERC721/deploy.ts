import { ethers } from "ethers";
import { Ducky } from "../../../../client/logging/ducky";
import { RPC } from "../../../../config/constants";
import contracts from "../../../../contracts";
import pgsql from "../../../../pgsql";
import artifact_finder from "../../../../utility/artifactFinder";
import projectDirectory from "../../../../utility/projectDirectory";

const FILE_DIR = "scripts/deployment/clancy/ERC/ClancyERC721";
const CONTRACT_NAME = "ClancyERC721",
    CONTRACT_SYMBOL = "CLANCY",
    MAX_SUPPLY = 100,
    URI = "https://clancy.com/api/";

const deploy = async () => {
    const foundry_artifact = artifact_finder(CONTRACT_NAME)

    // Deploy the contract to the network.
    const contract: ethers.Contract = await contracts.clancy.ERC.ClancyERC721.deploy(foundry_artifact, CONTRACT_NAME, CONTRACT_SYMBOL, MAX_SUPPLY, URI);
    if (!contract) {
        const message = `Could not deploy ${CONTRACT_NAME} contract to ${RPC.NAME}`;
        Ducky.Error(FILE_DIR, "deploy", message);
        throw new Error(message);
    }

    // Add the contract to PostgreSQL.
    const contract_pgsql_response = await pgsql.contracts.upsert(CONTRACT_NAME, contract, foundry_artifact);
    if (!contract_pgsql_response) {
        const message = `Could not add ${CONTRACT_NAME} to PostgreSQL`;
        Ducky.Error(FILE_DIR, "deploy", message);
        throw new Error(message);
    }

    Ducky.Debug(FILE_DIR, "deploy", `Successfully deployed ${CONTRACT_NAME} contract to ${RPC.NAME}`);
}

export default deploy;