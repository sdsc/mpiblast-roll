#!/usr/bin/perl -w
use Env;
# mpiblast roll installation test.  Usage:
# mpiblast.t [nodetype]
#   where nodetype is one of "Compute", "Dbnode", "Frontend" or "Login"
#   if not specified, the test assumes either Compute or Frontend

use Test::More qw(no_plan);

my $appliance = $#ARGV >= 0 ? $ARGV[0] :
                -d '/export/rocks/install' ? 'Frontend' : 'Compute';
my $installedOnAppliancesPattern = '.';
my $isInstalled = -d '/opt/mpiblast';
my $output;

my $TESTFILE = 'tmpmpiblast';
`mkdir -p $TESTFILE.dir/db/blast`;
open(OUT, ">$TESTFILE.dir/$TESTFILE.in");
print OUT <<END;
>
AGCTTTTCATTCTGACTGCAACGGGCAATATGTCTCTGTGTGGATTAAAAAAAGAGTGTCTGATAGCAGC
TTCTGAACTGGTTACCTGCCGTGAGTAAATTAAAATTTTATTGACTTAGGTCACTAAATACTTTAACCAA
TATAGGCATAGCGCACAGACAGATAAAAATTACAGAGTACACAACATCCATGAAACGCATTAGCACCACC
ATTACCACCACCATCACCATTACCACAGGTAACGGTGCGGGCTGACGCGTACAGGAAACACAGAAAAAAG
CCCGCACCTGACAGTGCGGGCTTTTTTTTTCGACCAAAGGTAACGAGGTAACAACCATGCGAGTGTTGAA
GTTCGGCGGTACATCAGTGGCAAATGCAGAACGTTTTCTGCGTGTTGCCGATATTCTGGAAAGCAATGCC
AGGCAGGGGCAGGTGGCCACCGTCCTCTCTGCCCCCGCCAAAATCACCAACCACCTGGTGGCGATGATTG
AAAAAACCATTAGCGGCCAGGATGCTTTACCCAATATCAGCGATGCCGAACGTATTTTTGCCGAACTTTT
END
close(OUT);
open(OUT, ">$ENV{'HOME'}/.ncbirc");
print OUT <<END;
[mpiBLAST]
Shared=$ENV{'PWD'}/$TESTFILE.dir/db/blast
Local=$ENV{'PWD'}/$TESTFILE.dir/db/blast
END
close(OUT);

open(OUT, ">$TESTFILE.sh");
print OUT <<END;
module load mpiblast
cd $TESTFILE.dir/db/blast
wget ftp://ftp.ncbi.nlm.nih.gov/blast/db/FASTA/drosoph.nt.gz
gunzip drosoph.nt.gz
mpiformatdb --nfrags=4 -i ./drosoph.nt -pF --quiet
cd ../..
output=`mpirun -np 8 /opt/mpiblast/bin/mpiblast -d drosoph.nt -i $TESTFILE.in -p blastn -o output 2>&1`
if [[ "\$output" =~ "run-as-root" ]]; then
  # Recent openmpi requires special option for root user
  output=`mpirun --allow-run-as-root -np 8 /opt/mpiblast/bin/mpiblast -d drosoph.nt -i $TESTFILE.in -p blastn -o output 2>&1`
fi
echo \$output
cat output
END
close(OUT);

# mpiblast-common.xml
if($appliance =~ /$installedOnAppliancesPattern/) {
  ok($isInstalled, 'mpiblast installed');
} else {
  ok(! $isInstalled, 'mpiblast not installed');
}
SKIP: {

  skip 'mpiblast not installed', 4 if ! $isInstalled;
  $output=`bash $TESTFILE.sh 2>&1`;
  like($output, qr/Score = 34.2 bits \(17\), Expect = 3.4/, 'mpiblast runs');

  `/bin/ls /opt/modulefiles/applications/mpiblast/[0-9]* 2>&1`;
  ok($? == 0, 'mpiblast module installed');
  `/bin/ls /opt/modulefiles/applications/mpiblast/.version.[0-9]* 2>&1`;
  ok($? == 0, 'mpiblast version module installed');
  ok(-l '/opt/modulefiles/applications/mpiblast/.version',
     'mpiblast version module link created');

}

`rm -rf $TESTFILE*`;
