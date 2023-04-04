import Ducky from "./logging/ducky";

const dir = process.cwd()

const PROJECT_NAME = "foundry";

/**
 * Returns the project directory path as a string. 
 * If the current directory contains the project name, the project directory path is returned 
 * with the project name as the last directory. 
 * Otherwise, an error message is logged, and the process is exited. 
 *
 * @returns {string} The project directory path as a string.
 */
const projectDirectory = (): string => {
    let matching_dir = dir;
    if (dir.includes(PROJECT_NAME)) {
        matching_dir = dir.substring(0, dir.indexOf(PROJECT_NAME));
        matching_dir = matching_dir.replace(/\\/g, "/");
        return matching_dir.concat(`${PROJECT_NAME}/`);
    }
    else {
        Ducky.Error(__filename, "projectDirectory", `Could not find ${__filename} directory`);
        process.exit(1);
    }
}

export default projectDirectory;