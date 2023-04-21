// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Chains {
    mapping(string => mapping(string => address)) public _chains;

    constructor() {
        setPolygon();
    }

    function setPolygon() private {
        _chains["polygon"][
            "POOL_ADDRESS_PROVIDER"
        ] = 0xa97684ead0e402dC232d5A977953DF7ECBaB3CDb;
        _chains["polygon"][
            "SWAPROUTER"
        ] = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
        _chains["polygon"]["USDC"] = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
        _chains["polygon"]["DAI"] = 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063;
    }
}
