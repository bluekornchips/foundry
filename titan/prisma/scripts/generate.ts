const generate = (client: string): string => {
    const command_generate = `npx prisma generate --schema=./titan/prisma/clancyClients/${client}.prisma`;
    return command_generate;
}

export default generate;