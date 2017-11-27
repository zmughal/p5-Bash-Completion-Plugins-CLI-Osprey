package TestCommand;
# ABSTRACT: A CLI::Osprey-based test command

use Moo;
use CLI::Osprey;

option 'verbose' => (
	is => 'ro',
	short => 'v',
);

option 'config_file' => (
	is => 'ro',
	format => 's',
	option => 'config',
);

subcommand 'init' => sub { 1 };

subcommand 'foo' => sub { 1 };

subcommand 'bar' => 'TestCommand::Bar';

subcommand 'baz' => sub { 1 };

1;
