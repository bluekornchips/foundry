const LINE_WIDTH = 80;
/**
 * Prints a fancy block of text to the console.
 * 
 * @param content The text to print.
 * @param centered Whether or not the text should be centered.
 * @param lines_padding The number of blank lines to print before and after the text.
 */
export const printFancy = (content: string, centered: boolean = false, lines_padding: number = 0) => {
    let line = "";

    if (centered) {
        let left_spaces = 0;
        let right_spaces = 0;
        const content_length = content.length;
        const total_spaces = LINE_WIDTH - content_length;
        left_spaces = Math.floor(total_spaces / 2) - 1;
        right_spaces = Math.ceil(total_spaces / 2) - 1;
        const left_padding = " ".repeat(left_spaces);
        const right_padding = " ".repeat(right_spaces);
        line = `|${left_padding}${content}${right_padding}|`;
    } else {
        // If we don't want the content centered, we just need to add spaces to the right of the content
        const content_length = content.length;
        const total_spaces = LINE_WIDTH - content_length;
        const right_padding = " ".repeat(total_spaces);
        line = `${content}${right_padding}`;
    }

    // Print the top block of the fancy text
    console.log(topBlock());

    // Print any padding lines before the content
    for (let i = 0; i < lines_padding; i++) {
        console.log(enclosedLine(" "));
    }

    // Print the content line
    console.log(line);

    // Print any padding lines after the content
    for (let i = 0; i < lines_padding - 1; i++) {
        console.log(enclosedLine(" "));
    }

    // Print the bottom block of the fancy text
    console.log(enclosedLine("_"));
}

/**
 * Returns a string that can be used to print the top block of a fancy text block.
 * 
 * @returns The top block string.
 */
const topBlock = (): string => {
    return printRepeated("_");
}

/**
 * Returns a string that can be used to print an enclosed line of a fancy text block.
 * 
 * @param repeatedChar The character to repeat for the line.
 * 
 * @returns The enclosed line string.
 */
const enclosedLine = (repeatedChar: string): string => {
    //Print a line of underscores, with a | on either side
    const line = printRepeated(repeatedChar);
    // Replace the first and last character of the line with a |, to create a block
    return `|${line.slice(1, -1)}|`;
}

/**
 * Returns a string with a repeated character for the specified line width.
 * 
 * @param content The character to repeat.
 * 
 * @returns The repeated string.
 */
const printRepeated = (content: string): string => {
    let line = "";
    for (let i = 0; i < LINE_WIDTH; i++) {
        line += content;
    }
    return line;
}
