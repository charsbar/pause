use v5.10;
use strict;
use warnings;
use DBI;
use Path::Tiny;
use PAUSE;
use PAUSE::Crypt;
use SQL::Maker;

unless ($ENV{CREATE_TEST_USERS}) {
  warn "CREATE_TEST_USERS ENV is not true, not creating test users!\n";
  exit;
}

my @users = qw(TESTUSER TESTADMIN TESTCNSRD);

my $maker = SQL::Maker->new(driver => 'mysql');

my $dbh = DBI->connect($ENV{AUTHEN_DATA_SOURCE_NAME}, $ENV{MYSQL_USER}, $ENV{MYSQL_ROOT_PASSWORD}, {
	AutoCommit => 1,
	PrintError => 0,
	RaiseError => 1,
	ShowErrorStatement => 1,
});
{
    $dbh->do('TRUNCATE usertable');
    for my $user (@users) {
        my ($sql, @bind) = $maker->insert('usertable', {
            user => $user,
            password => PAUSE::Crypt::hash_password('test'),
            secretemail => lc($user) . '@localhost',
		});
        $dbh->do($sql, undef, @bind);
	    my $user_dir = join "/", $PAUSE::Config->{MLROOT}, PAUSE::user2dir($user);
	    path($user_dir)->mkpath;
    }
    $dbh->do('TRUNCATE grouptable');
    my ($sql, @bind) = $maker->insert('grouptable', {user => 'TESTADMIN', ugroup => 'admin'});
    $dbh->do($sql, undef, @bind);
}

{
    $dbh->do('TRUNCATE users');
    for my $user (@users) {
        my ($sql, @bind) = $maker->insert('users', {
            userid => $user,
            fullname => "$user Name",
            email => ($user eq "TESTCNSRD" ? "CENSORED" : (lc($user) . '@localhost')),
            cpan_mail_alias => 'secr',
            isa_list => '',
        });
        $dbh->do($sql, undef, @bind);
    }
}
