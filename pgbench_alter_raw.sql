ALTER TABLE pgbench_history ALTER delta TYPE bytea USING encrypt(delta::text::bytea, 'secret'::bytea,'aes'::text),
                            ALTER mtime TYPE bytea USING encrypt(mtime::text::bytea, 'secret'::bytea,'aes'::text),
                            ALTER filler TYPE bytea USING encrypt(filler::bytea, 'secret'::bytea,'aes'::text);

-- Test
-- SELECT decrypt(delta,'secret'::bytea,'aes'::text)::int from pgbench_history;


ALTER TABLE pgbench_tellers
   ALTER tbalance TYPE bytea USING encrypt(tbalance::text::bytea, 'secret'::bytea,'aes'::text),
   ALTER filler TYPE bytea USING  encrypt(filler::bytea, 'secret'::bytea,'aes'::text);


ALTER TABLE pgbench_branches
      ALTER bbalance TYPE bytea USING encrypt(bbalance::text::bytea, 'secret'::bytea,'aes'::text),
      ALTER filler TYPE bytea USING  encrypt(filler::bytea, 'secret'::bytea,'aes'::text);


ALTER TABLE pgbench_accounts
            ALTER abalance TYPE bytea USING encrypt(abalance::text::bytea, 'secret'::bytea,'aes'::text),
            ALTER filler TYPE bytea USING  encrypt(filler::bytea, 'secret'::bytea,'aes'::text);
