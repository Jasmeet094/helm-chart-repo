#!/usr/bin/env python

"""Validate postgres data was correctly migrated.

Validates Tables, Views, Materialized Views, Sequences, Functions, Procedures, Triggers, Indexes, Foreign Keys
"""

import logging
from collections import namedtuple
from pathlib import Path

# ruff: noqa: UP035
from typing import Callable

import psycopg2
import yaml

# Set to True for more logging
DEBUG = False

# ruff: noqa: PYI024
Table = namedtuple(
    "Table",
    ["oid", "schema", "table", "relpersistence", "rolname", "relrowsecurity", "relacl"],
)
MatView = namedtuple("MatView", ["oid", "schema", "table", "rolname", "relacl", "definition"])
Function = namedtuple(
    "Function",
    [
        "oid",
        "proname",
        "rolname",
        "nspname",
        "prokind",
        "provariadic",
        "prosecdef",
        "proleakproof",
        "proisstrict",
        "proretset",
        "provolatile",
        "proparallel",
        "prosrc",
        "proconfig",
        "proacl",
    ],
)
User = namedtuple("User", ["oid", "rolname", "rolsuper", "rolcanlogin", "rolpassword"])
Trigger = namedtuple(
    "Trigger",
    [
        "oid",
        "tgrelid",
        "tgname",
        "tgfoid",
        "tgtype",
        "tgenabled",
        "tgconstrrelid",
        "tgconstrindid",
        "tgconstraint",
        "tgdeferrable",
        "tginitdeferred",
        "tgattr",
        "tgargs",
        "tgqual",
        "tgoldtable",
        "tgnewtable",
    ],
)
Sequence = namedtuple(
    "Sequence",
    [
        "oid",
        "schema",
        "relname",
        "rolname",
        "relacl",
        "seqstart",
        "seqincrement",
        "seqmax",
        "seqmin",
        "seqcache",
        "seqcycle",
        "typname",
        "last_value",
    ],
)
ForeignKey = namedtuple(
    "ForeignKey",
    [
        "oid",
        "conname",
        "nspname",
        "relname",
        "frelname",
        "confmatchtype",
        "confupdtype",
        "confdeltype",
        "condeferred",
        "condeferrable",
        "convalidated",
    ],
)
CheckConstraint = namedtuple(
    "CheckConstraint",
    [
        "oid",
        "nspname",
        "relname",
        "conname",
        "condeferrable",
        "condeferred",
        "convalidated",
    ],
)
UniqueConstraint = namedtuple(
    "UniqueConstraint",
    [
        "oid",
        "nspname",
        "relname",
        "conname",
        "condeferrable",
        "condeferred",
        "conindid",
        "constraintdef"
    ],
)
PrimaryKeyConstraint = namedtuple(
    "PrimaryKey",
    [
        "oid",
        "nspname",
        "relname",
        "conname",
        "condeferrable",
        "condeferred",
        "conindid",
    ],
)
Index = namedtuple(
    "Index",
    [
        "indexrelid",
        "indrelid",
        "indnatts",
        "indnkeyatts",
        "indisunique",
        "indisprimary",
        "indisexclusion",
        "indimmediate",
        "indisclustered",
        "indisvalid",
        "indcheckxmin",
        "indisready",
        "indisreplident",
        "indkey",
        "indoption",
        "indexprs",
        "indpred",
        "relam",
        "relname",
        "nspname",
    ],
)

# ruff: noqa: ANN001
def run_query(conn, query: str, fn: Callable) -> set:
    """Run <query> against <conn>, and return a set of fn(row)."""
    with conn.cursor() as cur:
        cur.execute(query)
        return {fn(row) for row in cur}


def list_tables(conn) -> dict[str, Table]:
    """Obtain a listing of all tables in the Postgres database "conn".

    This function queries Postgres system catalogs to obtain a list of tables,
    and turns it into a dictionary of "<schema>.<name>" => Table.
    """
    query = """
        select
            pg_class.oid,
            nspname,
            relname,
            relpersistence,
            rolname,
            relrowsecurity,
            relacl
        from pg_class
            left join pg_namespace on (pg_class.relnamespace = pg_namespace.oid)
            left join pg_roles on (pg_class.relowner = pg_roles.oid)
        where nspname not like 'pg_%'
            and nspname != 'information_schema'
            and relkind = 'r'
    """
    # ruff: noqa: E731
    fn = lambda table: Table(table[0], table[1], table[2], table[3], table[4], table[5], table[6])
    tables = run_query(conn, query, fn)
    return {f"{table.schema}.{table.table}": table for table in tables}


