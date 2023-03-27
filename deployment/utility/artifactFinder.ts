import { Ducky } from "../client/logging/ducky";
import projectDirectory from "./projectDirectory";

const FILE_DIR = "deployment/utility";

const artifact_finder = (contract_name: string) => {
    try {
        const foundry_artifact = require(`${projectDirectory()}out/${contract_name}.sol/${contract_name}.json`);
    } catch (error: any) {
        Ducky.Critical(FILE_DIR, "artifact_finder", `Could not find artifact for ${contract_name} contract`);
        throw new Error(error.message);
    }
}

export default artifact_finder;