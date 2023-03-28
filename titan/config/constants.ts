require("dotenv").config();

// # Project
export const ENV = process.env.ENV || 'DEV';

// # Odoo
export const ODOO_PACK_INFO = {
    DEV: {
        CLUTCH: 13,
        CRUNCHTIME: 11,
        HEATINUP: 9,
        SLAMPACKED: 1357,
        SWISHIN: 12,
    },
    QA: {
        CLUTCH: 8953,
        CRUNCHTIME: 8954,
        HEATINUP: 8955,
        SLAMPACKED: 8956,
        SWISHIN: 8957,
    },
    UAT: {
        CLUTCH: 53,
        CRUNCHTIME: 54,
        HEATINUP: 55,
        SLAMPACKED: 56,
        SWISHIN: 57,
    }
}

// # Blockchain
export const RPC = {
    URL: process.env.RPC_URL,
    NAME: process.env.RPC_NAME,
}

export const EOAS = {
    DEPLOYMENT_KEY: process.env.DEPLOYMENT_KEY || ""
}

export const VALID_CONTRACTS = {
    ClancyERC721: "ClancyERC721",
    MarketplaceERC721Escrow_v1: "MarketplaceERC721Escrow_v1",
}

export const CONTRACT_CONFIG_FILE_NAME = "contracts.yaml"
// export const VALID_CONTRACTS_LIST = ["ClancyERC721",
//     "MarketplaceERC721Escrow_v1",
// ]