def list_matviews(conn) -> dict[str, MatView]:
    """Obtain a listing of all materialized views in the Postgres database "conn".

    This function queries Postgres system catalogs to obtain a list of views,
    and turns it into a dictionary of "<schema>.<name>" => MatView.
    """
    query = """
        select
            pg_class.oid,
            nspname,
            relname,
            rolname,
            relacl,
            definition
        from pg_class
            left join pg_namespace on (pg_class.relnamespace = pg_namespace.oid)
            inner join pg_matviews on (
                pg_matviews.matviewname = pg_class.relname
            and pg_namespace.nspname = pg_matviews.schemaname
            )
            left join pg_roles on (pg_class.relowner = pg_roles.oid)
        where nspname not like 'pg_%'
            and nspname != 'information_schema'
    """
    fn = lambda table: MatView(table[0], table[1], table[2], table[3], table[4], table[5])
    tables = run_query(conn, query, fn)
    return {f"{table.schema}.{table.table}": table for table in tables}


def list_sequences(conn) -> dict[str, Sequence]:
    """Obtain a listing of all sequences in the Postgres database "conn".

    This function queries Postgres system catalogs to obtain a list of sequences,
    and turns it into a dictionary of "<schema>.<name>" => Sequence.

    The query in this function has a unique property where the 12th column is not selected. I have
    no idea why, and it doesn't seem to matter what the 12th column is, so I've set it to typtype,
    which is not a column we actually use. Notice how, when assigning the Sequence, it sets typname
    to the typtype column index in the query, which assigns typname to the field in the namedtuple.
    """
    query = """
        select
            pg_class.oid,
            nspname,
            relname,
            rolname,
            relacl,
            seqstart, seqincrement, seqmax, seqmin, seqcache, seqcycle
            typtype, typname
        from pg_class
            inner join pg_sequence on (pg_sequence.seqrelid = pg_class.oid)
            left join pg_namespace on (pg_class.relnamespace = pg_namespace.oid)
            left join pg_type on (pg_sequence.seqtypid = pg_type.oid)
            left join pg_roles on (pg_class.relowner = pg_roles.oid)
        where nspname not like 'pg_%'
            and nspname != 'information_schema'
    """

    def fn(row) -> Sequence:
        cur = conn.cursor()
        # ruff: noqa: S608
        cur.execute(f'SELECT last_value FROM "{row[2]}"')
        res = cur.fetchone()
        return Sequence(
            row[0],
            row[1],
            row[2],
            row[3],
            row[4],
            row[5],
            row[6],
            row[7],
            row[8],
            row[9],
            row[10],
            row[11],
            res[0],
        )

    sequences = run_query(conn, query, fn)
    return {f"{sequence.schema}.{sequence.relname}": sequence for sequence in sequences}


def missing_items(src: dict[str, any], dst: dict[str, any]) -> list[str]:
    """Find items missing in dst."""
    items = []
    for item in src:
        try:
            dst[item]
        except KeyError:
            items.append(item)
    return items


def list_functions(conn) -> dict[str, Function]:
    """List postgres functions."""
    query = """
        select
            pg_proc.oid,
            proname,
            rolname,
            nspname,
            prokind,
            provariadic,
            prosecdef,
            proleakproof,
            proisstrict,
            proretset,
            provolatile,
            proparallel,
            prosrc,
            proconfig,
            proacl
        from pg_proc
            left join pg_roles on (pg_proc.proowner::regclass::text = pg_roles.rolname)
            left join pg_namespace on (pg_proc.pronamespace = pg_namespace.oid)
            WHERE nspname != 'information_schema'
            AND nspname NOT LIKE 'pg_%'
    """
    fn = lambda function: Function(
        function[0],
        function[1],
        function[2],
        function[3],
        function[4],
        function[5],
        function[6],
        function[7],
        function[8],
        function[9],
        function[10],
        function[11],
        function[12],
        function[13],
        function[14],
    )
    functions = run_query(conn, query, fn)
    return {f"{function.nspname}.{function.proname}": function for function in functions}


def list_users(conn) -> dict[str, User]:
    """List postgres users."""
    query = """
        select oid, rolname, rolsuper, rolcanlogin, rolpassword
        from pg_roles
        where rolname in ('bitnami', 'bucardo')
    """
    fn = lambda user: User(user[0], user[1], user[2], user[3], user[4])
    users = run_query(conn, query, fn)
    return {user.rolname: user for user in users}


