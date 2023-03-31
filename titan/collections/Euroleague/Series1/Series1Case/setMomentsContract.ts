import { ethers } from "ethers"
import Ducky from "../../../../utility/logging/ducky"

const FILE_DIR = 'titan/collections/Euroleague/Series1/Moments'

/**
 * Sets the moments contract address for a given case contract.
 *
 * @param {ethers.Contract} case_contract - The case contract to set the moments contract for.
 * @param {string} moments_contract_address - The address of the moments contract to set.
 * @returns {Promise<boolean>} - True if the transaction was successful, false otherwise.
 * @throws Will throw an error if setting the moments contract fails.
 */
const setMomentsContract = async (case_contract: ethers.Contract, moments_contract_address: string): Promise<boolean> => {
    Ducky.Debug(FILE_DIR, "setMomentsContract", `Setting case contract ${await case_contract.getAddress()} moments to ${moments_contract_address}.`)
    try {
        const tx: ethers.TransactionResponse = await case_contract.setMomentsContract(moments_contract_address)
        const receipt = await tx.wait()
        if (receipt !== null) {
            Ducky.Debug(FILE_DIR, "setMomentsContract", `Result: ${receipt.status === 1 ? "Success" : "Failure"}`)
        } else {
            Ducky.Error(FILE_DIR, "setMomentsContract", `Result: ${tx}`)
            throw new Error(`Failed to set moments contract ${moments_contract_address} to moments contract ${moments_contract_address}.`)
        }
        return true
    } catch (error: any) {
        Ducky.Error(FILE_DIR, "setMomentsContract", `Error: ${error}`)
        return false
    }
}

export default setMomentsContract