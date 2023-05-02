
//#region ERC20
export interface IClancyERC20ConstructorArgConfig {
    name: string
    symbol: string
    initial_supply: number
    cap: number
}

export interface IClancyERC20Config {
    ClancyERC20: {
        cargs: IClancyERC20ConstructorArgConfig
    }
    Utils: {
        ClancyERC20Airdrop: IClancyERC20UtilsConfig
    }
}

export interface IClancyERC20UtilsConfig {
    name: string
}

// #endregion ERC20

//#region ERC721
export interface IClancyERC721ConstructorArgConfig {
    name: string;
    symbol: string;
    max_supply: number;
    uri: string;
}

export interface IClancyERC721ContractConfig {
    name: string; // The name of the ClancyERC721 contract.
    cargs: IClancyERC721ConstructorArgConfig;
    validForSale: boolean;
    publicMintStatus: boolean;
    publicBurnStatus: boolean;
}


export interface IClancyERC721Config {
    ClancyERC721: IClancyERC721ContractConfig;
}


export interface IClancyERCConfig {
    ERC721: IClancyERC721Config;
    ERC20: IClancyERC20Config;
}

// #endregion ERC721