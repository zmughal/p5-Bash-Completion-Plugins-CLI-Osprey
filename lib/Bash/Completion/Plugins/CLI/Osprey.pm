package Bash::Completion::Plugins::CLI::Osprey;
# ABSTRACT: Bash::Completion plugin for CLI::Osprey-based plugins

use strict;
use warnings;

use parent 'Bash::Completion::Plugin';

use Bash::Completion::Utils qw(prefix_match);
use Class::Load qw(load_class);

sub complete_option {
	my ($self, $r, $subcommand_class, $option ) = @_;

	my @names = ();
	$r->candidates(prefix_match($r->word, @names));
}

sub complete {
	my ( $self, $r ) = @_;
	my @args = $r->args;

	my $root_class = $self->command_class;
	my ($class, %subcommands, %options, %option_arg_to_option);
	%subcommands = (
		$args[0] => $root_class,
	);

	while( @args ) {
		my $arg = shift @args;
		if( $arg =~ /^--?/  ) {
			if( $arg =~ /^-[^-]/ ) {
				# If a short option, only use the last letter to refer
				# to the option that is checked for an argument since
				# the rest are assumed to be boolean format:
				#
				#   -abc 3
				#
				#     -a : boolean
				#     -b : boolean
				#     -c : format = i
				#
				# We only care about -c.
				my $last_short = substr($arg, -1, 1);
				$arg = '-' . $last_short;
			}
			if( exists $option_arg_to_option{$arg} && exists $options{ $option_arg_to_option{$arg} }{format} ) {
				# If the option needs an argument (non-boolean format).

				my $should_complete_option = 0;
				# partial completion: ./prog --path /roo^
				$should_complete_option ||= @args == 1 &&   $r->word;
				# de novo completion: ./prog --path ^
				$should_complete_option ||= @args == 0 && ! $r->word;

				if( $should_complete_option ) {
					$self->complete_option( $r, $class, $option_arg_to_option{$arg} );
					return;
				}

				shift @args;
			}
		} elsif( exists $subcommands{$arg} ) {
			$class = $subcommands{$arg};

			# stop if InlineSubcommand
			if( ref $class ) {
				# InlineSubcommand does not provide further
				# subcommands/options via CLI::Osprey
				%subcommands = ();
				%options = ();
				%option_arg_to_option = ();
				last;
			}

			load_class($class);
			%subcommands = $class->_osprey_subcommands;
			%options = $class->_osprey_options;
			%option_arg_to_option = ();
			for my $option (keys %options) {
				my $data = $options{$option};
				$option_arg_to_option{ "--" . $data->{option} } = $option;
				$option_arg_to_option{  "-" . $data->{short}  } = $option if exists $data->{short};
			}
		}
	}

	my @subcommand_names = keys %subcommands;
	my @option_names = keys %option_arg_to_option;
	my @default_option_names = qw(-h --help --man);

	my @names = ( @subcommand_names, @option_names, @default_option_names );

	$r->candidates(prefix_match($r->word, @names));
}

1;
