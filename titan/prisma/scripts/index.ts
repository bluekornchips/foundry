import yargs from 'yargs';

import generate from './generate';
import pull from './pull';
import { execSync } from 'child_process';
import { VALID_CLIENTS } from '../../config/constants';

const argv = yargs.options({
    schema: {
        alias: 's',
        description: 'The clients schema to be used',
        type: 'string',
        demandOption: true,
        requiresArg: true,
        choices: Object.keys(VALID_CLIENTS)
    },
    prisma: {
        alias: 'p',
        description: 'The prisma command to be used',
        type: 'string',
        demandOption: true,
        requiresArg: true,
    },
}).argv;

const execute_command = (command: string) => {
    try {
        execSync(command, { stdio: 'inherit' });
    } catch (error) {
        console.log(error);
        process.exit(1);
    }
}

const main = async () => {
    const input_args = await argv
    let command = ""
    if (input_args.prisma === 'pull') command = pull(input_args.schema);
    if (input_args.prisma === 'generate') command = generate(input_args.schema);
    execute_command(command);
}

main().catch((error) => {
    console.error(error);
    process.exit(1);
});