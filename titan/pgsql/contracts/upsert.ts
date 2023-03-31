import { contracts, PrismaClient } from "@prisma/client";
import { ethers } from "ethers";
import Ducky from "../../utility/logging/ducky";

const FILE_DIR = "titan/pgsql/contracts";
const prisma = new PrismaClient();

/**
 * Upserts a contract to the PostgreSQL database.
 * 
 * @param contract_name The name of the contract.
 * @param contract The ethers.js contract instance.
 * @param artifact The contract artifact.
 * 
 * @returns A Promise that resolves to the upserted contract.
 */
const upsert = async (contract_name: string, contract: ethers.Contract, artifact: any): Promise<contracts> => {
    const contract_address = await contract.getAddress();
    try {
        const contract_response: contracts = await prisma.contracts.upsert({
            create: {
                contract_name: contract_name,
                contract_address: contract_address,
                contract_artifact: JSON.stringify(artifact),
                odoo_token_id: 0,
                created_at: new Date(),
                updated_at: new Date(),
            },
            where: {
                contract_name: contract_name
            },
            update: {
                contract_name: contract_name,
                contract_address: contract_address,
                contract_artifact: JSON.stringify(artifact),
            },
        });
        Ducky.Debug(FILE_DIR, "upsert", `Upserted ${contract_name} to PostgreSQL`);
        return contract_response;
    } catch (error: any) {
        Ducky.Error(FILE_DIR, "upsert", error.message);
        throw new Error(error.message);
    }
}


export default upsert;