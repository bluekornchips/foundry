// SPDX-License-Identifier: None
pragma solidity ^0.8.19;

interface IMoments {
    error NotCaseContract();
    error CaseContractInvalid();

    event CaseContractSet(address indexed, bool indexed);
}
