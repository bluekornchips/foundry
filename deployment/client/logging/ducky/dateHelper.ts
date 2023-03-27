/**
 * A helper function to format the date.
 * @returns The formatted date.
 */
const dateHelper = () => {
    const current = new Date()
    const options = { timeZone: 'America/Toronto' }
    const formattedDate = current.toLocaleString('en-US', options)
    return formattedDate
}

export default dateHelper