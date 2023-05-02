import { IClancyConfig } from "./clancy/IClancyConfig";
import { IEuroleagueConfig } from "./EuroleagueConfig";

/// Defines the structure of an object containing configurations for different collections.
export interface ICollectionConfigs {
    Clancy: IClancyConfig;
    Euroleague: IEuroleagueConfig;
}
