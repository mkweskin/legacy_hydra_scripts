#!/usr/bin/env perl

use warnings;
use File::Copy;
use Cwd;
use File::Basename;

$split_seqs=1;
$out_template="NUMBER.fasta";
$count=0;
$filenum=0;
$len=0;
while (<>) {
    s/\r?\n//;
    if (/^>/) {
	if ($count % $split_seqs == 0) {
	    $filenum++;
	    $filename = $out_template;
	    $filename =~ s/NUMBER/$filenum/g;
	    if ($filenum > 1) {
		close SHORT
	    }
	    open (SHORT, ">$filename") or die $!;
	    
	}
	$count++;
	
    }
    else {
	$len += length($_)
    }
    print SHORT "$_\n";
}
close(SHORT);
warn "\nSplit $count FASTA records in $. lines, with total sequence length $len\nCreated $filenum files like $filename\n\n";

#Run each sequence
for ($rep=1; $rep<=$count; $rep++){
	warn "\nStarting job $rep\n";
	mkdir $rep, 0755 or die "can't create folder $rep: $!";
	move("$rep.fasta","$rep") or die "Cannot copy $rep.fasta to $rep: $!";
	system("qsub -N SAP-$rep -o $rep/$rep.out SAP-batch.qsub $rep");
}

