#!/usr/bin/env perl

use Test::Most tests => 1;

use lib 't/lib';

use Bash::Completion::Plugin::Test;

subtest "TestCommand completion" => sub {
	my $tester = Bash::Completion::Plugin::Test->new(
		plugin => 'Bash::Completion::Plugins::TestCommand',
	);

	my @default_options_long = qw/--help --man/;
	my @default_options = (qw/-h/, @default_options_long);
	subtest 'TestCommand' => sub {
		my @options = (@default_options, qw/--verbose -v --config/);
		$tester->check_completions('test-command ^', [qw/init foo bar baz/, @options],
			'empty args');
		$tester->check_completions('test-command i^', [qw/init/], 'just init subcommand');
		$tester->check_completions('test-command b^', [qw/bar baz/], 'the b* subcommands');
		$tester->check_completions('test-command -^', [@options],
			'all options');
		$tester->check_completions('test-command --^', [@default_options_long, qw/--verbose --config/],
			'just long options');

		$tester->check_completions('test-command init ^', [@default_options],
			'init subcommand is inline: no further options or subcommands');

		$tester->check_completions('test-command --config ignore also-ignore i^', [qw/init/],
			'ignore unknown args');
	};

	subtest 'TestCommand::Bar' => sub {
		my @options = (@default_options, qw/-v --verbose -r --root/);
		$tester->check_completions('test-command bar ^', [@options, qw/xyzzy/],
			'empty args');
		$tester->check_completions('test-command bar --root / ^',  [@options, qw/xyzzy/],
			'with an option');
		$tester->check_completions('test-command bar --root / -^', [@options],
			'another option');
		$tester->check_completions('test-command bar --root / x^', [ qw/xyzzy/],
			'start a subcommand');

		subtest 'Option complete' => sub {
			my @roots = qw|/root1 /root2|;
			my @all_roots = (@roots, qw|/another-root|);
			subtest 'Part of option at a time' => sub {
				my @option_kinds = qw(--root -r -vr);
				plan tests => 0+@option_kinds;
				for my $option_kind (@option_kinds) {
					subtest "Option: $option_kind" => sub {
						$tester->check_completions("test-command bar $option_kind ^", [@all_roots],
							'need argument for option');
						$tester->check_completions("test-command bar $option_kind /^", [@all_roots],
							'/');
						$tester->check_completions("test-command bar $option_kind /r^", [@roots],
							'/r');
						$tester->check_completions("test-command bar $option_kind /roo^", [@roots],
							'/roo');
						$tester->check_completions("test-command bar $option_kind /root1^", [qw|/root1|],
							'/root1');
						$tester->check_completions("test-command bar $option_kind /root1 ^", [@options, qw|xyzzy|],
							'empty');
					};
				}
			};

			subtest 'With text after' => sub {
				$tester->check_completions('test-command bar --root /roo^ x', [@roots],
					'subcommand after');
				$tester->check_completions('test-command bar --root /roo^z', [@roots],
					'text after');
				$tester->check_completions('test-command bar --root /roo^z x', [@roots],
					'text after, subcommand after');
				$tester->check_completions('test-command bar --root /^ x', [@all_roots],
					'all option results');
			};
		};
	};

	subtest 'TestCommand::Bar::Xyzzy' => sub {
		my @options = (@default_options, qw/-p --path --feature/);
		$tester->check_completions('test-command bar xyzzy ^', [@options, qw/plugh/],
			'empty args');
		$tester->check_completions('test-command bar --root / xyzzy ^', [@options, qw/plugh/],
			'with bar option preceding');
		$tester->check_completions('test-command bar --root / xyzzy -^', [@options],
			'all options');
		$tester->check_completions('test-command bar --root / xyzzy --path ^', [],
			'--path takes an argument but no completion available');
		$tester->check_completions('test-command bar --root / xyzzy -p ^', [],
			'-p takes an argument but no completion available');
	};
};

done_testing;
