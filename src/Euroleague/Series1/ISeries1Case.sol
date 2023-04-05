// SPDX-License-Identifier: None
pragma solidity ^0.8.19;

interface ISeries1Case {
    error ReelsContractNotSet();
    error ReelsContractNotValid();
    error ReelsPerCaseNotValid();

    event CaseOpened(uint256 indexed token_id, address indexed case_address);
}
