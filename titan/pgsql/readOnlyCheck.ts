import { DATABASE_READONLY } from "../config/constants"
import Ducky from "../utility/logging/ducky";

const isReadOnly = (): boolean => {
    if (DATABASE_READONLY) {
        Ducky.Info("Database read only.")
        return true;
    }
    return false;
}

export default isReadOnly