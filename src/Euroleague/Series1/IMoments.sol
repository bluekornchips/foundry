// SPDX-License-Identifier: None
pragma solidity ^0.8.17;

interface IMoments {
    error NotCaseContract();
    error CaseContractInvalid();

    event CaseContractSet(address indexed, bool indexed);
}
