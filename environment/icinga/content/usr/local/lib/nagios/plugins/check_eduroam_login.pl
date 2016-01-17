#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use File::Basename;
use Time::HiRes qw(gettimeofday tv_interval);;

# Based on check_radius.pl
# Originally fetched from Nagios exchange, 
# https://exchange.nagios.org/directory/Plugins/Network-Protocols/RADIUS/check_radius-2Epl/details

# my $version =	"20100116";
my $version =	"20131106";
my $host =	"localhost";
my $port =	1812;
my $debug =	0;
my $w =		3;
my $c =		5;
my $t =		10;
my $filename;
my $secret;
my $user;
my $pass;
my $status;

my $radtest =	"/usr/local/bin/rad_eap_test";

my %ERRORS =	('OK'=>0,'WARNING'=>1,'CRITICAL'=>2,'UNKNOWN'=>3,'DEPENDENT'=>4);



sub usage() {
	my $basename = basename($0);

print <<DATA;

	Version: $version
	$basename [-h] [-d] [-H hostname] [-P port] [-w warning] [-c critical] [-t timeout] -u user -p pass -s secret

	-h|--help	This help screen
	-d|--debug	Activate debug mode
	-H|--hostname	Hostname to send query [Default: $host]
	-P|--port	Port where status server is listening [Default: $port]
	-w|--warning	Warning threshold in seconds [Default: $w]
	-c|--critical	Critical threshold in seconds [Default: $c]
	-t|--timeout	Timeout [Default: $t]
	-u|--user	Username
	-p|--pass	Password
	-s|--secret	Secret

	The plugin output performance data about elapsed time executing the query.

DATA

	exit $ERRORS{'UNKNOWN'};
}

sub check_options () {
	my $o_help;
	my $o_debug;

	Getopt::Long::Configure ("bundling");
	GetOptions(
		'h|help'	=> \$o_help,
		'd|debug'	=> \$o_debug,
		'H|hostname:s'	=> \$host,
		'P|port:i'	=> \$port,
		'w|warning:i'	=> \$w,
		'c|critical:i'	=> \$c,
		't|timeout:s'	=> \$t,
		'u|user:s'	=> \$user,
		'p|pass:s'	=> \$pass,
		's|secret:s'	=> \$secret,

	);

	usage() if (defined($o_help));
	$debug = 1 if (defined($o_debug));
	if ( $port !~ /^\d+$/ or ($port <= 0 or $port > 65535)) {
		print "\nPlease insert an integer value between 1 and 65535\n";
		usage();
	}
	if ( $w !~ /^\d+$/ or $w <= 0) {
		print "\nPlease insert an integer value as warning threshold\n";
		usage();
	}
	if ( $c !~ /^\d+$/ or $c <= 0) {
		print "\nPlease insert an integer value as critical threshold\n";
		usage();
	}
	if ( $t !~ /^\d+$/ or $t < $c) {
		print "\nPlease insert an integer value greater than $c\n";
		usage();
	}
	if ( !defined($user) ) {
		print "\nPlease supply the username to test\n";
		usage();
	}
	if ( !defined($pass) ) {
		print "\nPlease supply the password to test\n";
		usage();
	}
	if ( !defined($secret) ) {
		print "\nPlease supply the secret for $host\n";
		usage();
	}
}

#
# Main
#
check_options();

my $cmd = "$radtest -u $user -p $pass -H $host -P $port -S $secret -m WPA-EAP -e PEAP -t $t >/dev/null 2>&1 ";
print "DEBUG: radclient command: $cmd\n" if $debug;

my $t0 = [gettimeofday];
system($cmd);
my $ret = $? >> 8;
my $elapsed = tv_interval($t0);

$status = $ERRORS{'OK'} if ( $elapsed < $w );
$status = $ERRORS{'WARNING'} if ( $elapsed >= $w );
$status = $ERRORS{'CRITICAL'} if ( $elapsed >= $c or $? !=0 );

print "DEBUG: Elapsed time: $elapsed seconds\n" if $debug;
print "DEBUG: radclient exit status: $?\n" if $debug;
print "DEBUG: plugin exit status: $status\n" if $debug;

print "Radius response time $elapsed seconds and return code $ret";
print " | ";
print "'Response Time'=$elapsed;$w;$c;0;$t:\n";

exit $status;

