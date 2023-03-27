import { Ducky } from "../client/logging/ducky";
import projectDirectory from "./projectDirectory";

const FILE_DIR = "deployment/utility";

/**
 * @dev Finds the artifact for the specified contract in the out directory and returns it
 * @param contract_name The name of the contract to find the artifact for
 * @return The artifact for the specified contract
 * @throws If there is an error finding the artifact for the specified contract
 */
const artifact_finder = (contract_name: string): any => {
    try {
        const foundry_artifact = require(`${projectDirectory()}out/${contract_name}.sol/${contract_name}.json`);
        return foundry_artifact;
    } catch (error: any) {
        Ducky.Critical(FILE_DIR, "artifact_finder", `Could not find artifact for ${contract_name} contract`);
        throw new Error(error.message);
    }
}

export default artifact_finder;