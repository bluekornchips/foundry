import { execSync } from 'child_process';

const valid_schemas = ['euroleague'];

// Input args
const [_, __, ...args] = process.argv;
const schema_root = `./titan/prisma/`

const pull = (): string => {
    const command_pull = `npx prisma db pull --schema=${schema_root}`;
    let command = '';
    if (valid_schemas.includes(args[1])) {
        command = `${command_pull}${args[1]}.prisma`;
    }
    else {
        console.log(`Invalid schema name.\nSchemas: ${valid_schemas.join(', ')}`);
        process.exit(1);
    }
    return command;
}

const generate = (): string => {
    const command_generate = `npx prisma generate --schema=${schema_root}`;
    let command = '';
    if (valid_schemas.includes(args[1])) {
        command = `${command_generate}${args[1]}.prisma`;
    }
    else {
        console.log(`Invalid schema name.\nSchemas: ${valid_schemas.join(', ')}`);
        process.exit(1);
    }
    return command;
}

const execute_command = (command: string) => {
    // Execute the command
    try {
        execSync(command, { stdio: 'inherit' });
    } catch (error) {
        console.log(error);
        process.exit(1);
    }
}

const main = () => {
    if (args.length < 2) {
        console.log(`Please provide a command and a schema name.\nCommands: pull, generate\nSchemas: ${valid_schemas.join(', ')}`);
        process.exit(1);
    }

    let command = ""
    if (args[0] === 'pull') command = pull();
    if (args[0] === 'generate') command = generate();
    execute_command(command);
}

main();