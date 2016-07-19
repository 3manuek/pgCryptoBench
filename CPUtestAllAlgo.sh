#!/bin/bash
PGHOST=172.17.0.2
PGUSER=postgres
PGDB=cryptobench
DATAFOLDER=data
SARFILE=${DATAFOLDER}/sacfile
ENTRIES=${DATAFOLDER}/stats.csv
THREADS=$(lscpu | awk '/^CPU\(s\):/ {print $2}')

# For the sar output.
LC_ALL=C
S_TIME_FORMAT=ISO


function execSQL ()
{
	#--output=/dev/null

	# Using heredoc as the timing does not work with -c option and > /dev/null
	# as the redirection for the timing is merelly an output (it can't be redirected).
	# Possible solution, regexp. No thanks, now.
	psql "postgresql://${PGUSER}@${PGHOST}/${PGDB}?application_name=test"  -n --output=/dev/null $4 <<EOF |
\timing
select
convert_from(pgp_sym_decrypt_bytea(pgp_sym_encrypt_bytea((\$\$Text to be encrypted using pgp_sym_decrypt_bytea\$\$::bytea
|| ((gen_random_uuid())::text)::bytea), 'key'::text, 'compress-algo=$1, compress-level=$2, cipher-algo=$3'::text), 'key'::text), 'SQL-ASCII'::name) from generate_series(1,10000);
EOF
grep Time | tr ',' '.' | awk  '{ print "'"$3"'" ","'$1'","'$2'"," $2 }' >> $ENTRIES  &

	CURTHD=$5

  if [ $CURTHD -gt 0 ] ; then
		execSQL $1 $2 $3 $4 $(( CURTHD - 1 ))
	fi
#Benchmarking bf with 0, level 0, DB cryptobench
#Time: 16707,233 ms

}

mv -f $ENTRIES ${ENTRIES}_$(date +%s) 2> /dev/null
touch $ENTRIES

for algo in bf aes128 aes192 aes256 3des ; do
	/usr/lib/sysstat/sadc -S XALL 1 50 ${SARFILE}_$algo &
	pid_sadc=$!
	for ca in $(seq 0 2) ; do   # compress-algo = 2 is Zlib with CRCs and metadata, should not affect the current test
		if [ $ca -eq 0 ]
		then
			execSQL $ca 0 $algo $PGDB $THREADS
			while [ $(psql -Upostgres -h172.17.0.2 -tnA -c 'select count(*) from pg_stat_activity where application_name ~ $$test$$') -gt 0 ]
			do
					sleep 1
			done
			continue
		fi
	  for lev in $(seq 0 9) ; do
				#echo "Benchmarking $algo with $ca, level $lev"
				execSQL $ca $lev $algo $PGDB $THREADS
				while [ $(psql -Upostgres -h172.17.0.2 -tnA -c 'select count(*) from pg_stat_activity where application_name ~ $$test$$') -gt 0 ]
				do
						sleep 1
				done
		done

	done

	kill $pid_sadc >& /dev/null
done

# Added to convert into kSar format.
for i in $(ls ${SARFILE}* ); do
	LC_ALL=C sar -A -f $i >> "${i}_ksar"
done
