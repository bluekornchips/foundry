import { ethers } from "ethers"
import { Ducky } from "../../../../client/logging/ducky";
import { EOAS, RPC } from "../../../../config/constants";
import createWalletWithPrivateKey from "../../../../utility/blockchain/createWalletWithPrivateKey";

const FILE_DIR = "deployment/contracts/clancy/ERC/ClancyERC721"
const CONTRACT_NAME = "ClancyERC721"

/**
 * @dev Deploys the specified contract artifact to the configured EVM network
 * @param artifact The contract artifact containing the ABI and bytecode for the contract to deploy
 * @param pack_name The name of the pack
 * @param pack_symbol The symbol of the pack
 * @param max_supply The maximum supply of the pack
 * @param uri The URI of the pack
 * @return The deployed contract instance as an ethers.Contract
 * @throws If there is an error deploying the contract
*/
const deploy = async (artifact: any, pack_name: string, pack_symbol: string, max_supply: number, uri: string): Promise<ethers.Contract> => {
    Ducky.Debug(FILE_DIR, CONTRACT_NAME, `Deploying ${CONTRACT_NAME} to ${RPC.NAME}`);
    try {
        const factory = new ethers.ContractFactory(artifact.abi, artifact.bytecode, createWalletWithPrivateKey(EOAS.DEPLOYMENT_KEY))
        const contract = await factory.deploy(pack_name, pack_symbol, max_supply, uri)
        await contract.waitForDeployment();

        const contract_address: string = await contract.getAddress()

        Ducky.Debug(FILE_DIR, "deploy", `${CONTRACT_NAME} deployed to ${contract_address}`);
        return contract as ethers.Contract;
    } catch (error: any) {
        Ducky.Error(FILE_DIR, "ClancyERC721", error.message)
        throw new Error(error.message);
    }
};

export default deploy;