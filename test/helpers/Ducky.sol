// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

contract Ducky is Test {
    uint8 CONSOLE_WIDTH = 80;

    string BIG_LINE;
    string SMALL_LINE;

    constructor() {
        setLines();
    }

    function ppBig(string memory params) public view {
        console.log(BIG_LINE);
        console.log("");
        console.log(centeredText(params));
        console.log("");
        console.log(BIG_LINE);
    }

    // function ppIndent(
    //     string memory params,
    //     uint8 indentAmount,
    //     string memory indentChar
    // ) public view {
    //     string memory indent = "";
    //     for (uint256 i = 0; i < indentAmount; i++) {
    //         indent = string(abi.encodePacked(indent, indentChar));
    //     }
    //     console.log(indent, params);
    // }

    function ppLines(uint8 lineCount) public view {
        for (uint256 i = 0; i < lineCount; i++) {
            console.log("");
        }
    }

    function ppHeader(
        string memory line,
        string memory headerStyle,
        uint8 width
    ) public view {
        ppLine(headerStyle, width);
        console.log(line);
        ppLine(headerStyle, width);
    }

    function ppLine(string memory headerStyle, uint8 width) public view {
        string memory line = "";
        for (uint256 i = 0; i < CONSOLE_WIDTH / width; i++) {
            line = string(abi.encodePacked(line, headerStyle));
        }
        console.log(line);
    }

    function ppSmall(string memory params) public view {
        console.log(SMALL_LINE);
        console.log(centeredText(params));
        console.log(SMALL_LINE);
    }

    function setLines() private {
        for (uint256 i = 0; i < CONSOLE_WIDTH; i++) {
            BIG_LINE = string(abi.encodePacked(BIG_LINE, "="));
            SMALL_LINE = string(abi.encodePacked(SMALL_LINE, "-"));
        }
    }

    function centeredText(
        string memory text
    ) private view returns (string memory) {
        uint256 textLength = bytes(text).length;
        uint256 padding = (CONSOLE_WIDTH - textLength) / 2;
        string memory paddingString = "";
        for (uint256 i = 0; i < padding; i++) {
            paddingString = string(abi.encodePacked(paddingString, " "));
        }
        return string(abi.encodePacked(paddingString, text));
    }
}
