import { ethers } from "ethers"

import artifact_finder from "../../../../utility/artifactFinder"
import collections from "../../.."
import Ducky from "../../../../utility/logging/ducky";
import { VALID_CONTRACTS } from "../../../../config/constants"

/**
 * Deploys a ClancyERC721 contract for Reels with the specified name, symbol, max supply, and URI.
 * @param name The name of the ERC721 contract to deploy.
 * @param symbol The symbol of the ERC721 contract to deploy.
 * @param max_supply The maximum supply of the ERC721 contract to deploy.
 * @param uri The base URI of the ERC721 contract to deploy.
 * @returns The deployed contract object.
 * @throws If the contract could not be deployed.
 */
const deploy = async (name: string, symbol: string, max_supply: number, uri: string, odoo_token_id: number): Promise<ethers.Contract> => {
    const artifact = artifact_finder(VALID_CONTRACTS.Reels, "Series1/");
    try {
        const contract = await collections.clancy.ERC.ClancyERC721.deploy(name, symbol, max_supply, uri, odoo_token_id, artifact); // Deploy the ClancyERC721 contract using the specified arguments and retrieved artifact.
        return contract;
    } catch (error: any) {
        const message = `Could not deploy ${name}: ${error.message}`;
        Ducky.Error(__filename, "deploy", message);
        throw new Error(message);
    }
};


export default deploy