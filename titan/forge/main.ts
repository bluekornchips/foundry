import yargs from 'yargs';

import clancyClients from './clients';
import nonClient from './nonClient';
import { COLLECTION_CONFIG_FILE_NAME, VALID_CLIENTS, VALID_CONTRACTS, VALID_ENVS } from '../config/constants';
import { setActiveEnv } from './env';
import { setPrismaClient } from '../prisma/prismaClient';
import utility from '../utility';

const argv = yargs.options({
    deploy: {
        alias: 'd',
        description: 'The contracts to be deployed',
        type: 'array',
        demandOption: false,
        choices: utility.getKeys(VALID_CONTRACTS),
        coerce: (arr) => {
            return arr.filter((item: any) => typeof item === 'string');
        },
    },
    coordinate: {
        alias: 'o',
        description: 'The setup to be run',
        type: 'array',
        demandOption: false,
        choices: utility.getKeys(VALID_CONTRACTS),
        coerce: (arr) => {
            return arr.filter((item: any) => typeof item === 'string');
        },
    },
    client: {
        alias: 'c',
        description: 'The clients packages to be built',
        type: 'string',
        demandOption: false,
        requiresArg: true,
        conflicts: ['coordinator'],
        choices: Object.keys(VALID_CLIENTS)
    },
    client_env: {
        alias: 'e',
        description: 'The clients environment to be used',
        type: 'string',
        demandOption: true,
        requiresArg: true,
        conflicts: ['coordinator'],
        choices: Object.keys(VALID_ENVS),
        when: 'client'
    },
}).config('config', COLLECTION_CONFIG_FILE_NAME)
    .argv;


const main = async () => {
    const input_args = await argv
    if (input_args.client !== undefined) {
        setActiveEnv(input_args.client, input_args.client_env)
        setPrismaClient(input_args.client)
        if (input_args.deploy !== undefined) {
            await nonClient.main(input_args)
        } else {
            await clancyClients(input_args.client)
        }
    }
}



main().catch((error) => {
    console.error(error);
    process.exit(1);
});
