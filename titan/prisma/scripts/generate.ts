const generate = (env: string, client: string): string => {
    const command_generate = `npx prisma generate --schema=./titan/prisma/${env}/${client}.prisma`;
    return command_generate;
}

export default generate;