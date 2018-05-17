my $header;
my $seq;
my %seq;
my @fa = glob("*.fa");
foreach my $fa (@fa) {
	if ($fa =~/(\S+)\.fa/) {
		my $ass = $1;
		open IN,"$fa" || die;
		while (<IN>) {
			chomp;
			if (/^>(\d+)/){ #the header line
				$header = $1;
			}else{
			    $seq=$_;
				$seq{$ass}{$header} = $seq;
			}
		}
        close IN;
	}
}
open INF, "location2.txt";
open OUT, ">result.fa";
while (my $line = <INF>){
     chomp ($line);
	 my ($str,$loca) = split("\t",$line);
     my ($chr,$pos)=split (":",$loca);
     my ($start,$end)=split ("-",$pos);
	 if ($start > $end) {
         ($start,$end) = ($end,$start);
		 if (exists $seq{$str}{$chr}) {
			 my $seqs = $seq{$str}{$chr};
			 my $start1 = $start - 1;
			 my $part = substr($seqs,$start1, $end); #from the 200bp before the start to the end
			 my $re_part= &reverse_complement($part);
			 print OUT ">$str" . "_" . $loca . "\n$re_part\n";
		 }else{print ">$str" . "_" . $loca . "\n";}
	  }else{
	      if (exists $seq{$str}{$chr}) {
			  my $seqs = $seq{$str}{$chr};
			  my $start1 = $start - 1;
			  my $part = substr($seqs,$start1, $end); #from the start to 200bp after the end
			  print OUT ">$str" . "_" . $loca . "\n$part\n";
		  }else{
			  print print ">$str" . "_" . $loca . "\n";
			  }
	  }
}
close IN;
close OUT;

sub reverse_complement {
        my $dna = shift;
        my $revcomp = reverse($dna);# reverse the DNA sequence
        $revcomp =~ tr/ACGTacgt/TGCAtgca/;# complement the reversed DNA sequence
        return $revcomp;
}
