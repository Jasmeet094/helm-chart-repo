#!/usr/bin/env python3

"""Migrate a Postgres database from one server to another.

Before you begin, make sure the credentials to connect to the database are specified
in a file called creds.yml alongside this file. For information about the structure
of the file, see validate_psql.py.

Setup:

1. Create a virtualenv with psycopg2

    virtualenv -p /usr/bin/python3 .venv
    source .venv/bin/activate
    pip install psycopg2

2. Create a pgpassword file with credentials for the src and destination database.
    Note that, for the sake of simplicity, you must connect to both databases using a
    username and password. You can find information on the format of the pgpass file at:
    https://www.postgresql.org/docs/current/libpq-pgpass.html

    Make sure you have a line in your PGPASSFILE for each endpoint listed in the "creds"
    variable, immediately below the imports, which are immediately after this doc block.

To run:

unset PGDATABASE PGHOST PGPASSWORD PGPORT PGUSER
export PGPASSFILE=~/.pgpass

source .venv/bin/activate
python3 pg_dump.py
"""

import logging
from collections import namedtuple
from collections.abc import Iterator
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime

# ruff: noqa: S404
from subprocess import PIPE, Popen

import psycopg2

creds = {
    "src": {
        "host": "127.0.0.1",
        "user": "dms_test",
        "port": 7432,
    },
    "dst": {
        "host": "127.0.0.1",
        "user": "postgres",
        "port": 6432,
    },
}


# ruff: noqa: FBT001, FBT002
def get_hup(cred: dict, d: bool = False) -> str:
    """Build host, user, and port command line arguments.

    Use this function to build a string containing the arguments that you can use
    as part of a command. The input should be a value from the "creds" dictionary
    above - that is to say, another dictionary.

    This function will return a string that looks like:

        -h <cred.host> -U <cred.user> -p <cred.port>

    This function will raise a KeyError if any of those keys do not exist.
    """
    res = f"-h {cred['host']} -U {cred['user']} -p {cred['port']}"
    if d:
        res = f"{res} {cred['dbname']}"
    return res


def pgdump_schema() -> None:
    """Recreate a database and schema (only) from one cluster into another cluster.

    The source schema is extracted via pg_dump, using `-Cc` to drop and recreate the database. Did
    you get that last bit? The database is going to be dropped and recreated. You should also know
    that it dumps out a sql file, grep -v's `CREATE INDEX`, and pipes that to `psql`. In practice
    that means you're going to be missing some indexes, but not all indexes. Any indexes that come
    from a table specification (PRIMARY KEY, UNIQUE, etc) will still be created along with their
    table constaints.
    """
    logging.info("creating schema")

    src_creds = get_hup(creds["src"])
    dst_creds = get_hup(creds["dst"])
    # ruff: noqa: E501
    cmd = f"pg_dump -Ccs {src_creds} --quote-all-identifiers djangostack | grep -v 'CREATE INDEX' | psql {dst_creds} postgres"
    logging.info("cmd is %s", cmd)

    start = datetime.now()
    # ruff: noqa: S602
    exe = Popen(cmd, stdout=PIPE, stderr=PIPE, shell=True)
    exe.communicate()
    end = datetime.now()
    logging.info("created schema in %s", end - start)


# ruff: noqa: ANN001
def create_users(conn) -> None:
    """Create the bucardo and bitnami users."""
    logging.info("creating users")
    start = datetime.now()
    with conn, conn.cursor() as cur:
        cur.execute(
            """
            CREATE USER bucardo
            WITH IN ROLE rds_superuser
            ENCRYPTED PASSWORD 'md5c52c3e45a37f1d698d118715049f7c5d';
            """
        )
        cur.execute(
            """
            CREATE USER bitnami
            WITH ENCRYPTED PASSWORD 'md5acd88f14f5033c6bc8a1685bdc9b38a7';
            """
        )
    end = datetime.now()
    logging.info("created users in %s", end - start)


def get_constraints(conn) -> Iterator[tuple]:
    """Generate a list of constraints from the pg_constraint system table.

    This generator will yield one tuple with columns (name, table, schema)
    for each constraint listed in pg_constraint.
    """
    q = """
    SELECT conname, relname AS table_name, nspname AS schema_name
    FROM pg_constraint
    JOIN pg_class ON (pg_constraint.conrelid = pg_class.oid)
    JOIN pg_namespace ON (pg_constraint.connamespace = pg_namespace.oid)
    WHERE nspname not like 'pg_%'
        AND nspname != 'information_schema'
    """
    with conn.cursor() as cur:
        cur.execute(q)
        yield from cur


