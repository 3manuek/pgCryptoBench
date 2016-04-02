\set nbranches :scale
\set ntellers 10 * :scale
\set naccounts 100000 * :scale
\setrandom aid 1 :naccounts
\setrandom bid 1 :nbranches
\setrandom tid 1 :ntellers
\setrandom delta -5000 5000
BEGIN;

-- UPDATE pgbench_accounts
--   SET abalance = pgp_sym_encrypt_bytea( ( convert_from(pgp_sym_decrypt_bytea(abalance, $$secret$$::text), 'SQL_ASCII')::int + 2)::text::bytea, $$secret$$::text ) WHERE aid = 1;

UPDATE pgbench_accounts SET abalance = pgp_sym_encrypt_bytea( ( convert_from(pgp_sym_decrypt_bytea(abalance, $$secret$$::text),'SQL_ASCII')::int + :delta)::text::bytea, $$secret$$::text ) WHERE aid = :aid;
SELECT convert_from(pgp_sym_decrypt_bytea(abalance, $$secret$$::text),'SQL_ASCII')::int FROM pgbench_accounts WHERE aid = :aid;
UPDATE pgbench_tellers SET tbalance = pgp_sym_encrypt_bytea( ( convert_from(pgp_sym_decrypt_bytea(tbalance, $$secret$$::text),'SQL_ASCII')::int + :delta)::text::bytea, $$secret$$::text ) WHERE tid = :tid;
UPDATE pgbench_branches SET bbalance = pgp_sym_encrypt_bytea( ( convert_from(pgp_sym_decrypt_bytea(bbalance, $$secret$$::text),'SQL_ASCII')::int + :delta)::text::bytea, $$secret$$::text ) WHERE bid = :bid;
INSERT INTO pgbench_history (tid, bid, aid, delta, mtime) VALUES (:tid, :bid, :aid, pgp_sym_encrypt_bytea((:delta)::text::bytea, $$secret$$::text), pgp_sym_encrypt_bytea((CURRENT_TIMESTAMP)::text::bytea, $$secret$$::text));
END;
-- WORKING !
