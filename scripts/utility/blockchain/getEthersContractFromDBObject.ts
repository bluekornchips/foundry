import { contracts } from "@prisma/client";
import { ethers } from "ethers";
import { Ducky } from "../../client/logging/ducky/ducky";
import { getProvider } from "./getProvider";

const FILE_DIR = "utils/blockchain/contract"

export const getEthersContractFromDBObject = async (contract: contracts, wallet: any = undefined): Promise<ethers.Contract> => {

    let artifact: any = JSON.parse(contract.contract_artifact)

    try {
        if (wallet === undefined) {
            return new ethers.Contract(contract.contract_address, artifact.abi, getProvider())
        } else {
            return new ethers.Contract(contract.contract_address, artifact.abi, wallet)
        }
    }
    catch {
        Ducky.Error(FILE_DIR, `getEthersContractFromDBObject`, `Error creating ${contract.contract_name} contract instance.`)
        throw new Error(`Error creating ${contract.contract_name} contract instance.`)
    }
}