def drop_constraint(conn, name: str, table_name: str, schema_name: str) -> None:
    """Drop the constraint identified by the parameters."""
    q = f'ALTER TABLE "{schema_name}"."{table_name}" DROP CONSTRAINT IF EXISTS {name} CASCADE;'
    with conn, conn.cursor() as cur:
        cur.execute(q)


def drop_constraints(conn) -> None:
    """Find and drop all constraints from all tables."""
    logging.info("dropping constraints")
    start = datetime.now()
    count = 0
    for c in get_constraints(conn):
        drop_constraint(conn, c[0], c[1], c[2])
        count = count + 1
    end = datetime.now()
    logging.info("dropped %s constraints in %s", count, end - start)


def get_tables(conn) -> Iterator[tuple]:
    """Generate a list of all tables (ala pg_tables) for the given conn."""
    logging.info("getting tables")
    q = """
    SELECT schemaname, tablename
    FROM   pg_tables
    WHERE  schemaname NOT LIKE 'pg_%'
    AND    schemaname != 'information_schema'
    """
    with conn.cursor() as cur:
        cur.execute(q)
        yield from cur


def copy_table(schema: str, table: str) -> str:
    """Copy table from source to destination database using pg_dump."""
    logging.info("copying table %s.%s", schema, table)
    src_creds = get_hup(creds["src"])
    dst_creds = get_hup(creds["dst"])
    cmd = f"pg_dump -a -b -Fc {src_creds} -t '{schema}.{table}' --quote-all-identifiers djangostack"
    cmd = cmd + f" | pg_restore -a -Fc {dst_creds} -d djangostack --disable-triggers"
    logging.debug("cmd is %s", cmd)

    start = datetime.now()
    exe = Popen(cmd, stdout=PIPE, stderr=PIPE, shell=True)
    stdout, stderr = exe.communicate()
    end = datetime.now()
    logging.info("created table %s.%s in %s", schema, table, end - start)
    return stdout, stderr


def copy_data() -> None:
    """Copy postgres table data."""
    with ThreadPoolExecutor(max_workers=256) as executor:
        conn = psycopg2.connect(**creds["src"], dbname="djangostack")
        t2t = {executor.submit(copy_table, row[0], row[1]): row for row in get_tables(conn)}
        conn.close()
        for future in as_completed(t2t):
            row = t2t[future]
            try:
                stdout, stderr = future.result()
            # ruff: noqa: BLE001
            except Exception:
                logging.exception("%s.%s generated error", row[0], row[1])
            else:
                logging.info("stdout from table %s.%s is %s", row[0], row[1], stdout)
                logging.info("stderr from table %s.%s is %s", row[0], row[1], stderr)


def find_missing_indexes(src_conn, dst_conn) -> set[str]:
    """Find missing indexes in the dst databases."""
    q = """
    SELECT nspname, relname
    FROM pg_class
    JOIN pg_namespace ON (pg_namespace.oid = pg_class.relnamespace)
    WHERE nspname != 'information_schema'
    AND nspname NOT LIKE 'pg_%'
    AND relkind = 'i'
    """

    def indexes_as_set(conn) -> set:
        """Return db tuples as set."""
        with conn.cursor() as cur:
            cur.execute(q)
            return {f"{item[0]}.{item[1]}" for item in cur}

    src_diff = indexes_as_set(src_conn)
    dst_diff = indexes_as_set(dst_conn)
    return src_diff.difference(dst_diff)


def get_idx_create_stmts(conn, names) -> list[str]:
    """Get create index statements."""
    q = """
    SELECT indexdef
    FROM pg_indexes
    WHERE indexname = %s
    AND schemaname = %s
    """

    statements = []
    for name in names:
        schema, index = name.split(".")
        with conn.cursor() as cur:
            cur.execute(q, (index, schema))
            stmt = cur.fetchone()
            statements.append((stmt[0], schema, index))

    return statements


def create_index(stmt, schema, name, cred) -> tuple[str]:
    """Create index on the djangostack database using a subprocess."""
    logging.info("creating index %s.%s", schema, name)

    creds = get_hup(cred)
    cmd = f"psql {creds} -c '{stmt}' djangostack"
    logging.info("cmd is %s", cmd)

    start = datetime.now()
    exe = Popen(cmd, stdout=PIPE, stderr=PIPE, shell=True)
    exe.communicate()
    end = datetime.now()
    logging.info("created index %s.%s in %s", schema, name, end - start)
    return (schema, name)


