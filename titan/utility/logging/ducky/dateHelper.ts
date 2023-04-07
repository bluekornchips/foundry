/**
 * A helper function to format the date.
 * @returns The formatted date.
 */
const dateHelper = () => {
    const current = new Date();
    const options = {
        timeZone: 'America/Toronto',
    };
    // Remove the date from the formatted time.
    const formattedTime = current.toLocaleString('en-US', options).split(",")[1].trim();
    return formattedTime;
}

export default dateHelper