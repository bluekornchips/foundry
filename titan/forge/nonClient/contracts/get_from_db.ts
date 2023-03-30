import createEthersContractFromDB from "../../../utility/blockchain/createEthersContractFromDB"
import createWalletWithPrivateKey from "../../../utility/blockchain/createWalletWithPrivateKey"
import { ContractContainer } from "../../../types"
import { EOAS } from "../../../config/constants"
import pgsql from "../../../pgsql"

/**
 * Retrieves contract instances from the database and returns a ContractContainer object
 * @param contracts - a ContractContainer object to store the retrieved contract instances
 * @returns a ContractContainer object containing the retrieved contract instances
 */
const get_from_db = async (contracts: ContractContainer): Promise<ContractContainer> => {
    const db_contracts = await pgsql.contracts.get_all();

    for (const db_contract of db_contracts) {
        if (!contracts[db_contract.contract_name]) {
            const privateKey = EOAS.DEPLOYMENT_KEY;
            const wallet = createWalletWithPrivateKey(privateKey);
            const contract = await createEthersContractFromDB(db_contract, wallet);

            contracts[db_contract.contract_name] = contract;
        }
    }

    return contracts;
}


export default get_from_db
