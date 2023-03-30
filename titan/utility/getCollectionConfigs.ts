import { COLLECTION_CONFIG_FILE_NAME } from "../config/constants";
import { ICollectionConfigs } from "../interfaces";

const fs = require('fs');

/**
 * Retrieves the collection configurations from the collection configuration file.
 *
 * @returns The collection configurations as an ICollectionConfigs object.
 * @throws An error if the configuration file cannot be found or cannot be read.
 */
const getCollectionConfigs = (): ICollectionConfigs => {
    try {
        // Check if the file exists
        if (!fs.existsSync(COLLECTION_CONFIG_FILE_NAME)) {
            const message = `Could not find ${COLLECTION_CONFIG_FILE_NAME}`
            throw new Error(message)
        }
        // Read the json file
        const configs: ICollectionConfigs = JSON.parse(fs.readFileSync(COLLECTION_CONFIG_FILE_NAME, 'utf8'))
        return configs
    } catch (error: any) {
        const message = `Could not load ${COLLECTION_CONFIG_FILE_NAME}: ${error.message}`
        throw new Error(message)
    }
}

export default getCollectionConfigs;