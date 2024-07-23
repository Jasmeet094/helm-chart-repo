#!/usr/bin/env bash

export PGDATABASE=djangostack
export PGPORT=6432

TIME_PER_RUN=300

for file in *.sql; do
    exec >"${file%%\.sql}.log" 2>&1
    echo -e "*** RESULTS FOR ${file}\n\n"
    for concurrency in 1 5 10 25 50 100 500 1000; do
        echo -e "*** Running with concurrency ${concurrency}\n"
        pgbench -n -c "$concurrency" -j "$concurrency" -T "$TIME_PER_RUN" -f "$file"
        echo "----------------"
    done
    for concurrency in 1 5 10 25 50 100 500 1000; do
        echo -e "*** Running with concurrency ${concurrency}\n"
        for _ in {1..4}; do # Five runs, to be safe
            pgbench -n -c "$concurrency" -j "$concurrency" -T "$TIME_PER_RUN" -f "$file"
            echo "----------------"
        done
    done
done
