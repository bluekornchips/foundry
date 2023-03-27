import { getProvider } from "./getProvider"
import { getEthersContractFromDBObject } from "./getEthersContractFromDBObject"
import getDevWallet from "./getDevWallet"

const blockchain = {
    getDevWallet,
    getProvider,
    getEthersContractFromDBObject
}

export default blockchain