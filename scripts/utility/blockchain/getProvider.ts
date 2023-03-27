import { ethers } from "ethers"
import { RPC } from "../../config/constants"

export const getProvider = () => {
    return new ethers.providers.JsonRpcProvider(RPC.URL)
}