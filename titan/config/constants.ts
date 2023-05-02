require("dotenv").config();

// # Project
export const ENV = process.env.ENV || 'DEV';
export const PROJECT_NAME = process.env.PROJECT_NAME || "foundry"
export const VALID_ENVS = {
    dev: "dev",
    qa: "qa",
    uat: "uat",
    prod: "prod",
}
export const DATABASE_READONLY = false;

export const DATABASE_URL = {
    EUROLEAGUE: {
        DEV: process.env.DATABASE_URL_DEV_EUROLEAGUE || "",
        QA: process.env.DATABASE_URL_QA_EUROLEAGUE || "",
        UAT: process.env.DATABASE_URL_UAT_EUROLEAGUE || "",
    },
    BENFICA: {
        PROD: process.env.DATABASE_URL_PROD_BENFICA || "",
    }
}

// # Blockchain
export const RPC = {
    URL: process.env.RPC_URL_SENTINEL_DEV
}

export const EOAS = {
    DEPLOYMENT_KEY: process.env.DEPLOYMENT_KEY || ""
}

export const VALID_CONTRACTS = {
    Clancy: {
        ERC: {
            ClancyERC721: "ClancyERC721",
            ClancyERC20: "ClancyERC20",
            ClancyERC20Airdrop: "ClancyERC20Airdrop",
        },
        Marketplace: {
            EscrowERC721: "EscrowERC721",
            OffersERC721: "OffersERC721",

        }
    },
    Euroleague: {
        Reels: "Reels",
        Clutch: "Clutch",
        CrunchTime: "CrunchTime",
        HeatinUp: "HeatinUp",
        SlamPacked: "SlamPacked",
        Swishin: "Swishin",
    }
}

export const VALID_CLIENTS = {
    euroleague: "euroleague",
    benfica: "benfica",
}

// # Titan
export const COLLECTION_CONFIG_FILE_NAME = "collection-config.json"

// # Odoo
export const ODOO_PACK_INFO = {
    EUROLEAGUE: {
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
    },
    BENFICA: {
        PROD: {
            PACKS: 1,
            REELS: 2
        }
    }
}