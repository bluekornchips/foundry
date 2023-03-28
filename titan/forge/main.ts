import { Ducky } from '../client/logging/ducky';
import yargs from 'yargs';
import deploy from './contracts/deploy';
import { ContractContainer } from '../types';
import get_from_db from './contracts/get_from_db';
import { CONTRACT_CONFIG_FILE_NAME, VALID_CONTRACTS } from '../config/constants';
import coordinator from './coordinator';

const argv = yargs.options({
    deploy: {
        alias: 'd',
        description: 'The contracts to be deployed',
        type: 'array',
        demandOption: false,
        coerce: (arr) => {
            return arr.filter((item: any) => typeof item === 'string');
        },
    },
    coordinator: {
        alias: 'c',
        description: 'The setup to be run',
        type: 'array',
        demandOption: false,
        coerce: (arr) => {
            return arr.filter((item: any) => typeof item === 'string');
        },
    },
}).config('config', CONTRACT_CONFIG_FILE_NAME)
    .argv;


const main = async () => {
    const input_args = await argv
    let contracts: ContractContainer = await get_from_db({})

    if (input_args.deploy) contracts = await deploy(input_validaton(input_args.deploy))
    if (input_args.coordinator) {
        input_validaton(input_args.coordinator)
        contracts = await coordinator(contracts)
    }
}

const input_validaton = (inputs: string[]): string[] => {
    // Ensure each input parameter is a string, and matches the VALID_CONTRACTS array
    const validated_inputs: string[] = inputs = inputs.map((element) => {
        // If the element matches a known key in VALID_CONTRACTS, return the key
        if (typeof element !== "string") return ""
        if (Object.keys(VALID_CONTRACTS).includes(element)) return element
        else {
            const message = `Contract ${element} not found`
            Ducky.Error("Deployment", "main", message)
            throw new Error(message)
        }
    }).filter((element) => element !== "")
    return validated_inputs
}

main().catch((error) => {
    console.error(error);
    process.exit(1);
});