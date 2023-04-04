import { DuckyTypeEnum } from "../enum";

export type QuackContainer = {
    log_severity: DuckyTypeEnum;
    class_name: string;
    method_name: string;
    description: string;
    error_message?: string;
    created_at: Date;
}