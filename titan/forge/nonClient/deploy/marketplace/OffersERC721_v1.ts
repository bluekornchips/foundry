import { ethers } from "ethers";

import collections from "../../../../collections";
import nonClient from "../..";
import utility from "../../../../utility";
import { ContractContainer } from "../../../../types";
import { ICollectionConfigs } from "../../../../interfaces";
import { VALID_CONTRACTS } from "../../../../config/constants";
import coordinator from "../../coordinator";

const OffersERC721_v1 = async (): Promise<ethers.Contract> => {
    const configs: ICollectionConfigs = utility.getCollectionConfigs();

    const contractsContainer: ContractContainer = await nonClient.getContractsFromDb({}, [
        VALID_CONTRACTS.Clutch,
        VALID_CONTRACTS.CrunchTime,
        VALID_CONTRACTS.HeatinUp,
        VALID_CONTRACTS.Reels,
        VALID_CONTRACTS.SlamPacked,
        VALID_CONTRACTS.Swishin
    ]);

    const offersERC721_v1: ethers.Contract = await collections.clancy.marketplace.offers.OffersERC721_v1.deploy(configs.Clancy.Marketplace.Offers.name);

    await coordinator.marketplace.setAllowedContracts(offersERC721_v1, contractsContainer, VALID_CONTRACTS.OffersERC721_v1);

    return offersERC721_v1;
}

export default OffersERC721_v1;