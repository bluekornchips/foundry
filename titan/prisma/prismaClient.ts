import { PrismaClient } from '@prisma/client'
import Ducky from '../utility/logging/ducky'
import getActiveEnv from '../forge/env'



let activeClient: PrismaClient
let prismaEuroleague: PrismaClient

const setPrismaClient = (db: string, env: string) => {
    const envVarName = `DATABASE_URL_${env.toLocaleUpperCase()}_${db.toUpperCase()}`

    if (!process.env[envVarName]) {
        Ducky.Critical(__filename, `setPrismaClient`, `No database url found for ${db}`)
    }
    else if (db === 'euroleague') {
        if (!prismaEuroleague) {
            prismaEuroleague = new PrismaClient({
                datasources: {
                    db: {
                        url: getActiveEnv().euroleague.database_url
                    }
                }
            })
        }
        Ducky.Debug(__filename, `setPrismaClient`, `Set prisma client for ${db}`)
        activeClient = prismaEuroleague
    }
}

export { activeClient, setPrismaClient }