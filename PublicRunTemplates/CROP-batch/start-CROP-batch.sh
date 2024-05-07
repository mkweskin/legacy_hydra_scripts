#!/bin/bash
echo "This will start several runs of CROP. Each run will start in a numbered folder. You will need to modify CROP.job to refer to source files in the parent folder (e.g. ../file)."
echo

echo "How many jobs to start?"
read jobs
for ((x = 1 ; x <= jobs ; x++)); do
  echo "Submitting rep: $x"
  source CROP.qsub $x
done
