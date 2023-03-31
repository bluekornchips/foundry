import { DATABASE_URL, ODOO_PACK_INFO } from "../../config/constants";

export interface IActiveEnv {
    env: string
    euroleague: {
        database_url: string,
        odoo_token_ids: any
    }
}

let activeEnv: IActiveEnv;

const getActiveEnv = (): IActiveEnv => {
    return activeEnv
}

export const setActiveEnv = (client: string, env: string) => {
    switch (env.toUpperCase()) {
        case "DEV":
            activeEnv = {
                env: env,
                euroleague: {
                    database_url: DATABASE_URL.EUROLEAGUE.DEV,
                    odoo_token_ids: ODOO_PACK_INFO.DEV
                }
            }
            break;
        case "QA":
            activeEnv = {
                env,
                euroleague: {
                    database_url: DATABASE_URL.EUROLEAGUE.QA,
                    odoo_token_ids: ODOO_PACK_INFO.QA
                }
            }
            break;
        case "UAT":
            activeEnv = {
                env,
                euroleague: {
                    database_url: DATABASE_URL.EUROLEAGUE.UAT,
                    odoo_token_ids: ODOO_PACK_INFO.UAT
                }
            }
            break;
        default:
            throw new Error("Invalid environment")
    }
}

export default getActiveEnv