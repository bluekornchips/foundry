import { ethers } from "ethers"
import Ducky from "../../../../utility/logging/ducky"



/**
 * Sets the case contract address and its status on the Reels contract.
 * @param Reels_contract The Reels contract instance.
 * @param case_contract_address The address of the case contract.
 * @param status The status to set for the case contract.
 * @returns A boolean indicating if the operation was successful.
 * @throws An error if the transaction fails or if any other error occurs.
 */
const setCaseContract = async (Reels_contract: ethers.Contract, case_contract_address: string, status: boolean): Promise<boolean> => {
    Ducky.Debug(__filename, "setCaseContract", `Setting case contract ${case_contract_address} to ${status} on Reels contract ${await Reels_contract.getAddress()}.`)
    try {
        const tx: ethers.TransactionResponse = await Reels_contract.setCaseContract(case_contract_address, status)
        const receipt = await tx.wait()
        if (receipt !== null) {
            Ducky.Debug(__filename, "setCaseContract", `Result: ${receipt.status === 1 ? "Success" : "Failure"}`)
        }
        else {
            Ducky.Error(__filename, "setCaseContract", `Result: ${tx}`)
            throw new Error(`Failed to set case contract ${case_contract_address} to ${status} on Reels contract ${case_contract_address}.`)
        }
        return true
    } catch (error: any) {
        Ducky.Error(__filename, "setCaseContract", `Error: ${error}`)
        return false
    }
}

export default setCaseContract