def recreate_indexes() -> None:
    """Recreate indexes on dst database."""
    src_conn = psycopg2.connect(**creds["src"], dbname="djangostack")
    dst_conn = psycopg2.connect(**creds["dst"], dbname="djangostack")

    indexes = find_missing_indexes(src_conn, dst_conn)
    statements = get_idx_create_stmts(src_conn, list(indexes))

    with ThreadPoolExecutor(max_workers=48) as executor:
        t2t = {executor.submit(create_index, stmt[0], stmt[1], stmt[2], creds["dst"]): stmt for stmt in statements}
        for future in as_completed(t2t):
            row = t2t[future]
            try:
                stdout, stderr = future.result()
            except Exception:
                logging.exception("%s.%s generated error", row[0], row[1])
            else:
                logging.info("stdout from index %s.%s is %s", row[0], row[1], stdout)
                logging.info("stderr from index %s.%s is %s", row[0], row[1], stderr)
    src_conn.close()
    dst_conn.close()


def find_missing_fks(src_conn, dst_conn) -> set[str]:
    """Find missing foreign keys."""
    q = """
    SELECT conname, nspname
    FROM pg_constraint
    JOIN pg_namespace ON (pg_namespace.oid = pg_constraint.connamespace)
    WHERE nspname != 'information_schema'
    AND nspname NOT LIKE 'pg_%'
    AND contype = 'f'
    """

    def constraints_as_set(conn) -> set[str]:
        """Return db tuples as set."""
        with conn.cursor() as cur:
            cur.execute(q)
            return {f"{item[1]}.{item[0]}" for item in cur}

    src_diff = constraints_as_set(src_conn)
    dst_diff = constraints_as_set(dst_conn)

    return src_diff.difference(dst_diff)


# ruff: noqa: ANN201,ARG001,PLR0914
def get_fk_create_stmt(conn, schema, name):
    """Get foreign key create statements."""
    # select referenced table, match type, on delete, on update
    q = """
    SELECT pg_constraint.oid, -- oid of constraint for faster finding
        ct.relname, -- referencing (local) table name
        rt.relname, -- referenced table name
        confmatchtype, -- Foreign key match type: f = full, p = partial, s = simple
        confupdtype, -- Foreign key update action code: a = no action, r = restrict, c = cascade, n = set null, d = set default
        confdeltype, -- Foreign key deletion action code: a = no action, r = restrict, c = cascade, n = set null, d = set default
        condeferred, -- FK "deferred"
        condeferrable -- FK "initially deferrable"
    FROM pg_constraint
    JOIN pg_namespace ON (pg_namespace.oid = pg_constraint.connamespace)
    JOIN pg_class rt ON (pg_constraint.confrelid = rt.oid)
    JOIN pg_class ct ON (pg_constraint.conrelid = ct.oid)
    WHERE nspname != 'information_schema'
    AND nspname NOT LIKE 'pg_%'
    AND contype = 'f'
    """

    with conn.cursor() as cur:
        cur.execute(q)
        (
            oid,
            ct_name,
            rt_name,
            confmatchtype,
            confupdtype,
            confdeltype,
            condeferred,
            condeferrable,
        ) = cur.fetchone()

    # Constrained columns
    q = """
    SELECT pg_attribute.attname
    FROM pg_attribute
    JOIN pg_constraint ON (pg_attribute.attnum = ANY(pg_constraint.conkey) AND pg_constraint.conrelid = pg_attribute.attrelid)
    WHERE pg_constraint.oid = %s
    """

    with conn.cursor() as cur:
        cur.execute(q, (oid,))
        res = cur.fetchall()
        local_columns = [row[0] for row in res]

    # Referenced columns
    q = """
    SELECT pg_attribute.attname
    FROM pg_attribute
    JOIN pg_constraint ON (pg_attribute.attnum = ANY(pg_constraint.confkey) AND pg_constraint.confrelid = pg_attribute.attrelid)
    WHERE pg_constraint.oid = %s
    """

    with conn.cursor() as cur:
        cur.execute(q, (oid,))
        res = cur.fetchall()
        referenced_columns = [row[0] for row in res]

    lc = '", "'.join(local_columns)
    rc = '", "'.join(referenced_columns)
    stmt = f'ALTER TABLE "{ct_name}" ADD CONSTRAINT "{name}" FOREIGN KEY ("{lc}") '
    stmt = stmt + f'REFERENCES "{rt_name}" ("{rc}") '

    if confmatchtype is not None:
        stmt = stmt + "MATCH " + {"f": "FULL ", "p": "PARTIAL ", "s": "SIMPLE "}[confmatchtype]

    actions = {"a": "NO ACTION", "r": "RESTRICT", "c": "CASCADE", "n": "SET NULL", "d": "SET DEFAULT"}

    if confdeltype is not None:
        stmt = f"{stmt} ON DELETE {actions[confdeltype]} "

    if confupdtype is not None:
        stmt = f"{stmt} ON UPDATE {actions[confupdtype]} "

    if condeferred:
        stmt = f"{stmt} DEFERRABLE"
    if condeferrable:
        stmt = f"{stmt} INITIALLY DEFERRED"

    return stmt


