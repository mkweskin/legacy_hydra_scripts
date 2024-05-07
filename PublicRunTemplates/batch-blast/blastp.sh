#!/bin/sh

for ARQ in *.fasta

do
  
  BASE=`basename $ARQ`
  NAME=${BASE%%.*}
  
    qsub -q lThC.q -N blast-$NAME -S /bin/sh -V -e job_$NAME.err -o job_$NAME.out -l mres=6G,h_data=6G,h_vmem=6G -cwd ./blastp.job $ARQ

done
