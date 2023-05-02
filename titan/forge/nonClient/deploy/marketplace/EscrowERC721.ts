import { ethers } from "ethers";

import collections from "../../../../collections";
import nonClient from "../..";
import utility from "../../../../utility";
import { ContractContainer } from "../../../../types";
import { ICollectionConfigs } from "../../../../interfaces";
import { VALID_CONTRACTS } from "../../../../config/constants";
import coordinator from "../../coordinator";

const EscrowERC721 = async (): Promise<ethers.Contract> => {
    const configs: ICollectionConfigs = utility.getCollectionConfigs();

    const contractsContainer: ContractContainer = await nonClient.getContractsFromDb({}, [
        VALID_CONTRACTS.Euroleague.Clutch,
        VALID_CONTRACTS.Euroleague.CrunchTime,
        VALID_CONTRACTS.Euroleague.HeatinUp,
        VALID_CONTRACTS.Euroleague.Reels,
        VALID_CONTRACTS.Euroleague.SlamPacked,
        VALID_CONTRACTS.Euroleague.Swishin
    ]);

    const offersERC721: ethers.Contract = await collections.clancy.marketplace.escrow.EscrowERC721.deploy(configs.Clancy.Marketplace.Escrow.name);

    await coordinator.marketplace.setAllowedContracts(offersERC721, contractsContainer, VALID_CONTRACTS.Clancy.Marketplace.EscrowERC721);

    return offersERC721;
}

export default EscrowERC721;