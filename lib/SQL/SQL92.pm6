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
    my $sth = $dbh.prepare(qq:to/STATEMENT/);
    DROP TABLE IF EXISTS $table
    STATEMENT

    $sth.execute;
} # drop-table

sub key-exists($dbh, $table, $keycol, $keyval --> Bool) is export(:key-exists) {
    my $sth = $dbh.prepare(qq:to/STATEMENT/);
    SELECT * FROM $table WHERE $keycol = "$keyval"
    STATEMENT

    try { 
        $sth.execute; 
    }
    CATCH {
        return False; 
    }

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

=begin comment
# this is db-specific
sub table-exists($dbh, $table) is export(:table-exists) {
    my $sth = $dbh.prepare(qq:to/STATEMENT/);
    SELECT *
    FROM $table
    IF EXISTS TABLE $table
    STATEMENT

    $sth.execute;
    my @vals = $sth.row;
    my $table-exists = @vals ?? shift @vals !! '';

    # always clean up after an execute
    $sth.finish;

    return $table-exists;
} # table-exists
=end comment

sub dump-table($dbh, $table) is export(:dump-table) {
    my $sth = $dbh.prepare(qq:to/STATEMENT/);
    SELECT *
    FROM $table
    STATEMENT

    $sth.execute;

    my @rows = $sth.allrows;

    # always clean up after an execute
    $sth.finish;

    return @rows;
}
