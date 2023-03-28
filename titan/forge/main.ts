import { Ducky } from '../client/logging/ducky';
import yargs from 'yargs';
import deploy from './contracts/deploy';
import { ContractContainer } from '../types';
import get_from_db from './contracts/get_from_db';
import { CONTRACT_CONFIG_FILE_NAME, VALID_CONTRACTS } from '../config/constants';
import coordinator from './coordinator';
import marketplace from './marketplace';

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
    marketplace: {
        alias: 'm',
        description: 'Add the contracts to the marketplace',
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

    if (input_args.deploy) {
        const deployed_contracts: ContractContainer = await deploy(input_validaton(input_args.deploy))
        contracts = { ...contracts, ...deployed_contracts }
    }
    if (input_args.coordinator) {
        const inputs = input_validaton(input_args.coordinator)
        if (inputs.length < 1) throw new Error("No valid coordinator inputs")

        // Create a new ContractCoordinator instance with the matching inputs as keys
        const contracts_to_be_coordinated = Object.fromEntries(Object.entries(contracts).filter(([key]) => inputs.includes(key)))
        await coordinator(contracts_to_be_coordinated)
    }
    if (input_args.marketplace) {
        const inputs = input_validaton(input_args.marketplace)
        if (inputs.length < 1) throw new Error("No valid coordinator inputs")
        const contracts_to_be_coordinated = Object.fromEntries(Object.entries(contracts).filter(([key]) => inputs.includes(key)))
        await marketplace.setAllowedContracts(contracts[VALID_CONTRACTS.MarketplaceERC721Escrow_v1], contracts_to_be_coordinated)
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