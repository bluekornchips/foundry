import { Ducky } from '../client/logging/ducky';
import utility from '../utility';
import yargs from 'yargs';
import deploy_contract from './deploy_contract';
import { VALID_CONTRACTS } from '../config/constants';
import { ethers } from 'ethers';

const argv = yargs.options({
    deploy: {
        alias: 'd',
        description: 'The contracts to be deployed',
        type: 'array',
        demandOption: false
    }
}).argv;

type ContractContainer = {
    [key: string]: {
        contract: ethers.Contract
    }
}


const main = async () => {
    const input_args = await argv
    console.log(utility.printRepeated("="))
    console.log(utility.printFancy("Deployment", true))
    console.log(utility.printRepeated("="))

    const contracts: ContractContainer = {}

    if (input_args.deploy) {
        // Ensure each input parameter is a string, and matches the VALID_CONTRACTS array
        const contract_names: string[] = input_args.deploy = input_args.deploy.map((element) => {
            if (VALID_CONTRACTS.includes(element as string)) {
                return element as string
            }
            else {
                const message = `Contract ${element} not found`
                Ducky.Error("Deployment", "main", message)
                throw new Error(message)
            }
        })
        for (const contract_name of contract_names) {
            const contract = await deploy_contract(contract_name)
            contracts[contract_name] = {
                contract: contract
            }
        }
    }
}

main().catch((error) => {
    console.error(error);
    process.exit(1);
});