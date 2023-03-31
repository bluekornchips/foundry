import { ethers } from "ethers"
import Ducky from "../../../../utility/logging/ducky"

const FILE_DIR = 'titan/collections/Euroleague/Series1/Moments'

/**
 * Sets the case contract address and its status on the moments contract.
 * @param moments_contract The moments contract instance.
 * @param case_contract_address The address of the case contract.
 * @param status The status to set for the case contract.
 * @returns A boolean indicating if the operation was successful.
 * @throws An error if the transaction fails or if any other error occurs.
 */
const setCaseContract = async (moments_contract: ethers.Contract, case_contract_address: string, status: boolean): Promise<boolean> => {
    Ducky.Debug(FILE_DIR, "setCaseContract", `Setting case contract ${case_contract_address} to ${status} on moments contract ${await moments_contract.getAddress()}.`)
    try {
        const tx: ethers.TransactionResponse = await moments_contract.setCaseContract(case_contract_address, status)
        const receipt = await tx.wait()
        if (receipt !== null) {
            Ducky.Debug(FILE_DIR, "setCaseContract", `Result: ${receipt.status === 1 ? "Success" : "Failure"}`)
        }
        else {
            Ducky.Error(FILE_DIR, "setCaseContract", `Result: ${tx}`)
            throw new Error(`Failed to set case contract ${case_contract_address} to ${status} on moments contract ${case_contract_address}.`)
        }
        return true
    } catch (error: any) {
        Ducky.Error(FILE_DIR, "setCaseContract", `Error: ${error}`)
        return false
    }
}

export default setCaseContract