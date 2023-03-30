import { VALID_CLIENTS } from "../../config/constants";
import utility from "../../utility";
import Euroleague from "./Euroleague";

const clancyClients = async (input_args: string) => {
    utility.printFancy("Client Functions", true, 1)
    //Allow user to read the console
    await new Promise((resolve) => setTimeout(resolve, 5000));
    switch (input_args) {
        case VALID_CLIENTS.Euroleague:
            await Euroleague.deploy();
            break;
        default:
            break;
    }
}

export default clancyClients;