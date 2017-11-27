package TestCommand::Bar;
# ABSTRACT: A subcommand for TestCommand

use Moo;
use CLI::Osprey;

option verbose => (
	is => 'ro',
	short => 'v',
);

option root => (
	is => 'ro',
	format => 's',
	short => 'r',
);

subcommand 'xyzzy' => 'TestCommand::Bar::Xyzzy';

1;
