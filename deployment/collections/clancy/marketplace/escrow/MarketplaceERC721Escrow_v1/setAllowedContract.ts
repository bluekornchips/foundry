import { ethers } from "ethers";
import { Ducky } from "../../../../../client/logging/ducky/ducky";
import contracts from "../../../../../contracts";
import pgsql from "../../../../../pgsql";
import utility from "../../../../../utility";

const FILE_DIR = "deployment/collections/marketplace/escrow/MarketplaceERC721Escrow_v1";

/**
 * @dev Sets the allowed state of an ERC721 contract in the specified marketplace contract
 * @param marketplace_name The name of the marketplace contract in PostgreSQL
 * @param erc721_contract_name The name of the ERC721 contract in PostgreSQL
 * @param allowed Whether the contract is allowed or not
 * @return A Promise resolving to a boolean indicating whether the operation was successful or not
 * @throws If the specified contracts cannot be found in PostgreSQL, or if there is an error setting the allowed state
 */
const setAllowedContract = async (marketplace_name: string, erc721_contract_name: string, allowed: boolean) => {
    const marketplace_contract_db = await pgsql.contracts.get(marketplace_name)
    if (!marketplace_contract_db) {
        const message = `Could not find contract ${marketplace_name} in PostgreSQL`
        Ducky.Error(FILE_DIR, "setAllowedContract", message)
        throw new Error(message);
    }

    const contract_db = await pgsql.contracts.get(erc721_contract_name)
    if (!contract_db) {
        const message = `Could not find contract ${erc721_contract_name} in PostgreSQL`
        Ducky.Error(FILE_DIR, "setAllowedContract", message)
        throw new Error(message);
    }

    const marketplace_contract: ethers.Contract = await utility.blockchain.createEthersContractFromDB(marketplace_contract_db);
    const erc721_contract: ethers.Contract = await utility.blockchain.createEthersContractFromDB(contract_db);

    const update_result: boolean = await contracts.clancy.marketplace.escrow.MarketplaceERC721Escrow_v1.setAllowedContract(marketplace_contract, erc721_contract, allowed);
    if (!update_result) {
        const message = `Could not set allowed contract ${erc721_contract_name} in contract ${marketplace_name}`
        Ducky.Error(FILE_DIR, "setAllowedContract", message)
        throw new Error(message);
    }
    Ducky.Debug(FILE_DIR, "setAllowedContract", `Allowed contract ${erc721_contract_name} in contract ${marketplace_name}`)

    return update_result;
}

export default setAllowedContract;