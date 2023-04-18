import { dev_contracts, qa_contracts, uat_contracts } from "@prisma/client";
import { dev_tokens, qa_tokens, uat_tokens } from "@prisma/client";
import { dev_users, qa_users, uat_users } from "@prisma/client";

// Prisma Wrappers
export type contracts_db = dev_contracts | qa_contracts | uat_contracts;
export type tokens_db = dev_tokens | qa_tokens | uat_tokens;
export type users_db = dev_users | qa_users | uat_users;