def list_fks(conn) -> dict[str, ForeignKey]:
    """List postgres foreign keys."""
    query = """
    SELECT pg_constraint.oid, -- oid of constraint for faster finding
        conname, -- constraint name
        nspname, -- schemaname
        ct.relname, -- referencing (local) table name
        rt.relname, -- referenced table name
        confmatchtype, -- Foreign key match type: f = full, p = partial, s = simple
        confupdtype, -- fk update action code: a = no action, r = restrict, c = cascade, n = set null, d = set default
        confdeltype, -- fk deletion action code: a = no action, r = restrict, c = cascade, n = set null, d = set default
        condeferred, -- FK "deferred"
        condeferrable, -- FK "initially deferrable"
        convalidated -- Has the constraint been validated?
    FROM pg_constraint
    JOIN pg_namespace ON (pg_namespace.oid = pg_constraint.connamespace)
    JOIN pg_class rt ON (pg_constraint.confrelid = rt.oid)
    JOIN pg_class ct ON (pg_constraint.conrelid = ct.oid)
    WHERE nspname != 'information_schema'
    AND nspname NOT LIKE 'pg_%'
    AND contype = 'f'
    """
    fn = lambda fk: ForeignKey(fk[0], fk[1], fk[2], fk[3], fk[4], fk[5], fk[6], fk[7], fk[8], fk[9], fk[10])
    fks = run_query(conn, query, fn)
    return {f"{fk.nspname}.{fk.conname}": fk for fk in fks}


def list_triggers(conn) -> dict[str, Trigger]:
    """List postgres triggers."""
    query = """
        select
            oid,
            tgrelid::regclass,
            tgname,
            tgfoid::regclass,
            tgtype,
            tgenabled,
            tgconstrrelid,
            tgconstrindid,
            tgconstraint::regclass,
            tgdeferrable,
            tginitdeferred,
            tgattr,
            tgargs,
            tgqual,
            tgoldtable,
            tgnewtable
        from pg_trigger
        WHERE tgname NOT LIKE 'RI_ConstraintTrigger%'
    """
    fn = lambda trigger: Trigger(
        trigger[0],
        trigger[1],
        trigger[2],
        trigger[3],
        trigger[4],
        trigger[5],
        trigger[6],
        trigger[7],
        trigger[8],
        trigger[9],
        trigger[10],
        trigger[11],
        trigger[12],
        trigger[13],
        trigger[14],
        trigger[15],
    )
    triggers = run_query(conn, query, fn)
    return {trigger.tgname: trigger for trigger in triggers}


def list_indexes(conn) -> dict[str, Index]:
    """List postgres indexes."""
    query = """
        select
            pg_index.indexrelid,
            indrelid::regclass,
            indnatts,
            indnkeyatts,
            indisunique,
            indisprimary,
            indisexclusion,
            indimmediate,
            indisclustered,
            indisvalid,
            indcheckxmin,
            indisready,
            indisreplident,
            indkey,
            indoption,
            indexprs,
            indpred,
            pg_class.relam::regclass,
            relname,
            nspname
        from pg_index
        left join pg_class on (pg_class.oid = pg_index.indexrelid)
        left join pg_namespace on (pg_namespace.oid = pg_class.relnamespace)
        WHERE nspname != 'information_schema'
        AND nspname NOT LIKE 'pg_%'
    """
    fn = lambda index: Index(
        index[0],
        index[1],
        index[2],
        index[3],
        index[4],
        index[5],
        index[6],
        index[7],
        index[8],
        index[9],
        index[10],
        index[11],
        index[12],
        index[13],
        index[14],
        index[15],
        index[16],
        index[17],
        index[18],
        index[19],
    )
    indexes = run_query(conn, query, fn)
    return {f"{index.nspname}.{index.relname}": index for index in indexes}


def list_check_constraints(conn) -> dict[str, CheckConstraint]:
    """List postgres check constrains."""
    query = """
        SELECT
            pg_constraint.oid,
            nspname,
            relname,
            conname,
            condeferrable,
            condeferred,
            convalidated
        FROM pg_constraint
        LEFT join pg_namespace on (pg_namespace.oid = pg_constraint.connamespace)
        LEFT join pg_class on (pg_class.oid = pg_constraint.conrelid)
        WHERE nspname != 'information_schema'
        AND nspname NOT LIKE 'pg_%'
        AND contype = 'c'
    """
    fn = lambda constraint: CheckConstraint(
        constraint[0],
        constraint[1],
        constraint[2],
        constraint[3],
        constraint[4],
        constraint[5],
        constraint[6],
    )
    constraints = run_query(conn, query, fn)
    return {f"{constraint.nspname}.{constraint.conname}": constraint for constraint in constraints}


