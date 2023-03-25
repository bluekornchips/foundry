const hre = require("hardhat");

import ethers from "ethers"
import { Ducky } from "../../../../client/logging/ducky/ducky";
import { SENTINEL_RPC_URL } from "../../../../config/constants";

const FILE_DIR = "scripts/blockchain/clancy/ERC/"
const CONTRACT_NAME = "ClancyERC721"

export const ClancyERC721 = async (pack_name: string, pack_symbol: string, max_supply: number, uri: string): Promise<ethers.Contract> => {
    Ducky.Debug(FILE_DIR, CONTRACT_NAME, `Deploying ${CONTRACT_NAME} to ${SENTINEL_RPC_URL}`);
    let contract: ethers.Contract;
    try {
        const contractFactory = await hre.ethers.getContractFactory(CONTRACT_NAME);
        contract = await contractFactory.deploy(pack_name, pack_symbol, max_supply, uri);

        await contract.deployed();

        Ducky.Debug(FILE_DIR, "deploy", `${pack_name} deployed to ${contract.address}`);

        return contract;
    } catch (error: any) {
        Ducky.Error(FILE_DIR, "deploy", error.message)
        throw error;
    }
};