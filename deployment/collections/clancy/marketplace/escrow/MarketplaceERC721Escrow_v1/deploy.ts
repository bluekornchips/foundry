import { ethers } from "ethers";
import pgsql from "../../../../../pgsql";
import { RPC } from "../../../../../config/constants";
import { Ducky } from "../../../../../client/logging/ducky/ducky";
import contracts from "../../../../../contracts";
import artifact_finder from "../../../../../utility/artifactFinder";

const FILE_DIR = "deployment/collections/marketplace/escrow/MarketplaceERC721Escrow_v1";
const CONTRACT_NAME = "MarketplaceERC721Escrow_v1";

/**
 * @dev Deploys the MarketplaceERC721Escrow_v1 contract to the EVM network and adds it to PostgreSQL
 * @throws If there is an error deploying the contract to the EVM network or adding it to PostgreSQL
 */
const deploy = async () => {
    const foundry_artifact = artifact_finder(CONTRACT_NAME);

    // Deploy the contract to the network.
    const contract: ethers.Contract = await contracts.clancy.marketplace.escrow.MarketplaceERC721Escrow_v1.deploy(foundry_artifact);
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