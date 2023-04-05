
//#region Clients

//#region Euroleague
/**
 * Defines the configuration options for Euroleague reels that extend the ClancyERC721 contract configuration options.
 */
export interface IEuroleagueReelConfig extends IClancyERC721ContractConfig { }

/**
 * Defines the configuration options for the Euroleague Series 1 collection.
 */
export interface EuroleagueSeries1Config {
    Series1Cases: IClancyERC721ContractConfig[]; // Naming required because of reserved word "case".
    Reels: IEuroleagueReelConfig;
}

/**
 * Defines the configuration options for a Series 1 case that extend the ClancyERC721 contract configuration options.
 */
export interface ISeries1CaseConfig extends IClancyERC721ContractConfig {
    reelsPerCase: number;
}

/**
 * Defines the configuration options for the Euroleague collection.
 */
export interface IEuroleagueConfig {
    ERC: EuroleagueSeries1Config;
}
//#endregion Euroleague

//#endregion Clients

//#region Clancy
/**
 * Defines the configuration options for the arguments needed to deploy a ClancyERC721 contract.
 */
export interface IClancyERC721ConstructorArgConfig {
    name: string;
    symbol: string;
    max_supply: number;
    uri: string;
}

/**
 * Defines the configuration options for the ClancyERC721 contract.
 */
export interface IClancyERC721ContractConfig {
    name: string; // The name of the ClancyERC721 contract.
    cargs: IClancyERC721ConstructorArgConfig;
    validForSale: boolean;
    publicMintStatus: boolean;
    publicBurnStatus: boolean;
}
/**
 * Defines the configuration options for the ClancyERC721 contract.
 */
export interface IClancyERC721Config {
    ClancyERC721: IClancyERC721ContractConfig;
}

/**
 * Defines the configuration options for the MarketplaceERC721Escrow contract.
 */
export interface IMarketplaceERC721EscrowConfig {
    name: string;
}

/**
 * Defines the configuration options for the Clancy marketplace contract.
 */
export interface IClancyMarketplaceConfig {
    MarketplaceERC721Escrow: IMarketplaceERC721EscrowConfig;
}

/**
 * Defines the configuration options for the Clancy collection.
 */
export interface IClancyConfig {
    ERC: IClancyERC721Config;
    Marketplace: IClancyMarketplaceConfig;
    [Symbol.iterator](): IterableIterator<[string, IClancyERC721ContractConfig]>; // Returns an iterable iterator for the ERC property.
}
//#endregion Clancy


//#region All
/**
 * Defines the structure of an object containing configurations for different collections.
 */
export interface ICollectionConfigs {
    Clancy: IClancyConfig;
    Euroleague: IEuroleagueConfig;
}
//#endregion All