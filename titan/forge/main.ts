import yargs from 'yargs';
import { COLLECTION_CONFIG_FILE_NAME, VALID_CLIENTS, VALID_CONTRACTS } from '../config/constants';
import clancyClients from './clients';
import nonClient from './nonClient';

const argv = yargs.options({
    deploy: {
        alias: 'd',
        description: 'The contracts to be deployed',
        type: 'array',
        demandOption: false,
        choices: Object.keys(VALID_CONTRACTS),
        coerce: (arr) => {
            return arr.filter((item: any) => typeof item === 'string');
        },
    },
    coordinate: {
        alias: 'o',
        description: 'The setup to be run',
        type: 'array',
        demandOption: false,
        choices: Object.keys(VALID_CONTRACTS),
        coerce: (arr) => {
            return arr.filter((item: any) => typeof item === 'string');
        },
    },
    marketplace: {
        alias: 'm',
        description: 'Add the contracts to the marketplace',
        type: 'array',
        demandOption: false,
        choices: Object.keys(VALID_CONTRACTS),
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
        conflicts: ['deploy', 'coordinator', 'marketplace'],
        choices: Object.keys(VALID_CLIENTS)
    }
}).config('config', COLLECTION_CONFIG_FILE_NAME)
    .argv;


const main = async () => {
    const input_args = await argv
    if (input_args.client !== undefined) await clancyClients(input_args.client)
    else await nonClient(input_args)
}


main().catch((error) => {
    console.error(error);
    process.exit(1);
});