def list_unique_constraints(conn) -> dict[str, UniqueConstraint]:
    """List postgres unique constraints."""
    query = """
        select
            pg_constraint.oid,
            nspname,
            relname,
            conname,
            condeferrable,
            condeferred,
            conindid::regclass,
            pg_get_constraintdef(pg_constraint.oid)
        from pg_constraint
        left join pg_namespace on (pg_namespace.oid = pg_constraint.connamespace)
        left join pg_class on (pg_class.oid = pg_constraint.conrelid)
        WHERE nspname != 'information_schema'
        AND nspname NOT LIKE 'pg_%'
        AND contype = 'u'
    """
    # ruff: noqa: ERA001
    # jscpd:ignore-start
    fn = lambda constraint: UniqueConstraint(
        constraint[0],
        constraint[1],
        constraint[2],
        constraint[3],
        constraint[4],
        constraint[5],
        constraint[6],
        constraint[7],
    )
    constraints = run_query(conn, query, fn)
    return {f"{constraint.nspname}.{constraint.conname}": constraint for constraint in constraints}
    # jscpd:ignore-end

def list_primary_key_constraints(conn) -> dict[str, PrimaryKeyConstraint]:
    """List postgres primary keys constraints."""
    query = """
        select
            pg_constraint.oid,
            nspname,
            relname,
            conname,
            condeferrable,
            condeferred,
            conindid::regclass
        from pg_constraint
        left join pg_namespace on (pg_namespace.oid = pg_constraint.connamespace)
        left join pg_class on (pg_class.oid = pg_constraint.conrelid)
        WHERE nspname != 'information_schema'
        AND nspname NOT LIKE 'pg_%'
        AND contype = 'p'
    """
    # jscpd:ignore-start
    fn = lambda constraint: PrimaryKeyConstraint(
        constraint[0],
        constraint[1],
        constraint[2],
        constraint[3],
        constraint[4],
        constraint[5],
        constraint[6],
    )
    constraints = run_query(conn, query, fn)
    return {f"{constraint.nspname}.{constraint.conname}": constraint for constraint in constraints}
    # jscpd:ignore-end


def get_connections(config: dict) -> dict:
    """Get postgres connection from config."""
    return {name: psycopg2.connect(**config.get(name)) for name in config}


# ruff: noqa: PLR0912, C901
def process_tables(pg) -> None:
    """Find missing tables and tables with different properties."""
    # Load table data from ec2 and rds
    logging.info("loading ec2 tables")
    src = list_tables(pg["ec2"])
    logging.info("loading rds tables")
    dst = list_tables(pg["rds"])

    # Find missing tables
    logging.info("finding missing tables")
    missing = missing_items(src, dst)
    if len(missing) == 0:
        logging.info("found no missing tables")
    else:
        logging.error("found %s missing tables", len(missing))
        for item in missing:
            logging.error("missing %s", item)

    # Find tables with different properties
    relpersistence = []
    rolname = []
    relrowsecurity = []
    relacl = []
    for table in dst:
        if "awsdms" in table:  # Skip AWS DMS tables
            logging.warning("found aws dms table %s", table)
            continue
        try:  # What if the table doesn't exist in the source?
            if src[table].relpersistence != dst[table].relpersistence:
                relpersistence.append(table)
        except KeyError:
            logging.warning("missing table %s in src", table)
            continue
        if src[table].rolname != dst[table].rolname:
            rolname.append(table)
        if src[table].relrowsecurity != dst[table].relrowsecurity:
            relrowsecurity.append(table)
        if src[table].relacl != dst[table].relacl:
            relacl.append(table)

    if len(relpersistence) != 0:
        logging.error("found %s tables with different persistence", len(relpersistence))
    if len(rolname) != 0:
        logging.error("found %s tables with different ownership", len(rolname))
    if len(relrowsecurity) != 0:
        logging.error("found %s tables with different row security", len(relrowsecurity))
    if len(relacl) != 0:
        logging.error("found %s tables with different permissions", len(relacl))


