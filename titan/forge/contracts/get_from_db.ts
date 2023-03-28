import { EOAS } from "../../config/constants"
import pgsql from "../../pgsql"
import createEthersContractFromDB from "../../utility/blockchain/createEthersContractFromDB"
import createWalletWithPrivateKey from "../../utility/blockchain/createWalletWithPrivateKey"
import { ContractContainer } from "../../types"

const get_from_db = async (contracts: ContractContainer): Promise<ContractContainer> => {

    //Get the remaining contracts from the db
    const db_contracts = await pgsql.contracts.get_all()
    // For each db_contract not in the contracts object, add it to the contracts object
    for (const db_contract of db_contracts) {
        if (!contracts[db_contract.contract_name]) {
            contracts[db_contract.contract_name] = await createEthersContractFromDB(db_contract, createWalletWithPrivateKey(EOAS.DEPLOYMENT_KEY))
        }
    }
    return contracts
}

export default get_from_db
