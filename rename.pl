#!/usr/bin/perl -w
# From the Perl Cookbook, Ch. 9.9
# rename - Larry's filename fixer
# - http://brablc.com/ - added interactive mode with preview

$help = <<EOF;
Usage: rename [-i] expr [files]
 
This script's first argument is Perl code that alters the filename (stored in \$_ ) to reflect how you want the file renamed. It can do this because it uses an eval to do the hard work. It also skips rename calls when the filename is untouched. This lets you simply use wildcards like rename EXPR * instead of making long lists of filenames. 

Use the switch -i to see interactively what it will do.
 
Here are examples of calling the rename program from your shell:
 
% rename 's/\.orig\$//' *.orig
% rename 'tr/A-Z/a-z/ unless /^Make/' *
% rename '\$_ .= ".bad"' *.f
% rename -i 's/foo/bar/' *
% find /tmp -name '*~' -print | rename 's/^(.+)~\$/.#\$1/'

The first shell command removes a trailing ".orig" from each filename.
 
The second converts uppercase to lowercase. Because a translation is used rather than the lc function, this conversion won't be locale-aware. To fix that, you'd have to write:
 
% rename 'use locale; \$_ = lc(\$_) unless /^Make/' *
 
The third appends ".bad" to each Fortran file ending in ".f", something a lot of us have wanted to do for a long time.
 
The fourth prompts the user for the change. Each file's name is printed to standard output and a response is read from standard input. If the user types something starting with a "y" or "Y", any "foo" in the filename is changed to "bar". To preview changes appen </dev/null to the command.
 
The fifth uses find to locate files in /tmp that end with a tilde. It renames these so that instead of ending with a tilde, they start with a dot and a pound sign. In effect, this switches between two common conventions for backup files
EOF

$in = 0;
do {
	$op = shift or die $help;
} while ($op eq "-i" && ($in = 1));

chomp(@ARGV = <STDIN>) unless @ARGV;
for (@ARGV) {
    $was = $_;
    eval $op;
    if ($in) {
        print "'$was' => '$_': ";
        $rsp = <STDIN>;
        unless (defined $rsp) {
        	$rsp = "n";
        	print "$rsp\n";
        }
        next unless $rsp =~ /^y/i;
    }
    die $@ if $@;
    rename($was,$_) unless $was eq $_;
}
