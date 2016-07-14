#!/bin/bash
PGHOST=172.17.0.2
PGUSER=postgres
PGDB=cryptobench
SARFILE=data/sacfile

function execSQL ()
{
	#--output=/dev/null
	echo "Benchmarking $3 with $1, level $2, DB $4"

	# Using heredoc as the timing does not work with -c option and > /dev/null
	# as the redirection for the timing is merelly an output (it can't be redirected).
	# Possible solution, regexp. No thanks, now.
	psql -h $PGHOST -U$PGUSER  -n --set=timing=on --output=/dev/null $4 <<EOF |
\timing
select
convert_from(pgp_sym_decrypt_bytea(pgp_sym_encrypt_bytea((\$\$Text to be encrypted using pgp_sym_decrypt_bytea\$\$::bytea
|| ((gen_random_uuid())::text)::bytea), 'key'::text, 'compress-algo=$1, compress-level=$2, cipher-algo=$3'::text), 'key'::text), 'SQL-ASCII'::name) from generate_series(1,10000);
EOF
grep Time



}


for algo in bf aes128 aes192 aes256 3des aes256 ; do
	/usr/lib/sysstat/sadc -S XALL 1 50 ${SARFILE}_$algo &
	pid_sadc=$!
	for ca in $(seq 0 2) ; do   # compress-algo = 2 is Zlib with CRCs and metadata, should not affect the current test
		if [ $ca -eq 0 ]
		then
			execSQL $ca 0 $algo $PGDB
			continue
		fi
	  for lev in $(seq 0 9) ; do
				#echo "Benchmarking $algo with $ca, level $lev"
				execSQL $ca $lev $algo $PGDB
		done
	done
	kill $pid_sadc >& /dev/null
done
