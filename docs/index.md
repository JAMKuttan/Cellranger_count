10x Genomics scRNA-Seq (cellranger) count Pipeline
========================================

Introduction
------------

This pipeline is a wrapper for the cellranger count tool from 10x Genomics. It takes fastq files from 10x Genomics Single Cell Gene Expression libraries, performs alignment, filtering, barcode counting, and UMI counting. It uses the Chromium cellular barcodes to generate gene-barcode matrices, determine clusters, and perform gene expression analysis.

The pipeline uses Nextflow, a bioinformatics workflow tool.

To Run:
-------

* Workflow parameters:
  * **fastq**
        * Pairs (read1 and read2) of fastq.gz files from a sequencing of 10x single-cell expereiment. Index fastq not required.
        * REQUIRED
        * R1 and R2 only necessary
  * **design file**
        * A design file listing sample, corresponding read1 filename, corresponding read2 filename. There can be multiple rows with the same sample name, if there are multiple fastq's for that sample.
        * REQUIRED
        * column 1 = "Sample"
        * column 2 = "fastq_R1"
        * column 3 = "fastq_R2"
        * can have repeated "Sample" if there are multiole fastq R1/R2 pairs for the samples
        * eg: can be downloaded [HERE](https://git.biohpc.swmed.edu/BICF/Astrocyte/cellranger_count/blob/8db3e25c13cb1463c2a50e510159c72380ae5826/docs/design.csv)
  * **genome**
        * Reference species and genome used for alignment and subsequent analysis.
        * name of available 10x Gemomics premade reference genomes:
            * *'GRCh38-3.0.0'* = Human GRCh38 release 93
            * *'GRCh38-1.2.0'* = Human GRCh38 release 84
            * *'hg19-3.0.0'* = Human GRCh37 (hg19) release 87
            * *'hg19-1.2.0'* = Human GRCh37 (hg19) release 84
            * *'mm10-3.0.0'* = Human GRCm38 (mm10) release 93
            * *'mm10-3.0.0'* = Human GRCm38 (mm10) release 84
            * *'hg19_and_mm10-3.0.0'* = Human GRCh37 (hg19) + Mouse GRCm38 (mm19) release 93
            * *'hg19_and_mm10-1.2.0'* = Human GRCh37 (hg19) + Mouse GRCm38 (mm19) release 84
            * *'ercc92-1.2.0'* = ERCC.92 Spike-In
  * **expect cells**
        * Expected number of recovered cells.
        * guides cellranger in it's cutoff for background/low quality cells
        * as a guide it doesn't have to be exact
        * 0-10000
        * if --expextedCells is used then --forceCells is not necessary
        * only used if force cells is not entered or set to 0
   * **force cells**
        * Force pipeline to use this number of cells, bypassing the cell detection algorithm. Use this if the number of cells estimated by Cell Ranger is not consistent with the barcode rank plot. A value of 0 ignores this option. Any value other than 0 overrides expect-cells.
        * 0-10000
        * if force cells is used then expected cells is not necessary and is ignored
  * **chemistry version**
        * 10x single cell gene expression chemistry version (only used in cellranger version 3.x).
        * setting to auto will attempt to autodetect from the detected cycle strategy in the fastq's
        * chemistry version is only used if cellranger version is > 2.x
        * cellranger version 2.1.1 can only read chemistry version less than or equal to two (2)
   * **cellranger version**
        * 10x cellranger version.
        * cellranger version 2.1.1 can only read chemistry version less than or equal to two (2)

* Design example:

    | Sample  | fastq_R1                           | fastq_R2                           |
    |---------|------------------------------------|------------------------------------|
    | sample1 | pbmc_1k_v2_S1_L001_R1_001.fastq.gz | pbmc_1k_v2_S1_L001_R2_001.fastq.gz |
    | sample2 | pbmc_1k_v2_S2_L001_R1_001.fastq.gz | pbmc_1k_v2_S2_L001_R2_001.fastq.gz |
    | sample2 | pbmc_1k_v2_S2_L002_R1_001.fastq.gz | pbmc_1k_v2_S2_L002_R2_001.fastq.gz |
    


Credits
------------
This worklow is was developed jointly with the [Bioinformatic Core Facility (BICF), Department of Bioinformatics](http://www.utsouthwestern.edu/labs/bioinformatics/)


Please cite in publications: Pipeline was developed by BICF from funding provided by **Cancer Prevention and Research Institute of Texas (RP150596)**.
