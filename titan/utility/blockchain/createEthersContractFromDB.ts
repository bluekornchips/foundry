import { ethers } from "ethers";

import { contracts } from "@prisma/client";

import getProvider from "./getProvider";
import Ducky from "../logging/ducky";

const createEthersContractFromDB = async (contract: contracts, wallet: any = undefined): Promise<ethers.Contract> => {

    let artifact: any = JSON.parse(contract.contract_artifact)

    try {
        if (wallet === undefined) return new ethers.Contract(contract.contract_address, artifact.abi, getProvider())
        else return new ethers.Contract(contract.contract_address, artifact.abi, wallet)
    }
    catch {
        Ducky.Error(__filename, `createEthersContractFromDB`, `Error creating ${contract.contract_name} contract instance.`)
        throw new Error(`Error creating ${contract.contract_name} contract instance.`)
    }
}

export default createEthersContractFromDB;