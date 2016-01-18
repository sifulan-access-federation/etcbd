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
my $verbose =	0;
my $w =		3;
my $c =		5;
my $t =		10;
my $filename;
my $secret;
my $user;
my $pass;
my $status;

my $radtest =	"/usr/local/bin/rad_eap_test";


my $eduroam_method = "WPA-EAP";
my $eduroam_eap_method = "PEAP";
my $eduroam_phase2 = "PAP";
my $eduroam_operator_name;
my $eduroam_request_cui;
my $nas_ip_address;

my %ERRORS =	('OK'=>0,'WARNING'=>1,'CRITICAL'=>2,'UNKNOWN'=>3,'DEPENDENT'=>4);



sub usage() {
	my $basename = basename($0);

print <<DATA;

	Version: $version
	$basename [-h] [-d] [-H hostname] [-P port] [-w warning] [-c critical] [-t timeout] -u user -p pass -s secret

	-h|--help	This help screen
	-v|--verbose	Activate verbose mode
	-d|--debug	Activate debug mode
	-H|--hostname	Hostname to send query [Default: $host]
	-P|--port	Port where status server is listening [Default: $port]
	-w|--warning	Warning threshold in seconds [Default: $w]
	-c|--critical	Critical threshold in seconds [Default: $c]
	-t|--timeout	Timeout [Default: $t]
	-u|--user	Username
	-p|--pass	Password
	-s|--secret	Secret
	-m|--method	Auth method [Default: $eduroam_method]
	-e|--eapmethod	EAP method [Default: $eduroam_eap_method]
	-2|--phase2	Phase2 authentication [Default: $eduroam_phase2]
	-O|--operator	Operator name
	-C|--requestcui	Request Chargable user identity
	-I|--nasipaddr	NAS IP Address

	The plugin output performance data about elapsed time executing the query.

DATA

	exit $ERRORS{'UNKNOWN'};
}

sub check_options () {
	my $o_help;
	my $o_debug;
	my $o_verbose;
	my $o_request_cui;

	Getopt::Long::Configure ("bundling");
	GetOptions(
		'h|help'	=> \$o_help,
		'd|debug'	=> \$o_debug,
		'v|verbose'	=> \$o_verbose,
		'H|hostname:s'	=> \$host,
		'P|port:i'	=> \$port,
		'w|warning:i'	=> \$w,
		'c|critical:i'	=> \$c,
		't|timeout:s'	=> \$t,
		'u|user:s'	=> \$user,
		'p|pass:s'	=> \$pass,
		's|secret:s'	=> \$secret,
		'm|method:s'	=> \$eduroam_method,
		'e|eapmethod:s'	=> \$eduroam_eap_method,
		'2|phase2:s'	=> \$eduroam_phase2,
		'O|operator:s'	=> \$eduroam_operator_name,
		'C|requestcui'	=> \$o_request_cui,
		'I|nasipaddr:s'	=> \$nas_ip_address,

	);

	usage() if (defined($o_help));
	$debug = 1 if (defined($o_debug));
	$verbose = 1 if (defined($o_verbose));
	$eduroam_request_cui = 1 if (defined($o_request_cui));
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

my $cmd = "$radtest -u $user -p $pass -H $host -P $port -S $secret -m $eduroam_method -e $eduroam_eap_method -2 $eduroam_phase2 -t $t ";
$cmd .= " -O $eduroam_operator_name" if defined($eduroam_operator_name);
$cmd .= " -I $nas_ip_address" if defined($nas_ip_address);
$cmd .= " -C" if $eduroam_request_cui;
$cmd .= " -v" if $verbose;
$cmd .= " -c" if $debug;
$cmd .= ">/dev/null 2>&1 " if !$debug && !$verbose;
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