def process_matviews(pg: dict) -> None:
    """Find missing matviews and matviews with different properties."""
    # Load matview data from ec2 and rds
    logging.info("loading ec2 matview")
    src = list_matviews(pg["ec2"])
    logging.info("loading rds matviews")
    dst = list_matviews(pg["rds"])

    # Find missing matviews
    logging.info("finding missing matviews")
    missing = missing_items(src, dst)
    if len(missing) == 0:
        logging.info("found no missing matviews")
    else:
        logging.error("found %s missing matviews", len(missing))
        for item in missing:
            logging.error("missing %s", item)

    # Find matviews with different props
    diffs = compare_namedtuples(src, dst)
    log_differences("matviews", diffs)


def process_functions(pg: dict) -> None:
    """Find missing functions and functions with different properties."""
    # Load function data from ec2 and rds
    logging.info("loading ec2 functions")
    src = list_functions(pg["ec2"])
    logging.info("loading rds functions")
    dst = list_functions(pg["rds"])

    # Find missing functions
    logging.info("finding missing functions")
    missing = missing_items(src, dst)
    if len(missing) == 0:
        logging.info("found no missing functions")
    else:
        logging.error("found %s missing functions", len(missing))
        for item in missing:
            logging.error("missing %s", item)

    # Find functions with different props
    diffs = compare_namedtuples(src, dst)
    log_differences("functions", diffs)


def process_users(pg: dict) -> None:
    """Find missing users."""
    # Load user data from ec2 and rds
    logging.info("loading ec2 users")
    src = list_users(pg["ec2"])
    logging.info("loading rds users")
    dst = list_users(pg["rds"])

    # Find missing users
    logging.info("finding missing users")
    missing = missing_items(src, dst)
    if len(missing) == 0:
        logging.info("found no missing users")
    else:
        logging.error("found %s missing users", len(missing))
        for item in missing:
            logging.error("missing %s", item)

    # Find users with different props
    diffs = compare_namedtuples(src, dst)
    log_differences("users", diffs)


def process_triggers(pg: dict) -> None:
    """Find missing triggers and triggers with different properties."""
    # Load trigger data from ec2 and rds
    logging.info("loading ec2 triggers")
    src = list_triggers(pg["ec2"])
    logging.info("loading rds triggers")
    dst = list_triggers(pg["rds"])

    # Find missing triggers
    logging.info("finding missing triggers")
    missing = missing_items(src, dst)
    if len(missing) == 0:
        logging.info("found no missing triggers")
    else:
        logging.error("found %s missing triggers", len(missing))
        for item in missing:
            logging.error("missing %s", item)

    # Find triggers with different props
    diffs = compare_namedtuples(src, dst)
    log_differences("triggers", diffs)


def process_sequences(pg: dict) -> None:
    """Find missing sequences and sequences with different permissions and/or data types."""
    # Load table data from ec2 and rds
    logging.info("loading ec2 sequences")
    src = list_sequences(pg["ec2"])
    logging.info("loading rds sequences")
    dst = list_sequences(pg["rds"])

    # Find missing tables
    logging.info("finding missing sequences")
    missing = missing_items(src, dst)
    if len(missing) == 0:
        logging.info("found no missing sequences")
    else:
        logging.error("found %s missing sequences", len(missing))
        for item in missing:
            logging.error("missing %s", item)

    # Find tables with different properties
    diffs = compare_namedtuples(src, dst)
    log_differences("sequences", diffs)

    # Log the differences in last_value
    for key in diffs:
        if src[key].last_value > dst[key].last_value:
            logging.error("sequence %s: last value in src: %s; dst: %s", key, src[key].last_value, dst[key].last_value)
        if DEBUG and src[key].last_value < dst[key].last_value:
            # ruff: noqa: E501
            logging.warning("sequence %s: last value in src: %s; dst: %s", key, src[key].last_value, dst[key].last_value)


def process_fks(pg: dict) -> None:
    """Find missing foreign keys."""
    # Load trigger data from ec2 and rds
    logging.info("loading ec2 foreign keys")
    src = list_fks(pg["ec2"])
    logging.info("loading rds foreign keys")
    dst = list_fks(pg["rds"])

    # Find missing triggers
    logging.info("finding missing foreign keys")
    missing = missing_items(src, dst)
    if len(missing) == 0:
        logging.info("found no missing foreign keys")
    else:
        logging.error("found %s missing foreign keys", len(missing))
        for item in missing:
            logging.error("missing %s", item)

    # Find triggers with different props
    diffs = compare_namedtuples(src, dst)
    log_differences("foreign keys", diffs)


