unit module DBD::SQL92;

use DBIish;

# This module has general functions which should work with any
# DBIish-capable RDBMS.
#
# The author plans, or has in place, modules specifically for SQLite
# and PostreSQL. See:
#
#   DBD::SQLite
#   DBD::PostgreSQL
#
# The following functions, among others, are found in modules for
# specific RDBMSs:
#
#   open-db

sub drop-table($dbh, $table) is export(:drop-table) {
    my $sth = $dbh.do(qq:to/STATEMENT/);
        DROP TABLE IF EXISTS $table
        STATEMENT
} # drop-table

sub key-exists($dbh, $table, $keycol, $keyval) is export(:key-exists) {
    my $sth = $dbh.prepare(qq:to/STATEMENT/);
        SELECT *
        FROM $table
        WHERE $keycol = "$keyval"
        STATEMENT

    $sth.execute;
    my @vals = $sth.row;
    my $key-exists = @vals ?? True !! False;

    # always clean up after an execute
    $sth.finish;

    return $key-exists;
} # key-exists

sub get-col-value($dbh, $table, $colname, $keycol, $keyval) is export(:get-col-value) {
    my $sth = $dbh.prepare(qq:to/STATEMENT/);
        SELECT $colname
        FROM $table
        WHERE $keycol = "$keyval"
        STATEMENT

    $sth.execute;
    my @vals = $sth.row;
    my $val = @vals ?? shift @vals !! '';

    # always clean up after an execute
    $sth.finish;

    return $val;
} # get-col-value
