import { ethers } from "ethers";

import Ducky from "../../utility/logging/ducky";
import getActiveEnv from "../../forge/env";
import { activeClient } from "../../prisma/prismaClient";
import { contract_type_db, contracts_db } from "../../types";

/**
 * Upserts a contract to the PostgreSQL database.
 * @param contract_name The name of the contract.
 * @param contract      The ethers.js contract instance.
 * @param artifact      The contract artifact.
 * @returns             A Promise that resolves to the upserted contract.
*/
const upsert = async (contract_name: string, contract: ethers.Contract, odoo_token_id: number, contract_type: contract_type_db, artifact: any): Promise<contracts_db> => {
    const contract_address = await contract.getAddress();
    try {
        const contract_response: contracts_db = await activeClient[`${getActiveEnv().env}_contracts`].upsert({
            create: {
                contract_name: contract_name,
                contract_address: contract_address,
                contract_artifact: JSON.stringify(artifact),
                odoo_token_id: odoo_token_id,
                created_at: new Date(),
                updated_at: new Date(),
                contract_type: contract_type
            },
            where: {
                contract_name: contract_name
            },
            update: {
                contract_name: contract_name,
                contract_address: contract_address,
                contract_artifact: JSON.stringify(artifact),
                odoo_token_id: odoo_token_id,
                updated_at: new Date(),
            },
        });
        Ducky.Debug(__filename, "upsert", `Upserted ${contract_name} to PostgreSQL`);
        return contract_response;
    } catch (error: any) {
        Ducky.Error(__filename, "upsert", error.message);
        throw new Error(error.message);
    }
}

export default upsert;