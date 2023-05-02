import { ethers } from "ethers";
import { ICollectionConfigs } from "../../../../interfaces";
import utility from "../../../../utility";
import { VALID_CONTRACTS } from "../../../../config/constants";
import collections from "../../../../collections";
import Ducky from "../../../../utility/logging/ducky/ducky";

const clancyERC20Airdrop = async (): Promise<ethers.Contract> => {
    const configs: ICollectionConfigs = utility.getCollectionConfigs();

    try {
        const args = configs.Clancy.ERC.ERC20.Utils.ClancyERC20Airdrop;
        const artifact = utility.artifactFinder(VALID_CONTRACTS.Clancy.ERC.ClancyERC20Airdrop);
        const airdrop: ethers.Contract = await collections.clancy.ERC.ERC20.ClancyERC20Airdrop.deploy(args.name, -1, artifact);
        return airdrop;
    } catch (error: any) {
        Ducky.Error(__filename, "clancyERC20Airdrop", `Failed to deploy: ${error.message}`);
        throw new Error(error.message);
    }
}

export default clancyERC20Airdrop;