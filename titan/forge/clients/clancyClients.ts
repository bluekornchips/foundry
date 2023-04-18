import { VALID_CLIENTS } from "../../config/constants";
import utility from "../../utility";
import Benfica from "./Benfica";
import Euroleague from "./Euroleague";

const main = async (input_args: string) => {
    utility.printFancy("Client Functions", true, 1)
    //Allow user to read the console
    // await new Promise((resolve) => setTimeout(resolve, 5000));
    switch (input_args) {
        case VALID_CLIENTS.euroleague:
            await Euroleague.deploy();
            break;
        case VALID_CLIENTS.benfica:
            await Benfica.liftAndShift();
        default:
            break;
    }
}

export default main;