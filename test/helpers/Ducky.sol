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
    //     for (uint256 i; i < indentAmount; i++) {
    //         indent = string(abi.encodePacked(indent, indentChar));
    //     }
    //     console.log(indent, params);
    // }

    function ppLines(uint8 lineCount) public view {
        for (uint256 i; i < lineCount; i++) {
            console.log("");
        }
    }

    function ppHeader(
        string memory line,
        string memory headerStyle
    ) public view {
        uint8 lineWidth = uint8(bytes(line).length + 4);

        ppLine(headerStyle, lineWidth);

        string memory formattedLine = string(abi.encodePacked("| ", line));
        uint256 lineLength = lineWidth - bytes(line).length - 3;

        for (uint256 i; i < lineLength; i++) {
            formattedLine = string(abi.encodePacked(formattedLine, " "));
        }

        formattedLine = string(abi.encodePacked(formattedLine, "|"));
        console.log(formattedLine);

        ppLine(headerStyle, lineWidth);
    }

    function ppSubHeader(string memory line, uint8 width) public view {
        uint8 lineWidth = (CONSOLE_WIDTH / width);
        console.log(string(abi.encodePacked(" ", line)));
        ppLine("*", lineWidth);
    }

    function ppLine(string memory headerStyle, uint8 width) public view {
        string memory line = "";
        for (uint256 i; i < width; i++) {
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
        for (uint256 i; i < CONSOLE_WIDTH; i++) {
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
        for (uint256 i; i < padding; i++) {
            paddingString = string(abi.encodePacked(paddingString, " "));
        }
        return string(abi.encodePacked(paddingString, text));
    }
}
