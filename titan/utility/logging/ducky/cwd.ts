/**
 * Gets the current directory path, starting from the "blockchain-middleware" directory.
 * @throws {Error} If the current directory path does not contain the "blockchain-middleware" substring.
 * @returns The contents of the path after the "blockchain-middleware" substring.
 */
const cwd = (path: string): string => {
    const currentPath: string = path;
    const index: number = currentPath.indexOf('blockchain-middleware');
    if (index === -1) throw new Error('Current directory path does not contain "blockchain-middleware" substring.');
    return currentPath.substring(index + 'blockchain-middleware'.length + 1);
}

export default cwd;