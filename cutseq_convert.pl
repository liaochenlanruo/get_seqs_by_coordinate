#!/usr/bin/perl
my $header;
my $seq = "";
my $fastaFile = "Dd_assembly_20150826.fa";
my %seq;
open IN, "$fastaFile" or die "Cannot find the specified fasta file $fastaFile";
while(my $line=<IN>){
        chomp($line);
        if ($line=~/^>/){ #the header line
                if (length $seq > 0){ #not the first line
                        $seq{$header} = $seq;
                }
                $header = substr($line,1); #remove >
                $seq = "";
        }else{
                $seq.=$line;
        }
}
$seq{$header} = $seq;
close IN;
open IN, "location";
open OUT, ">result file";
while (my $line = <IN>){
     chomp ($line);
     my ($chr,$pos)=split (":",$line);
     my ($start,$end)=split ("-",$pos);
	 if ($start > $end) {
         ($start,$end) = ($end,$start);
		 my $seq = $seq{$chr};
	     my $start1 = $start - 1;
#        my $part = substr($seq,$start1, $end-$start1); #add +1 or -1 after testing
	     my $part = substr($seq,$start1-200, $end); #from the 200bp before the start to the end
		 my $re_part= &reverse_complement($part);
#		 my $id = $chr . ":" . 
         print OUT ">$line\n$re_part\n";
	 }else{
       my $seq = $seq{$chr};
	   my $start1 = $start - 1;
#       my $part = substr($seq,$start1, $end-$start1); #add +1 or -1 after testing
	   my $part = substr($seq,$start1, $end+200); #from the start to 200bp after the end
       print OUT ">$line\n$part\n";
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
