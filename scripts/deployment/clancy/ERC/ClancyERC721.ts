import { ethers } from "ethers";
import { Ducky } from "../../../../client/logging/ducky/ducky";
import { SENTINEL_RPC_URL } from "../../../../config/constants";
import parentDirectory from "../../../../utils/projectDirectory";
import { ERC } from "../../../blockchain/clancy/ERC";
import { pgsql } from "../../../pgsql";

const FILE_DIR = "scripts/deploy/clancy/ERC/ClancyERC721.ts";
const CONTRACT_NAME = "ClancyERC721",
    CONTRACT_SYMBOL = "CLANCY",
    MAX_SUPPLY = 100,
    URI = "https://clancy.com/api/";

const main = async () => {
    Ducky.Debug(FILE_DIR, "ClancyERC721", "Deploying ClancyERC721 contract");

    const topDir = parentDirectory();

    // Find the compiled contract artifact.
    const foundry_artifact = require(`${topDir}out/ClancyERC721.sol/ClancyERC721.json`);
    if (!foundry_artifact) {
        Ducky.Error(FILE_DIR, "ClancyERC721", `Could not find artifact for ${CONTRACT_NAME} contract`);
        process.exit(1);
    }
    // Deploy the contract to the network.
    const blockchain_deployment_response: ethers.Contract = await ERC.ClancyERC721(CONTRACT_NAME, CONTRACT_SYMBOL, MAX_SUPPLY, URI);
    if (!blockchain_deployment_response) {
        Ducky.Error(FILE_DIR, "ClancyERC721", `Could not deploy ${CONTRACT_NAME} contract to ${SENTINEL_RPC_URL}`);
        process.exit(1);
    }
    const contract_pgsql_response = await pgsql.Clancy.ERC.ClancyERC721(CONTRACT_NAME, blockchain_deployment_response.address, foundry_artifact);
    if (!contract_pgsql_response) {
        Ducky.Error(FILE_DIR, "ClancyERC721", `Could not add ${CONTRACT_NAME} to PostgreSQL`);
        process.exit(1);
    }

    Ducky.Debug(FILE_DIR, "ClancyERC721", `Successfully deployed ${CONTRACT_NAME} contract to ${SENTINEL_RPC_URL}`);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});