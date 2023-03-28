import { contracts, PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

/**
 * @dev Retrieves the specified contract from the contracts table in PostgreSQL
 * @param contract_name The name of the contract to retrieve
 * @return A Promise resolving to the retrieved contract
 * @throws If the contract cannot be found in PostgreSQL
 */
const get = async (contract_name: string): Promise<contracts> => {
    const contract_response = await prisma.contracts.findUnique({
        where: {
            contract_name: contract_name
        }
    });

    if (!contract_response) {
        throw new Error(`Could not find contract ${contract_name} in PostgreSQL`);
    }

    return contract_response;
}

export default get;