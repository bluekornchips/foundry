import { PROJECT_NAME } from "../../../config/constants";

/**
 * Gets the current directory path, starting from the {PROJECT_NAME} directory.
 * @throws {Error} If the current directory path does not contain the "blockchain-middleware" substring.
 * @returns The contents of the path after the {PROJECT_NAME} substring.
 */
const cwd = (path: string): string => {
    const currentPath: string = path;
    const index: number = currentPath.indexOf(PROJECT_NAME);
    if (index === -1) throw new Error(`Current directory path does not contain "${PROJECT_NAME}" substring.`);
    return currentPath.substring(index + PROJECT_NAME.length + 1);
}

export default cwd;