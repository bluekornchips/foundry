// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Chains {
    mapping(string => address) public _polygon;
    mapping(string => address) public _eth;

    constructor() {
        setPolygon();
        setEth();
    }

    function setPolygon() private {
        // Aave
        _polygon[
            "POOL_ADDRESS_PROVIDER"
        ] = 0xa97684ead0e402dC232d5A977953DF7ECBaB3CDb;

        // Uniswap
        _polygon[
            "UNISWAP_SWAPROUTER"
        ] = 0xE592427A0AEce92De3Edee1F18E0157C05861564;

        // Stablecoins
        _polygon["USDC"] = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
        _polygon["DAI"] = 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063;
    }

    function setEth() private {
        // Aave
        _eth[
            "POOL_ADDRESS_PROVIDER"
        ] = 0x2f39d218133AFaB8F2B819B1066c7E434Ad94E9e;

        // Uniswap
        _eth["UNISWAP_SWAPROUTER"] = 0xE592427A0AEce92De3Edee1F18E0157C05861564;

        // Meme Coins
        _eth["PEPE"] = 0x6982508145454Ce325dDbE47a25d4ec3d2311933;

        // Wrapped Ether
        _eth["WETH"] = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

        //Stablecoins
        _eth["USDC"] = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    }
}
