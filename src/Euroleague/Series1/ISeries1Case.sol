// SPDX-License-Identifier: None
pragma solidity ^0.8.17;

interface ISeries1Case {
    error MomentsContractNotSet();
    error MomentsContractNotValid();
    error MomentsPerCaseNotValid();

    event CaseOpened(uint256 indexed token_id, address indexed case_address);
}
