import { contracts, PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

const reset_contracts = async () => {
    console.log(`Deleting contracts...`)
    await prisma.contracts.deleteMany();
    console.log(`contracts Deleted!`)
    await prisma.$executeRaw`ALTER SEQUENCE contracts_id_seq RESTART WITH 1;`;
    console.log(`contracts Identity Restarted!`)
}

export default reset_contracts;