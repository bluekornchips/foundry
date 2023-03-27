import { Ducky } from '../client/logging/ducky';
import collections from '../collections';
import utility from '../utility';
import yargs from 'yargs';

const argv = yargs.options({
    packageName: {
        alias: 'p',
        description: 'The package to be run',
        type: 'string',
        demandOption: true
    }
}).argv;


const main = async () => {
    const input_args = await argv
    console.log(utility.printRepeated("="))
    console.log(utility.printFancy("Deployment", true))
    console.log(utility.printRepeated("="))

    // Use the package name in your code as needed
    Ducky.Info(`Deploying package: ${input_args.packageName}`);

    switch (input_args.packageName) {
        case "marketplace":
            await collections.clancy.marketplace.escrow.MarketplaceERC721Escrow_v1.deploy();
            break;
        case "erc721":
            await collections.clancy.ERC.ClancyERC721.deploy();
            break;
        default:
            Ducky.Error("Deployment", "main", `Package ${input_args.packageName} not found`);
            break;
    }
}


main().catch((error) => {
    console.error(error);
    process.exit(1);
});