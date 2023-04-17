import { contracts } from "@prisma/client";

import pgsql from "../../pgsql";
import utility from "../../utility";
import { EOAS } from "../../config/constants";
import { ContractContainer } from "../../types";

/**
 * Retrieves contract instances from the database and returns a ContractContainer object
 * @param contracts - a ContractContainer object to store the retrieved contract instances
 * @param names - An optional param that specifies which contracts to retrieve.
 * @returns a ContractContainer object containing the retrieved contract instances
 */
const getContractsFromDb = async (contracts: ContractContainer, names: string[] = []): Promise<ContractContainer> => {
    const db_contracts: contracts[] = await pgsql.contracts.get_all();
    if (names.length == 0 || names == undefined) {
        for (const db_contract of db_contracts) {
            if (!contracts[db_contract.contract_name]) {
                const privateKey = EOAS.DEPLOYMENT_KEY;
                const wallet = utility.blockchain.createWalletWithPrivateKey(privateKey);
                const contract = await utility.blockchain.createEthersContractFromDB(db_contract, wallet);

                contracts[db_contract.contract_name] = contract;
            }
        }
    } else {
        const wanted_contracts: contracts[] = db_contracts.filter((db_contract: contracts) => names.includes(db_contract.contract_name))
        for (const db_contract of wanted_contracts) {
            if (!contracts[db_contract.contract_name]) {
                const privateKey = EOAS.DEPLOYMENT_KEY;
                const wallet = utility.blockchain.createWalletWithPrivateKey(privateKey);
                const contract = await utility.blockchain.createEthersContractFromDB(db_contract, wallet);
                contracts[db_contract.contract_name] = contract;
            }
        }
    }
    return contracts;
}


export default getContractsFromDb
