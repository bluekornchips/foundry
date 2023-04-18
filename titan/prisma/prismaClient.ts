import { PrismaClient } from '@prisma/client';
import Ducky from '../utility/logging/ducky/ducky';
import getActiveEnv from '../forge/env';


let activeClient: PrismaClient;
let prismaEuroleague: PrismaClient;

/**
 * Defines a Prisma client for a given database and environment and exports it.
 * @param db The name of the database to connect to.
 * @returns The Prisma client object for the specified database and environment.
 */
const setPrismaClient = (db: string) => {
    const envVarName = `DATABASE_URL_${db.toUpperCase()}`;

    if (!process.env[envVarName]) {
        Ducky.Critical(__filename, `setPrismaClient`, `No database URL found for ${db}`);
    } else if (db === 'euroleague') {
        if (!prismaEuroleague) {
            prismaEuroleague = new PrismaClient({
                datasources: {
                    db: {
                        url: getActiveEnv().database_url,
                    },
                },
            });
        }
        activeClient = prismaEuroleague;
    }

};

export { activeClient, setPrismaClient };
