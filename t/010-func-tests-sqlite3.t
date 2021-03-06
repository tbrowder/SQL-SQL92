use v6;
use Test;

use SQL::SQL92 :ALL;
use DBIish;

#plan ?;

# make sure sqlite3 program and driver are available

# create an sqlite db with a couple of tables
my $sqlf = './t/t.sql';
my $dbf = './t/t.sqlite3';
unlink $dbf, $sqlf;

my $sql = qq:to/HERE/;
CREATE TABLE one (
    idx INTEGER PRIMARY KEY,
    name TEXT NOT NULL
);
CREATE TABLE two (
    idx INTEGER PRIMARY KEY,
    name TEXT NOT NULL
);
INSERT INTO one VALUES(1, 'tom');
INSERT INTO two VALUES(1, 'tom');
HERE
spurt $sqlf, $sql;

my $exe = 'sqlite3';
my $cmd = "$exe $dbf < $sqlf";
shell $cmd;

my $debug = 1;
my $dbh;
my $ret;
lives-ok { $dbh = DBIish.connect: "SQLite", :database($dbf) }, 'open sqlite3 db';

#sub drop-table($dbh, $table) is export(:drop-table) {
lives-ok { $ret = drop-table $dbh, 'one' }, 'drop-table';
say "DEBUG: \$ret = '$ret'" if $debug;
lives-ok { $ret = drop-table $dbh, 'one' }, 'drop-table again';
say "DEBUG: \$ret = '$ret'" if $debug;

#sub key-exists($dbh, $table, $keycol, $keyval) is export(:key-exists) {
lives-ok { $ret = key-exists $dbh, 'one', 'idx', 1 }, 'key-exists in non-existent table';
say "DEBUG: \$ret = '$ret'" if $debug;
lives-ok { $ret = key-exists $dbh, 'two', 'idx', 1 }, 'key-exists';
say "DEBUG: \$ret = '$ret'" if $debug;

#sub get-col-value($dbh, $table, $colname, $keycol, $keyval) is export(:get-col-value) {
lives-ok { $ret = get-col-value $dbh, 'two', 'name', 'idx', 1 }, 'get-col-value';
is $ret, 'tom', 'check correct column value';
say "DEBUG: \$ret = '$ret'" if $debug;


# normally delete tmp files
END {
    if 1 {
        unlink $dbf, $sqlf;
    }
}

done-testing;
