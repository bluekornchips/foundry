import { ethers } from "ethers";

import collections from "../../../../collections";
import nonClient from "../..";
import utility from "../../../../utility";
import { ContractContainer } from "../../../../types";
import { ICollectionConfigs } from "../../../../interfaces";
import { VALID_CONTRACTS } from "../../../../config/constants";
import coordinator from "../../coordinator";

const OffersERC721 = async (): Promise<ethers.Contract> => {
    const configs: ICollectionConfigs = utility.getCollectionConfigs();

    const contractsContainer: ContractContainer = await nonClient.getContractsFromDb({}, [
        VALID_CONTRACTS.Clutch,
        VALID_CONTRACTS.CrunchTime,
        VALID_CONTRACTS.HeatinUp,
        VALID_CONTRACTS.Reels,
        VALID_CONTRACTS.SlamPacked,
        VALID_CONTRACTS.Swishin
    ]);

    const offersERC721: ethers.Contract = await collections.clancy.marketplace.offers.OffersERC721.deploy(configs.Clancy.Marketplace.Offers.name);

    await coordinator.marketplace.setAllowedContracts(offersERC721, contractsContainer, VALID_CONTRACTS.OffersERC721);

    return offersERC721;
}

export default OffersERC721;