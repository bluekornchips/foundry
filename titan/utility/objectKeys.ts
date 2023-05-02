
function getLowestLevelKeys(obj: any, parentKey: string = ''): string[] {
    const keys: string[] = [];
    for (const key in obj) {
        // Construct the full key path
        const fullKey = parentKey ? `${parentKey}.${key}` : key;

        // Check if the value is an object and not an array
        if (typeof obj[key] === 'object' && !Array.isArray(obj[key])) {
            // If the value is an object, call the function recursively
            const nestedKeys = getLowestLevelKeys(obj[key], fullKey);
            keys.push(...nestedKeys);
        } else {
            // If the value is not an object, add the key to the array
            keys.push(fullKey);
        }
    }
    // Find the last index of "." and return the string after it
    const lastDotIndex = keys[0].lastIndexOf('.');
    if (lastDotIndex !== -1) {
        return keys.map(key => key.substring(lastDotIndex + 1));
    }
    return keys;
}

const getKeys = (obj: any, parentKey: string = ''): string[] => {
    const keys: string[] = getLowestLevelKeys(obj, parentKey);
    return keys
}

export default getKeys