def create_fk(dst_cred, con_sqname, stmt) -> tuple[str]:
    """Create foreign key."""
    schema, name = con_sqname.split(".")
    logging.info("creating foreign key %s.%s", schema, name)
    # jscpd:ignore-start
    creds = get_hup(dst_cred)
    cmd = f"psql {creds} -c '{stmt}' djangostack"
    logging.info("cmd is %s", cmd)

    start = datetime.now()
    exe = Popen(cmd, stdout=PIPE, stderr=PIPE, shell=True)
    exe.communicate()
    end = datetime.now()
    logging.info("created foreign key %s.%s in %s", schema, name, end - start)
    # jscpd:ignore-end
    return (schema, name)


def recreate_fks() -> None:
    """Recreate missing foreign keys."""
    src_conn = psycopg2.connect(**creds["src"], dbname="djangostack")
    dst_conn = psycopg2.connect(**creds["dst"], dbname="djangostack")

    names = find_missing_fks(src_conn, dst_conn)

    stmts = [(name, get_fk_create_stmt(src_conn, name.split(".")[0], name.split(".")[1])) for name in names]

    with ThreadPoolExecutor(max_workers=64) as executor:
        t2t = {executor.submit(create_fk, creds["dst"], name[0], name[1]): name for name in stmts}
        # jscpd:ignore-start
        for future in as_completed(t2t):
            row = t2t[future]
            try:
                stdout, stderr = future.result()
            except Exception:
                logging.exception("%s.%s generated error", row[0], row[1])
            else:
                logging.info("stdout from fk %s.%s is %s", row[0], row[1], stdout)
                logging.info("stderr from fk %s.%s is %s", row[0], row[1], stderr)
            # jscpd:ignore-end
    src_conn.close()
    dst_conn.close()


def find_missing_pks(src_conn, dst_conn) -> set[str]:
    """Find missing primary keys between src and dst database."""
    q = """
    SELECT nspname, i.relname AS index_name, t.relname AS tbl_name
    FROM pg_index, pg_class i, pg_class t, pg_namespace
    WHERE nspname != 'information_schema'
    AND nspname NOT LIKE 'pg_%'
    AND i.oid = pg_index.indexrelid
    AND t.oid = pg_index.indrelid
    AND pg_namespace.oid = i.relnamespace
    AND indisprimary
    """

    def indexes_as_set(conn) -> set[str]:
        """Return db tuples as set."""
        with conn.cursor() as cur:
            cur.execute(q)
            return {f"{item[0]}.{item[1]}" for item in cur}

    src_diff = indexes_as_set(src_conn)
    dst_diff = indexes_as_set(dst_conn)
    return src_diff.difference(dst_diff)


def hackily_fix_pks(src_conn, dst_conn) -> None:
    """Recreate primary keys in dst database."""
    q = """
    SELECT nspname, i.relname AS index_name, t.relname AS tbl_name
    FROM pg_index, pg_class i, pg_class t, pg_namespace
    WHERE nspname != 'information_schema'
    AND nspname NOT LIKE 'pg_%'
    AND i.oid = pg_index.indexrelid
    AND t.oid = pg_index.indrelid
    AND pg_namespace.oid = i.relnamespace
    AND indisprimary
    """

    with src_conn, src_conn.cursor() as cur:
        cur.execute(q)
        pks = {row[1]: row[2] for row in cur}

    queries = [f'ALTER TABLE "{pks[row]}" ADD CONSTRAINT "{row}" PRIMARY KEY USING INDEX "{row}"' for row in pks]
    for query in queries:
        try:
            with dst_conn, dst_conn.cursor() as cur:
                logging.info("executing %s", query)
                cur.execute(query)
        except psycopg2.errors.ObjectNotInPrerequisiteState:
            logging.exception("oops")


