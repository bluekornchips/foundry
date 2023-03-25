import { contracts, PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

const reset_tokens = async () => {
    console.log(`Deleting tokens...`)
    await prisma.tokens.deleteMany();
    console.log(`Tokens Deleted!`)
    await prisma.$executeRaw`ALTER SEQUENCE tokens_id_seq RESTART WITH 1;`;
    console.log(`Tokens Identity Restarted!`)
}

export default reset_tokens;