def process_check_constraints(pg: dict) -> None:
    """Find missing check constraints."""
    # Load trigger data from ec2 and rds
    logging.info("loading ec2 check constraints")
    src = list_check_constraints(pg["ec2"])
    logging.info("loading rds check constraints")
    dst = list_check_constraints(pg["rds"])

    # Find missing triggers
    logging.info("finding missing check constraints")
    missing = missing_items(src, dst)
    if len(missing) == 0:
        logging.info("found no missing check constraints")
    else:
        logging.error("found %s missing check constraints", len(missing))
        for item in missing:
            logging.error("missing %s", item)

    # Find triggers with different props
    diffs = compare_namedtuples(src, dst)
    log_differences("check constraints", diffs)


def process_unique_constraints(pg: dict) -> None:
    """Find missing unique constraints."""
    # Load trigger data from ec2 and rds
    logging.info("loading ec2 unique constraints")
    src = list_unique_constraints(pg["ec2"])
    logging.info("loading rds unique constraints")
    dst = list_unique_constraints(pg["rds"])

    # Find missing triggers
    logging.info("finding missing unique constraints")
    missing = missing_items(src, dst)
    if len(missing) == 0:
        logging.info("found no missing unique constraints")
    else:
        logging.error("found %s missing unique constraints", len(missing))
        for item in missing:
            logging.error("missing %s", item)

    # Find triggers with different props
    diffs = compare_namedtuples(src, dst)
    log_differences("unique constraints", diffs)


def process_primary_key_constraints(pg: dict) -> None:
    """Find missing primary keys."""
    # Load trigger data from ec2 and rds
    logging.info("loading ec2 primary key constraints")
    src = list_primary_key_constraints(pg["ec2"])
    logging.info("loading rds primary key constraints")
    dst = list_primary_key_constraints(pg["rds"])

    # Find missing triggers
    logging.info("finding missing primary key constraints")
    missing = missing_items(src, dst)
    if len(missing) == 0:
        logging.info("found no missing primary key constraints")
    else:
        logging.error("found %s missing primary key constraints", len(missing))
        for item in missing:
            logging.error("missing %s", item)

    # Find triggers with different props
    diffs = compare_namedtuples(src, dst)
    log_differences("primary key constraints", diffs)


def process_indexes(pg: dict) -> None:
    """Find missing indexes."""
    # Load trigger data from ec2 and rds
    logging.info("loading ec2 indexes")
    src = list_indexes(pg["ec2"])
    logging.info("loading rds indexes")
    dst = list_indexes(pg["rds"])

    # Find missing triggers
    logging.info("finding missing indexes")
    missing = missing_items(src, dst)
    if len(missing) == 0:
        logging.info("found no missing indexes")
    else:
        logging.error("found %s missing indexes", len(missing))
        for item in missing:
            logging.error("missing %s", item)

    # Find triggers with different props
    diffs = compare_namedtuples(src, dst)
    log_differences("indexes", diffs)


def log_differences(typ: str, diffs: dict[str, list]) -> None:
    """Log the differences found after comparing namedtuples."""
    diffs = {key: diffs[key] for key in diffs if len(diffs[key]) > 0}

    if len(diffs) == 0:
        logging.info("found no %s with different attributes", typ)
    else:
        logging.error("found %s %s with different attributes", len(diffs), typ)
    for k, v in diffs.items():
        logging.error("differences in %s %s: %s", typ, k, v)


def compare_namedtuples(src: dict[str, namedtuple], dst: dict[str, namedtuple]) -> dict[str, list[str]]:
    """Compare tuples for different attributes and return the differences."""
    for key in src:
        attrs = list(src[key]._asdict())
        break

    diffs = {}
    for key in src:
        attr_diffs = []
        for attr in attrs:
            if attr in {"oid", "tgfoid", "tgrelid", "indexrelid", "last_value"}:
                continue
            try:
                if src[key]._asdict()[attr] != dst[key]._asdict()[attr]:
                    attr_diffs.append(attr)
            except KeyError:
                continue

        diffs[key] = attr_diffs
    return diffs


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    with Path("creds.yml").open(encoding="UTF-8") as f:
        creds = yaml.safe_load(f)
    pg = get_connections(creds)

    process_tables(pg)
    process_matviews(pg)
    process_functions(pg)
    process_users(pg)
    process_triggers(pg)
    process_fks(pg)
    process_sequences(pg)
    process_check_constraints(pg)
    process_unique_constraints(pg)
    process_primary_key_constraints(pg)
    process_indexes(pg)
