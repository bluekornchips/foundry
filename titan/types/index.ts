import { ethers } from "ethers"

export type ContractContainer = {
    [key: string]: ethers.Contract
}

export type ValidContracts = {
    [key: string]: string
}