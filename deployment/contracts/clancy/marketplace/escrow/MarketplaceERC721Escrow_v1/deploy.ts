import { ethers } from "ethers"
import { Ducky } from "../../../../../client/logging/ducky/ducky";
import { EOAS, RPC } from "../../../../../config/constants";
import createWalletWithPrivateKey from "../../../../../utility/blockchain/createWalletWithPrivateKey";

const FILE_DIR = "deployment/contracts/clancy/marketplace/escrow/MarketplaceERC721Escrow_v1"
const CONTRACT_NAME = "MarketplaceERC721Escrow_v1"

/**
 * @dev Deploys the specified contract artifact to the configured EVM network
 * @param artifact The contract artifact containing the ABI and bytecode for the contract to deploy
 * @return The deployed contract instance as an ethers.Contract
 */
const deploy = async (artifact: any): Promise<ethers.Contract> => {
    Ducky.Debug(FILE_DIR, CONTRACT_NAME, `Deploying ${CONTRACT_NAME} to ${RPC.NAME}`);
    try {
        const factory = new ethers.ContractFactory(artifact.abi, artifact.bytecode, createWalletWithPrivateKey(EOAS.DEPLOYMENT_KEY))

        const contract = await factory.deploy()
        await contract.waitForDeployment();

        const contract_address: string = await contract.getAddress();

        Ducky.Debug(FILE_DIR, "deploy", `${CONTRACT_NAME} deployed to ${contract_address}`);
        return contract as ethers.Contract;
    } catch (error: any) {
        Ducky.Error(FILE_DIR, "deploy", error.message)
        throw new Error(error.message);
    }
};

export default deploy;