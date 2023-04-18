const pull = (client: string): string => {
    const command_pull = `npx prisma db pull --schema=./titan/prisma/clancyClients/${client}.prisma`;
    return command_pull;
}

export default pull;