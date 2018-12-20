#! /usr/bin/perl
use strict; use warnings; 
use Data::Dumper;
use Getopt::Long;


#CCK <30/jun/2016>

# default values
my $some_dir;	# option variable with default value
my $tag;
my $header;
my $verbose;
my $help;

# if no argument is given; print usage
if (!@ARGV) {
    print "$0: Argument required.\n\n";
    usage();
}

# otherwise get arguments
GetOptions('dir|d=s' => \$some_dir,
           'tag|t=s' => \$tag,
	   'header|a' => \$header,
           'verbose|v' => \$verbose,
           'help|h|?' => \$help) 
    or die("$0: Error in command line arguments.\n\n*** --help for usage ***\n\n");


if($help){
    usage();
}

sub usage {
    print STDERR<<USAGE;

  Description: all files which file name match the 'specified tag' from directory 
               will be joined in a matrix.
  
  Input: two-column TSV files
  Output: matrix in R format (header has n-1 fields)

  Usage: perl $0
    --dir|d       : directory to read all tsv files
    --tag|t       : tag for file names
    --header|h    : if TSV files have a header
    --verbose|v   
    --help
    
  Example:
    perl $0 --dir ~cklein/analysis --tag astalavista


USAGE
    exit();
}
###########################################################################################

my %matrix;
my @samples;
opendir(my $dh, $some_dir) || die "Can't open $some_dir: $!";
my @files = readdir $dh;
foreach my $f (@files) {
    if($f=~/$tag/ && $f=~/.tsv$/){
	print STDERR "open file: $some_dir/$f\n";
	(my $id)=($f=~/(^.+).tsv/);
	$id =~ s/$tag//;
	$id =~ s/\.\./\./;
	$id =~ s/\.$//;
	push(@samples,$id);
	my $pf="$some_dir/$f";
	open(F,"<$pf" || die "can't open file $pf: $!");
	my $c=0;
	while(my $l = <F>){
	    chomp($l);
	    if(($header && $c>0) || (! $header)){
		my @tmp = split(/\t/,$l);
		$matrix{$tmp[0]}{$id}=$tmp[1];   
	    }
	    $c=$c+1;
	}
	close(F);
    }
}
closedir $dh;


# header
my $c=0;
foreach my $hid (sort @samples) {
    if($c eq 0){
	print $hid;
	$c=$c+1;
    }else{
	print "\t".$hid;
    }
}
print "\n";

# print matrix
foreach my $peak (sort keys %matrix) {
    print "$peak";
    foreach my $id (sort @samples) {
    if(exists $matrix{$peak}{$id}){
	    print "\t$matrix{$peak}{$id}";	    
	}else {
	    print "\tNA";
	}
    }
    print "\n";
}


#print Dumper(\%matrix);
