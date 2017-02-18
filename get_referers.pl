#!/usr/bin/perl

sub extract_host
{
	my $ref = shift;
	if ($ref =~ 'http://([^/]+)/')
	{
		return $1;
	}	
	return $ref;
}

sub extract_url
{
	my $get = shift;
	#GET /priv/dc/baby01/ HTTP/1.1

	if ($get =~ '(\w+) (\S+) (HTTP.*)')
	{
		my $pre = $1;
		my $path = $2;
		my $post = $3;
		return qq($pre <a href="$path">$path</a> $post);
	}
	return $get
}

my %cache = ();

sub in_cache
{
	my $host = shift;
	return 1 if (defined $cache{$host});
	$cache{$host}++;
	return 0;
}

#65.214.36.56 - - [28/Jun/2004:03:48:10 -0700] "GET /u/rance/ HTTP/1.0" 200 788 "-" "Mozilla/2.0 (compatible; Ask Jeeves/Teoma)"
my $regex = qr'(\d+\.\d+\.\d+\.\d+)\s\S+\s\S+\s\[(\d+)/(\w+)/(\d{4}:\d{2}:\d{2}:\d{2})\s\-0\d00\]\s"(.*)"\s\d{3}\s\d+\s"(.*)"\s".*"';

print "<ul>\n";
while (<>)
{
	if (/$regex/)
	{
		my $source = $1;
		my $day = $2;
		my $month = $3;
		my $time = $4;
		my $get = $5;
		my $ref = $6;

		next if ($ref eq "-" || $ref =~ /chalco\.dyndns\.org/);

		#print "$source $ref\n";
		my $host = extract_host $ref;
		my $url = extract_url $get;
		next if (in_cache $ref);
		print <<EOF;
		<li>
		<a href="$ref">$host</a>
		($url)
		</li>

EOF
	}
}
print "</ul>\n";
