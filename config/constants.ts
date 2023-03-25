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
export const SENTINEL_RPC = {
    URL: process.env.SENTINEL_RPC_URL,
    NAME: "sentinel_dev",
}