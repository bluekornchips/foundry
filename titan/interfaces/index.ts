export interface IContractOptions {
    [key: string]: IContractOption;
    ClancyERC721: IClancyERC721Options;
    MarketplaceERC721Escrow_v1: IContractOption;
}

interface IClancyERC721Options extends IContractOption {
    cargs: {
        name: string;
        symbol: string;
        max_supply: number;
        uri: string;
    };
    publicMintStatus: boolean;
    publicBurnStatus: boolean;
}

export interface IContractOption {
    name: string;
    validForSale: boolean;
}