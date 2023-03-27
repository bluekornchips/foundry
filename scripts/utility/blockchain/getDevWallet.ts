import { ethers } from "ethers";
import { EOAS } from "../../config/constants";
import { getProvider } from "./getProvider";

const getDevWallet = (): ethers.Wallet => {
    return new ethers.Wallet(EOAS.WALLET_PRIVATE_KEY_DEV, getProvider());
}

export default getDevWallet;