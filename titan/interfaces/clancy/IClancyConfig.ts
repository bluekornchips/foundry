import { IClancyERC721ContractConfig, IClancyERCConfig } from "./ClancyERC";
import { IClancyMarketplaceConfig } from "./ClancyMarketplace";

export interface IClancyConfig {
    ERC: IClancyERCConfig;
    Marketplace: IClancyMarketplaceConfig;
    [Symbol.iterator](): IterableIterator<[string, IClancyERC721ContractConfig]>; // Returns an iterable iterator for the ERC property.
}
