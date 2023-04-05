import { ethers } from "ethers"
import Ducky from "../../../../utility/logging/ducky"



/**
 * Sets the Reels contract address for a given case contract.
 *
 * @param {ethers.Contract} case_contract - The case contract to set the Reels contract for.
 * @param {string} Reels_contract_address - The address of the Reels contract to set.
 * @returns {Promise<boolean>} - True if the transaction was successful, false otherwise.
 * @throws Will throw an error if setting the Reels contract fails.
 */
const setReelsContract = async (case_contract: ethers.Contract, Reels_contract_address: string): Promise<boolean> => {
    Ducky.Debug(__filename, "setReelsContract", `Setting case contract ${await case_contract.getAddress()} Reels to ${Reels_contract_address}.`)
    try {
        const tx: ethers.TransactionResponse = await case_contract.setReelsContract(Reels_contract_address)
        const receipt = await tx.wait()
        if (receipt !== null) {
            Ducky.Debug(__filename, "setReelsContract", `Result: ${receipt.status === 1 ? "Success" : "Failure"}`)
        } else {
            Ducky.Error(__filename, "setReelsContract", `Result: ${tx}`)
            throw new Error(`Failed to set Reels contract ${Reels_contract_address} to Reels contract ${Reels_contract_address}.`)
        }
        return true
    } catch (error: any) {
        Ducky.Error(__filename, "setReelsContract", `Error: ${error}`)
        return false
    }
}

export default setReelsContract