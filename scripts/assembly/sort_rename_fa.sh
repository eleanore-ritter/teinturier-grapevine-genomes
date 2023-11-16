#!/bin/bash

#Ugly script to sort and rename fasta files
#Use bash sort_rename_fa.sh <input_fasta> <cutoff_length> <output_fasta>

for i in {0..9}
do
cat $1 |\
awk '/^>/ {printf("%s%s\t",(N>0?"\n":""),$0);N++;next;} {printf("%s",$0);} END {printf("\n");}' |\
awk -F '\t' '{printf("%d\t%s\n",length($2),$0);}' |\
awk -v a=$2 '$1 >= a' |\
cut -f 2- |\
tr "\t" "\n" |\
grep -A1 ">chr0${i}" |\
awk '{if ($0 ~ /chr/) {print $0} else {print $0}}' > temp${i}.fa
done

for i in {10..19}
do
cat $1 |\
awk '/^>/ {printf("%s%s\t",(N>0?"\n":""),$0);N++;next;} {printf("%s",$0);} END {printf("\n");}' |\
awk -F '\t' '{printf("%d\t%s\n",length($2),$0);}' |\
awk -v a=$2 '$1 >= a' |\
cut -f 2- |\
tr "\t" "\n" |\
grep -A1 ">chr${i}" |\
awk '{if ($0 ~ /chr/) {print $0, $0} else {print $0}}' > temp${i}.fa
done

seq 0 19 | sed 's:.*:temp&.fa:' | xargs cat > temp20.fa

cat $1 |\
awk '/^>/ {printf("%s%s\t",(N>0?"\n":""),$0);N++;next;} {printf("%s",$0);} END {printf("\n");}' |\
awk -F '\t' '{printf("%d\t%s\n",length($2),$0);}' |\
awk -v a=$2 '$1 >= a' |\
sort -k1,1rn |\
cut -f 2- |\
tr "\t" "\n" |\
sed -e '/chr/,+1d'|\
sed s/^\>/old_name\=/ |\
awk -v i=9000000 '/old_name\=/{print ">contig_" ++i, $0; next}{print}' |\
sed s/contig_9/contig_0/ > temp21.fa

cat temp20.fa temp21.fa > $3

rm temp*
