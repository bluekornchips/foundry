import { DATABASE_URL, ODOO_PACK_INFO } from "../../config/constants";

export interface IActiveEnv {
    env: string
    client: string
    database_url: string,
    odoo_token_ids: any
}

let activeEnv: IActiveEnv;

const getActiveEnv = (): IActiveEnv => {
    return activeEnv
}

export const setActiveEnv = (client: string, env: string) => {
    switch (client) {
        case "euroleague": euroleague(env)
            break;
        case "benfica": benfica(env)
            break;
        default: throw new Error("Invalid client")

    }
}

const euroleague = (env: string) => {
    activeEnv = {
        client: "euroleague",
        env,
        database_url: "",
        odoo_token_ids: undefined
    }
    switch (env.toLocaleLowerCase()) {
        case "dev":
            activeEnv.database_url = DATABASE_URL.EUROLEAGUE.DEV,
                activeEnv.odoo_token_ids = ODOO_PACK_INFO.EUROLEAGUE.DEV
            break;
        case "qa":
            activeEnv.database_url = DATABASE_URL.EUROLEAGUE.QA,
                activeEnv.odoo_token_ids = ODOO_PACK_INFO.EUROLEAGUE.QA
            break;
        case "uat":
            activeEnv.database_url = DATABASE_URL.EUROLEAGUE.UAT,
                activeEnv.odoo_token_ids = ODOO_PACK_INFO.EUROLEAGUE.UAT
            break;
        default:
            throw new Error("Invalid environment")
    }
}

const benfica = (env: string) => {
    switch (env.toUpperCase()) {
        case "PROD":
            activeEnv = {
                client: "benfica",
                env,
                database_url: DATABASE_URL.BENFICA.PROD,
                odoo_token_ids: ODOO_PACK_INFO.BENFICA.PROD
            }
            break;
        default:
            throw new Error("Invalid environment")
    }
}


export default getActiveEnv