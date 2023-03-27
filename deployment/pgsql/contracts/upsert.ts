import { contracts, PrismaClient } from "@prisma/client";
import { ethers } from "ethers";
import { Ducky } from "../../client/logging/ducky/ducky";

const FILE_DIR = "deployment/pgsql/contracts";
const prisma = new PrismaClient();

/**
 * @dev Upserts the specified contract into the contracts table in PostgreSQL
 * @param contract_name The name of the contract to upsert
 * @param contract The contract instance to upsert
 * @param artifact The contract artifact containing the ABI and bytecode for the contract
 * @return A Promise resolving to the upserted contract
 * @throws If there is an error upserting the contract into PostgreSQL
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

        return contract_response;

    } catch (error: any) {
        Ducky.Critical(FILE_DIR, "upsert", error.message);
        throw new Error(error.message);
    }
}

export default upsert;