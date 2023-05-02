import { IClancyERC721ContractConfig } from "./clancy";

export interface IEuroleagueReelConfig extends IClancyERC721ContractConfig { }

export interface EuroleagueSeries1Config {
    Series1Cases: IClancyERC721ContractConfig[]; // Naming required because of reserved word "case".
    Reels: IEuroleagueReelConfig;
}

export interface ISeries1CaseConfig extends IClancyERC721ContractConfig {
    reelsPerCase: number;
}

export interface IEuroleagueConfig {
    ERC: EuroleagueSeries1Config;
}