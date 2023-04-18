// import { log_history } from "@prisma/client";

import { DuckyTypeEnum } from "./enum";
import dateHelper from "./dateHelper";
import cwd from "./cwd";

class Ducky {

    private static _logLevel = 3;
    private static _quackEnabled = true;
    private constructor() { }

    public static Critical(class_name: string, method_name: string, details: string, quack: boolean = false) {
        class_name = cwd(class_name)
        Ducky.Print(`[${this.printTypeAsString(DuckyTypeEnum.CRITICAL)}] >>> [${class_name} > ${method_name}] >> ${details} `, DuckyTypeEnum.ERROR);
    }

    public static Error(class_name: string, method_name: string, details: string, quack: boolean = false) {
        class_name = cwd(class_name)
        Ducky.Print(`[${this.printTypeAsString(DuckyTypeEnum.ERROR)}] >>> [${class_name} > ${method_name}] >> ${details} `, DuckyTypeEnum.ERROR);
    }

    public static Debug(class_name: string, method_name: string, details: string, quack: boolean = false) {
        class_name = cwd(class_name)
        Ducky.Print(`[${this.printTypeAsString(DuckyTypeEnum.DEBUG)}] >>> [${class_name} > ${method_name}] >> ${details} `, DuckyTypeEnum.DEBUG);
    }

    public static Info(details: any) {
        Ducky.Print(details, DuckyTypeEnum.INFO);
    }

    private static Print(message: string, severity: number) {
        // Replace all back slashes with forward slashes.
        message = message.replace(/\\/g, "/");
        if (severity <= this._logLevel) console.log(`[${dateHelper()}] >>>>> ${message}`);
    }

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

export default Ducky;