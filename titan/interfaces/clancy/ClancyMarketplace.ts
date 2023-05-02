export interface IOffersERC721Config extends IClancyMarketplaceERC721EscrowConfig { }
export interface IEscrowERC721Config extends IClancyMarketplaceERC721EscrowConfig { }

export interface IClancyMarketplaceERC721EscrowConfig {
    name: string;
}

export interface IClancyMarketplaceConfig {
    Escrow: IEscrowERC721Config;
    Offers: IOffersERC721Config
}