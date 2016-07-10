use strict;

while (<STDIN>){
	my $line = $_;
	$line =~ s/(\w+):/\"$1\":/g;
	print $line;
}

