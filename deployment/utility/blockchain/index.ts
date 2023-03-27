import getProvider from "./getProvider"
import createEthersContractFromDB from "./createEthersContractFromDB"
import createWalletWithPrivateKey from "./createWalletWithPrivateKey"

const blockchain = {
    createWalletWithPrivateKey,
    getProvider,
    createEthersContractFromDB
}


export default blockchain