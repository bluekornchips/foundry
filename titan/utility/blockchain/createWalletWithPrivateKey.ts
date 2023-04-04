import { ethers } from "ethers";

import getProvider from "./getProvider";
import Ducky from "../logging/ducky";

/**
 * @dev Creates an ethers wallet instance with the specified private key and the configured provider
 * @param private_key The private key to use for the wallet
 * @return The created wallet instance
 * @throws If there is an error creating the wallet instance
 */
const createWalletWithPrivateKey = (private_key: string): ethers.Wallet => {
    try {
        return new ethers.Wallet(private_key, getProvider());
    } catch (error: any) {
        Ducky.Critical(__filename, "createWalletWithPrivateKey", error.message)
        throw new Error(error.message);
    }
}

export default createWalletWithPrivateKey;