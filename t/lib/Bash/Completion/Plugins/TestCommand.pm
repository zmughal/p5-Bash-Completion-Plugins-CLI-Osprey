package Bash::Completion::Plugins::TestCommand;
# ABSTRACT: A Bash::Completion plugin for TestCommand

use strict;
use warnings;
use parent 'Bash::Completion::Plugins::CLI::Osprey';

use Bash::Completion::Utils qw(prefix_match);

sub complete_option {
	my ($self, $r, $subcommand_class, $option ) = @_;

	my @names = ();

	if( $subcommand_class eq 'TestCommand::Bar' && $option eq 'root' ) {
		@names = qw|/root1 /root2 /another-root|;
	}

	$r->candidates(prefix_match($r->word, @names));
}

sub should_activate {
	return [ 'test-command' ];
}

sub command_class { 'TestCommand' }

1;
