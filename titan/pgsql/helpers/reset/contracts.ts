import { PrismaClient } from "@prisma/client";
import { FILE } from "dns";
import { Ducky } from "../../../client/logging/ducky/ducky";

const FILE_DIR = "titan/pgsql/helpers/reset";
const prisma = new PrismaClient();

/**
 * @dev Resets the contracts table by deleting all records and resetting the identity counter
 * @throws If there is an error deleting records or resetting the identity counter
 */
const reset_contracts = async () => {
    Ducky.Debug(FILE_DIR, 'reset_contracts', `Deleting contracts...`)
    try {
        await prisma.contracts.deleteMany();
        Ducky.Debug(FILE_DIR, 'reset_contracts', `contracts Deleted!`)
        await prisma.$executeRaw`ALTER SEQUENCE contracts_id_seq RESTART WITH 1;`;
        Ducky.Debug(FILE_DIR, 'reset_contracts', `contracts Identity Restarted!`)
    } catch (error: any) {
        const message = `Error resetting contracts: ${error.message}`
        Ducky.Critical(FILE_DIR, 'reset_contracts', message);
        throw new Error(message);
    }
}

export default reset_contracts;