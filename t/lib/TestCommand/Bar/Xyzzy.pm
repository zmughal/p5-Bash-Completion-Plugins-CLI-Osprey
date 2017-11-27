package TestCommand::Bar::Xyzzy;
# ABSTRACT: A subcommand for TestCommand

use Moo;
use CLI::Osprey;

option path => (
	is => 'ro',
	format => 's',
	short => 'p',
);

option feature => (
	is => 'ro',
	format => 's',
);

subcommand 'plugh' => sub { 1 };

1;
