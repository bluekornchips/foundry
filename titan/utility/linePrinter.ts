const LINE_WIDTH = 80;

/**
 * Returns a string containing the input string padded with spaces to form a centered or left-aligned line, 
 * depending on the value of the `centered` parameter. 
 *
 * @param {string} content - The string to be padded with spaces.
 * @param {boolean} [centered=false] - A boolean value indicating whether the content should be centered or left-aligned. Defaults to false.
 * @returns {string} A string containing the input string padded with spaces to form a centered or left-aligned line.
 */
export const printFancy = (content: string, centered: boolean = false): string => {
    let line = "";
    // If we want the content centered, we need to calculate the number of spaces to add to the left and right of the content
    let left_spaces = 0;
    let right_spaces = 0;
    if (centered) {
        const content_length = content.length;
        const total_spaces = LINE_WIDTH - content_length;
        left_spaces = Math.floor(total_spaces / 2) - 1;
        right_spaces = Math.ceil(total_spaces / 2) - 1;
        line = "|" + " ".repeat(left_spaces) + content + " ".repeat(right_spaces) + "|";
    }
    else {
        // If we don't want the content centered, we just need to add spaces to the right of the content
        const content_length = content.length;
        const total_spaces = LINE_WIDTH - content_length;
        line = content + " ".repeat(total_spaces);
    }
    return line
}

/**
 * Returns a string containing a repeated pattern of the input string up to the specified line width. 
 *
 * @param {string} content - The string to be repeated in the output string.
 * @returns {string} A string containing the repeated input string up to the specified line width.
 */
export const printRepeated = (content: string): string => {
    let line = "";
    for (let i = 0; i < LINE_WIDTH; i++) {
        line += content;
    }
    return line;
}