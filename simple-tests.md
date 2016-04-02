



## Symmetric encryption tests

PGP symmetric encryption using different compression algorithms.


### Testing compression algorithms:

Default compression-level = 6. aes128 is the default algorithm.

```
\o /dev/null
select convert_from(pgp_sym_decrypt_bytea(pgp_sym_encrypt_bytea(($$Text to be encrypted using pgp_sym_decrypt_bytea$$::bytea || ((gen_random_uuid())::text)::bytea), 'key'::text, 'compress-algo=2'::text), 'key'::text), 'SQL-ASCII'::name) from generate_series(1,10000);

select convert_from(pgp_sym_decrypt_bytea(pgp_sym_encrypt_bytea(($$Text to be encrypted using pgp_sym_decrypt_bytea$$::bytea || ((gen_random_uuid())::text)::bytea), 'key'::text, 'compress-algo=1'::text), 'key'::text), 'SQL-ASCII'::name) from generate_series(1,10000);

select convert_from(pgp_sym_decrypt_bytea(pgp_sym_encrypt_bytea(($$Text to be encrypted using pgp_sym_decrypt_bytea$$::bytea || ((gen_random_uuid())::text)::bytea), 'key'::text, 'compress-algo=0'::text), 'key'::text), 'SQL-ASCII'::name) from generate_series(1,10000);
```

> Using forced casting for improving the planning phase.

#### Result

Using only CPU and memory (disabling writing to a table):

```
\o /dev/null
test=# select convert_from(pgp_sym_decrypt_bytea(pgp_sym_encrypt_bytea('Text to be encrypted using pgp_sym_decrypt_bytea' || gen_random_uuid()::text::bytea,'key', 'compress-algo=2'),'key'),'SQL-ASCII') from generate_series(1,10000);
Time: 14981,497 ms
test=# select convert_from(pgp_sym_decrypt_bytea(pgp_sym_encrypt_bytea('Text to be encrypted using pgp_sym_decrypt_bytea' || gen_random_uuid()::text::bytea,'key', 'compress-algo=1'),'key'),'SQL-ASCII')  from generate_series(1,10000);
Time: 14976,375 ms
test=# select convert_from(pgp_sym_decrypt_bytea(pgp_sym_encrypt_bytea('Text to be encrypted using pgp_sym_decrypt_bytea' || gen_random_uuid()::text::bytea,'key', 'compress-algo=0'),'key'),'SQL-ASCII') from generate_series(1,10000);
Time: 14445,014 ms
```

```
 EXPLAIN (ANALYZE true, BUFFERS true, TIMING true, COSTS true)
```

## Testing algorithms (No compression)

```

select convert_from(pgp_sym_decrypt_bytea(pgp_sym_encrypt_bytea(($$Text to be encrypted using pgp_sym_decrypt_bytea$$::bytea || ((gen_random_uuid())::text)::bytea), 'key'::text, 'compress-algo=0'::text), 'key'::text), 'SQL-ASCII'::name) from generate_series(1,10000); -- aes128


select convert_from(pgp_sym_decrypt_bytea(pgp_sym_encrypt_bytea(($$Text to be encrypted using pgp_sym_decrypt_bytea$$::bytea || ((gen_random_uuid())::text)::bytea), 'key'::text, 'compress-algo=0, cipher-algo=bf'::text), 'key'::text), 'SQL-ASCII'::name) from generate_series(1,10000);


select convert_from(pgp_sym_decrypt_bytea(pgp_sym_encrypt_bytea(($$Text to be encrypted using pgp_sym_decrypt_bytea$$::bytea || ((gen_random_uuid())::text)::bytea), 'key'::text, 'compress-algo=0, cipher-algo=aes192'::text), 'key'::text), 'SQL-ASCII'::name) from generate_series(1,10000);


select convert_from(pgp_sym_decrypt_bytea(pgp_sym_encrypt_bytea(($$Text to be encrypted using pgp_sym_decrypt_bytea$$::bytea || ((gen_random_uuid())::text)::bytea), 'key'::text, 'compress-algo=0, cipher-algo=3des'::text), 'key'::text), 'SQL-ASCII'::name) from generate_series(1,10000);

select convert_from(pgp_sym_decrypt_bytea(pgp_sym_encrypt_bytea(($$Text to be encrypted using pgp_sym_decrypt_bytea$$::bytea || ((gen_random_uuid())::text)::bytea), 'key'::text, 'compress-algo=0, cipher-algo=cast5'::text), 'key'::text), 'SQL-ASCII'::name) from generate_series(1,10000);

```


Values: bf, aes128, aes192, aes256 (OpenSSL-only: 3des, cast5)


#### Results

```
test=# select convert_from(pgp_sym_decrypt_bytea(pgp_sym_encrypt_bytea(($$Text to be encrypted using pgp_sym_decrypt_bytea$$::bytea || ((gen_random_uuid())::text)::bytea), 'key'::text, 'compress-algo=0'::text), 'key'::text), 'SQL-ASCII'::name) from generate_series(1,10000); -- aes128
Time: 14370,141 ms
test=#
test=#
test=# select convert_from(pgp_sym_decrypt_bytea(pgp_sym_encrypt_bytea(($$Text to be encrypted using pgp_sym_decrypt_bytea$$::bytea || ((gen_random_uuid())::text)::bytea), 'key'::text, 'compress-algo=0, cipher-algo=bf'::text), 'key'::text), 'SQL-ASCII'::name) from generate_series(1,10000);
Time: 15365,116 ms
test=#
test=#
test=# select convert_from(pgp_sym_decrypt_bytea(pgp_sym_encrypt_bytea(($$Text to be encrypted using pgp_sym_decrypt_bytea$$::bytea || ((gen_random_uuid())::text)::bytea), 'key'::text, 'compress-algo=0, cipher-algo=aes192'::text), 'key'::text), 'SQL-ASCII'::name) from generate_series(1,10000);
Time: 29413,692 ms
test=#
test=#
test=# select convert_from(pgp_sym_decrypt_bytea(pgp_sym_encrypt_bytea(($$Text to be encrypted using pgp_sym_decrypt_bytea$$::bytea || ((gen_random_uuid())::text)::bytea), 'key'::text, 'compress-algo=0, cipher-algo=3des'::text), 'key'::text), 'SQL-ASCII'::name) from generate_series(1,10000);
Time: 28774,683 ms
test=# select convert_from(pgp_sym_decrypt_bytea(pgp_sym_encrypt_bytea(($$Text to be encrypted using pgp_sym_decrypt_bytea$$::bytea || ((gen_random_uuid())::text)::bytea), 'key'::text, 'compress-algo=0, cipher-algo=cast5'::text), 'key'::text), 'SQL-ASCII'::name) from generate_series(1,10000);
Time: 14526,856 ms
```
