import { PrismaClient } from "@prisma/client";
import { Ducky } from "../../../client/logging/ducky/ducky";

const FILE_DIR = "deployment/pgsql/helpers/reset";
const prisma = new PrismaClient();

/**
 * @dev Resets the tokens table by deleting all records and resetting the identity counter
 * @throws If there is an error deleting records or resetting the identity counter
 */

const reset_tokens = async () => {
    Ducky.Debug(FILE_DIR, 'reset_tokens', `Deleting tokens...`)
    try {
        await prisma.tokens.deleteMany();
        Ducky.Debug(FILE_DIR, 'reset_tokens', `Tokens Deleted!`)
        await prisma.$executeRaw`ALTER SEQUENCE tokens_id_seq RESTART WITH 1;`;
        Ducky.Debug(FILE_DIR, 'reset_tokens', `Tokens Identity Restarted!`)
    } catch (error: any) {
        const message = `Error resetting tokens: ${error.message}`
        Ducky.Critical(FILE_DIR, 'reset_tokens', message)
        throw new Error(message);
    }
}

export default reset_tokens;