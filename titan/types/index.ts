import { contracts_db } from './prisma';

export * from './prisma'

import { ethers } from "ethers"

/**
 * A mapped object of deployed contracts.
 */
export type ContractContainer = {
    [key: string]: ethers.Contract
}

export type ValidContracts = {
    [key: string]: string
}