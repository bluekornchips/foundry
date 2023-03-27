import { ethers } from "ethers";
import { Ducky } from "../client/logging/ducky";
import collections from "../collections";

const deploy_contract = async (contract_name: string): Promise<ethers.Contract> => {
    switch (contract_name) {
        case "marketplace":
            const marketplace: ethers.Contract = await collections.clancy.marketplace.escrow.MarketplaceERC721Escrow_v1.deploy();
            return marketplace;
        case "erc721":
            const erc721: ethers.Contract = await collections.clancy.ERC.ClancyERC721.deploy();
            return erc721;
        default:
            const message = `Contract ${contract_name} not found`;
            Ducky.Error("Deployment", "main", message);
            throw new Error(message);
    }
}

export default deploy_contract;