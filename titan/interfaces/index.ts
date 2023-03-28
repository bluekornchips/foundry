export interface IContractOptions {
    ClancyERC721: {
        cargs: {
            name: string;
            symbol: string;
            max_supply: number;
            uri: string;
        };
        publicMintStatus: boolean;
        publicBurnStatus: boolean;
    };
    MarketplaceERC721Escrow_v1: {
        name: string;
    }
}