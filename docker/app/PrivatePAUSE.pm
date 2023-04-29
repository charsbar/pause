package PrivatePAUSE;
use strict;
use warnings;

my @to_copy = qw(
  AUTHEN_DATA_SOURCE_NAME
  AUTHEN_DATA_SOURCE_USER
  AUTHEN_DATA_SOURCE_PW
  MOD_DATA_SOURCE_NAME
  MOD_DATA_SOURCE_USER
  MOD_DATA_SOURCE_PW
  ADMIN
  ADMINS
  CPAN_TESTERS
  TO_CPAN_TESTERS
  REPLY_TO_CPAN_TESTERS
  GONERS_NOTIFY
  P5P
  ML_CHOWN_USER
  ML_CHOWN_GROUP
  ML_MIN_INDEX_LINES
  ML_MIN_FILES
  RUNDATA
  UPLOAD
  HAVE_PERLBAL
  SLEEP
  PAUSE_LOG
  PAUSE_LOG_DIR
  INCOMING
  RECAPTCHA_ENABLED
  CHECKSUMS_SIGNING_ARGS
  CHECKSUMS_SIGNING_KEY
  BATCH_SIG_HOME
);

for my $item (@to_copy) {
  unless (exists $ENV{$item}) {
    warn "Missing $item from the environment! Your .env file might be incorrect...\n";
  }

  $PAUSE::Config->{$item} = $ENV{$item};
}

$PAUSE::Config->{ADMINS} = [ split(',', $PAUSE::Config->{ADMINS}) ];

$PAUSE::Config->{RECAPTCHA_ENABLED} = $ENV{TEST_HARNESS} ? 0 : $ENV{RECAPTCHA_ENABLED};

1;
