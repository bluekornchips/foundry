const pull = (env: string, client: string): string => {
    const command_pull = `npx prisma db pull --schema=./titan/prisma/${env}/${client}.prisma`;
    return command_pull;
}

export default pull;