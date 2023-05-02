import { ethers } from "ethers";
import { ICollectionConfigs } from "../../../../interfaces";
import utility from "../../../../utility";
import { VALID_CONTRACTS } from "../../../../config/constants";
import collections from "../../../../collections";
import Ducky from "../../../../utility/logging/ducky/ducky";

const clancyERC721 = async (): Promise<ethers.Contract> => {
    const configs: ICollectionConfigs = utility.getCollectionConfigs();
    const args = configs.Clancy.ERC.ERC721.ClancyERC721.cargs;
    const artifact = utility.artifactFinder(VALID_CONTRACTS.Clancy.ERC.ClancyERC721);

    try {
        const erc20: ethers.Contract = await collections.clancy.ERC.ClancyERC721.deploy(args.name, args.symbol, args.max_supply, args.uri, -1, artifact);
        return erc20;
    } catch (error: any) {
        Ducky.Error(__filename, "clancyERC721", `Failed to deploy ClancyERC721: ${error.message}`);
        throw new Error(error.message);
    }
}

export default clancyERC721;