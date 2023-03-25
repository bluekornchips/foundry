import { DuckyTypeEnum } from "./enum";
import { log_history } from "@prisma/client";
import dateHelper from "../../../utils/dateHelper";
/**
 * A wrapper class for logging.
 * Logs are output to the console, sent as notications, and/or sent to the server.
 * @class Ducky
 * @param {DuckyTypeEnum} type - The type of log.
 * @param {string} message - The message to log.
 * @param {string} [title] - The title of the log.
 * @param {string} [url] - The url to send the log to.
 * @param {string} [method] - The method to use when sending the log to the server.
 * @param {string} [data] - The data to send to the server.
 */
export class Ducky {

    private static _logLevel = 3;
    private static _quackEnabled = true;
    private constructor() { }

    public static Critical(class_name: string, method_name: string, details: string, quack: boolean = false) {
        Ducky.Print(`[${this.printTypeAsString(DuckyTypeEnum.CRITICAL)}] >>> [${class_name}.${method_name}] >> ${details} `, DuckyTypeEnum.ERROR);
        if (quack) this.Quack(class_name, method_name, details, DuckyTypeEnum.ERROR);
    }

    /**
     * 
     * @param class_name 
     * @param method_name 
     * @param details 
     * @param notify 
     * @param quack 
     */
    public static Error(class_name: string, method_name: string, details: string, quack: boolean = false) {
        Ducky.Print(`[${this.printTypeAsString(DuckyTypeEnum.ERROR)}] >>> [${class_name}.${method_name}] >> ${details} `, DuckyTypeEnum.ERROR);
        if (quack) this.Quack(class_name, method_name, details, DuckyTypeEnum.ERROR);
    }

    /**
     * @param class_name 
     * @param method_name 
     * @param details 
     * @param notify 
     * @param quack 
     */
    public static Debug(class_name: string, method_name: string, details: string, quack: boolean = false) {
        Ducky.Print(`[${this.printTypeAsString(DuckyTypeEnum.DEBUG)}] >>> [${class_name}.${method_name}] >> ${details} `, DuckyTypeEnum.DEBUG);
        if (quack) this.Quack(class_name, method_name, details, DuckyTypeEnum.DEBUG);
    }

    /**
     * For generic debugging to the console.
     * Will never send a notification or post to the server.
     * @param details 
     * @param notify 
     */
    public static Info(details: any) {
        Ducky.Print(details, DuckyTypeEnum.INFO);
    }

    /**
     * Output to the Console
     */
    private static Print(message: string, severity: number) {
        if (severity <= this._logLevel) console.log(`[${dateHelper()}] ${message}`);
    }

    /**
     * Post to the server
     * @param class_name_  
     * @param method_name_ 
     * @param description_ 
     * @param severity_ 
     */
    private static async Quack(class_name_: string, method_name_: string, description_: string, severity_: DuckyTypeEnum) {
        if (!this._quackEnabled) return;
    }

    /**
     * A helper function to convert the DuckyTypeEnum to a string.
     * @param type 
     * @returns 
     */
    private static printTypeAsString(type: DuckyTypeEnum) {
        switch (type) {
            case DuckyTypeEnum.CRITICAL:
                return "CRITICAL";
            case DuckyTypeEnum.ERROR:
                return "ERROR";
            case DuckyTypeEnum.DEBUG:
                return "DEBUG";
            case DuckyTypeEnum.INFO:
                return "INFO";
        }
    }
}
