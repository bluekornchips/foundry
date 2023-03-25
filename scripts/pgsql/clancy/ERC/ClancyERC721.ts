import { contracts, PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

export const ClancyERC721 = async (contract_name: string, contract_address: string, artifact: any): Promise<contracts> => {

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
}
