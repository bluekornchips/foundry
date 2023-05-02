import { ethers } from "ethers";
import { ICollectionConfigs } from "../../../../interfaces";
import utility from "../../../../utility";
import { VALID_CONTRACTS } from "../../../../config/constants";
import collections from "../../../../collections";
import Ducky from "../../../../utility/logging/ducky/ducky";

const clancyERC20 = async (): Promise<ethers.Contract> => {
    const configs: ICollectionConfigs = utility.getCollectionConfigs();
    try {
        const args = configs.Clancy.ERC.ERC20.ClancyERC20.cargs;
        const artifact = utility.artifactFinder(VALID_CONTRACTS.Clancy.ERC.ClancyERC20);
        const erc20: ethers.Contract = await collections.clancy.ERC.ERC20.ClancyERC20.deploy(args.name, args.symbol, args.initial_supply, args.cap, -1, artifact);
        return erc20;
    } catch (error: any) {
        Ducky.Error(__filename, "clancyERC20", `Failed to deploy ClancyERC20: ${error.message}`);
        throw new Error(error.message);
    }
}

export default clancyERC20;