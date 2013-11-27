# SDSC mpiblast-roll

The SDSC mpiblast-roll installs  [MPIBLAST](www.mpiblast.org) into a Rocks(r) roll that can be installed easily on a Rocks(r) cluster.

## Roll Dependencies

The mpiblast-roll requires that you first build and install a compiler roll  (for example [gnu](http://github.com/sdsc/gnucompiler-roll), [intel](http://github/sdsc/intel-roll), or [pgi](http://github/sdsc/pgi-roll)) and the mpi roll [mpi](http://github/sdsc/mpi-roll)

## Installed Programs

### mpiblast

- mpiblast  is a freely available, open-source, parallel implementation of [NCBI BLAST] (http://blast.ncbi.nlm.nih.gov). By efficiently utilizing distributed computational resources through database fragmentation, query segmentation, intelligent scheduling, and parallel I/O, mpiBLAST improves NCBI BLAST performance by several orders of magnitude while scaling to hundreds of processors


##  Module File
- mpiblast-modules installs/configures module files for mpiblast.
