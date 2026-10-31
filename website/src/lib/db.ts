import mysql from "mysql2/promise";

// Single shared read pool. The website is read-only against the live game DB;
// point DB_USER at a SELECT-only MySQL user in production (see README).
declare global {
  // eslint-disable-next-line no-var
  var _looneyPool: mysql.Pool | undefined;
}

export const DB_INSTANCE = Number(process.env.DB_INSTANCE ?? 1);

export function pool(): mysql.Pool {
  if (!global._looneyPool) {
    global._looneyPool = mysql.createPool({
      host: process.env.DB_HOST ?? "127.0.0.1",
      port: Number(process.env.DB_PORT ?? 3306),
      user: process.env.DB_USER ?? "looneybin",
      password: process.env.DB_PASSWORD ?? "",
      database: process.env.DB_NAME ?? "looneybin",
      connectionLimit: 8,
      charset: "utf8mb4",
      // numbers can exceed JS safe int (bigint cols); keep as string then coerce where needed
      supportBigNumbers: true,
      bigNumberStrings: false,
      dateStrings: false,
    });
  }
  return global._looneyPool;
}

export async function q<T = Record<string, unknown>>(
  sql: string,
  params: unknown[] = []
): Promise<T[]> {
  const [rows] = await pool().query(sql, params);
  return rows as T[];
}

export async function one<T = Record<string, unknown>>(
  sql: string,
  params: unknown[] = []
): Promise<T | null> {
  const rows = await q<T>(sql, params);
  return rows[0] ?? null;
}

/** Coerce a possibly-bigint/string numeric column to a JS number. */
export function num(v: unknown, d = 0): number {
  if (v === null || v === undefined) return d;
  const n = typeof v === "number" ? v : Number(v);
  return Number.isFinite(n) ? n : d;
}
