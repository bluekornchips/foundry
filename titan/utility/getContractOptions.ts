import { CONTRACT_CONFIG_FILE_NAME } from "../config/constants";
import { IContractOptions } from "../interfaces";

const fs = require('fs');
const yaml = require('js-yaml');

/**
 * @dev Loads the contract options from the specified YAML file and returns them
 * @return An object containing the contract options
 * @throws If there is an error loading the contract options from the specified YAML file
 */
const getContractOptions = (): IContractOptions => {
    try {
        const options: IContractOptions = yaml.load(fs.readFileSync(CONTRACT_CONFIG_FILE_NAME, 'utf8'));
        return options
    } catch (error: any) {
        const message = `Could not load ${CONTRACT_CONFIG_FILE_NAME}: ${error.message}`
        throw new Error(message)
    }
}

export default getContractOptions;