def find_missing_cks(src_conn, dst_conn) -> set[str]:
    """Find missing check constraints."""
    q = """
    SELECT conname, relname AS table_name, nspname AS schema_name, pg_get_constraintdef(pg_constraint.oid)
    FROM pg_constraint
    JOIN pg_class ON (pg_constraint.conrelid = pg_class.oid)
    JOIN pg_namespace ON (pg_constraint.connamespace = pg_namespace.oid)
    WHERE nspname not like 'pg_%'
        AND nspname != 'information_schema'
        and contype = 'c'
    """
    # ruff: noqa: PYI024
    constraint = namedtuple("Constraint", ["table", "name", "definition"])

    def constraints_as_set(conn) -> set[str]:
        """Return db tuple as set."""
        with conn.cursor() as cur:
            cur.execute(q)
            return {constraint(item[1], item[0], item[3]) for item in cur}

    src_diff = constraints_as_set(src_conn)
    dst_diff = constraints_as_set(dst_conn)

    return src_diff.difference(dst_diff)


def create_cks(src_conn, dst_conn) -> None:
    """Create missing check constraints."""
    missing_constraints = find_missing_cks(src_conn, dst_conn)
    queries = [
        f"ALTER TABLE {constraint.table} ADD CONSTRAINT {constraint.name} {constraint.definition}"
        for constraint in missing_constraints
    ]
    for query in queries:
        try:
            with dst_conn, dst_conn.cursor() as cur:
                logging.info("executing %s", query)
                cur.execute(query)
        except Exception:
            logging.exception("error creating check constraint")


def find_missing_unique_constraints(src_conn, dst_conn) -> set[tuple]:
    """Find missing unique constraints."""
    q = """
    select
        pg_constraint.oid,
        nspname,
        relname,
        conname,
        condeferrable,
        condeferred,
        pg_get_constraintdef(pg_constraint.oid)
    from pg_constraint
    left join pg_namespace on (pg_namespace.oid = pg_constraint.connamespace)
    left join pg_class on (pg_class.oid = pg_constraint.conrelid)
    WHERE nspname != 'information_schema'
    AND nspname NOT LIKE 'pg_%'
    AND contype = 'u'
    """
    constraint = namedtuple("Constraint", ["nspname", "relname", "conname", "deferrable", "deferred", "constraintdef"])

    def constraints_as_set(conn) -> set[str]:
        """Return db tuple as set."""
        with conn.cursor() as cur:
            cur.execute(q)
            return {constraint(item[1], item[2], item[3], item[4], item[5], item[6]) for item in cur}

    src_diff = constraints_as_set(src_conn)
    dst_diff = constraints_as_set(dst_conn)

    return src_diff.difference(dst_diff)


def execute_queries(db_conn, queries: list[str], error_msg: str) -> None:
    """Execute a list of queries against a db."""
    for query in queries:
        try:
            with db_conn, db_conn.cursor() as cur:
                logging.info("executing %s", query)
                cur.execute(query)
        except Exception:
            logging.exception(error_msg)


def create_unique_constraints(src_conn, dst_conn) -> None:
    """Alter table to add missing unique constraints."""
    missing_constraints = find_missing_unique_constraints(src_conn, dst_conn)

    drop_index_stmts = [f"DROP INDEX {constraint.conname}" for constraint in missing_constraints]
    execute_queries(dst_conn, drop_index_stmts, "error dropping unique index")

    add_constraint_stmts = [
        f"ALTER TABLE {constraint.relname} ADD CONSTRAINT {constraint.conname} {constraint.constraintdef}"
        for constraint in missing_constraints
    ]
    execute_queries(dst_conn, add_constraint_stmts, "error altering table to add unique constraint")


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)

    # ruff: noqa: ERA001
    # 1. Migrate the users. At this point, the djangostack database may not exist.
    # conn = psycopg2.connect(**creds["dst"], dbname="postgres")
    # create_users(conn)
    # conn.close()

    # 2. Migrate the schema
    # pgdump_schema()

    # 3. Drop any constraints to speed up the ETL.
    # conn = psycopg2.connect(**creds["dst"], dbname="djangostack")
    # drop_constraints(conn)
    # conn.close()

    # 4. Profit
    # copy_data()

    # 5. Recreate the things
    # src_conn = psycopg2.connect(**creds["src"], dbname="djangostack")
    # dst_conn = psycopg2.connect(**creds["dst"], dbname="djangostack")
    # ruff: noqa: FIX004
    # hackily_fix_pks(src_conn, dst_conn)

    # 6. Create check constraints
    # src_conn = psycopg2.connect(**creds["src"], dbname="djangostack")
    # dst_conn = psycopg2.connect(**creds["dst"], dbname="djangostack")
    # create_cks(src_conn, dst_conn)

    # 7. Create missing unique constraints
    src_conn = psycopg2.connect(**creds["src"], dbname="djangostack")
    dst_conn = psycopg2.connect(**creds["dst"], dbname="djangostack")
    create_unique_constraints(src_conn, dst_conn)
