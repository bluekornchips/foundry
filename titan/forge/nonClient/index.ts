import main from "./nonClient";
import getContractsFromDb from "./getContractsFromDb";
import coordinator from "./coordinator";

const nonClient = {
    main,
    coordinator,
    getContractsFromDb
}

export default nonClient;