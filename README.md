|*master*|*develop*|
|:-:|:-:|
|[![Build Status](https://git.biohpc.swmed.edu/BICF/Astrocyte/cellranger_count/badges/master/build.svg)](https://git.biohpc.swmed.edu/BICF/Astrocyte/cellranger_count/commits/master)|[![Build Status](https://git.biohpc.swmed.edu/BICF/Astrocyte/cellranger_count/badges/develop/build.svg)](https://git.biohpc.swmed.edu/BICF/Astrocyte/cellranger_count/commits/develop)|

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.2652622.svg)](https://doi.org/10.5281/zenodo.2652622)


10x Genomics scRNA-Seq (cellranger) count Pipeline
==================================================

Introduction
------------

This pipeline is a wrapper for the cellranger count tool from 10x Genomics. It takes fastq files from 10x Genomics Single Cell Gene Expression libraries, performs alignment, filtering, barcode counting, and UMI counting. It uses the Chromium cellular barcodes to generate gene-barcode matrices, determine clusters, and perform gene expression analysis.

The pipeline uses Nextflow, a bioinformatics workflow tool.

This pipeline is primarily used with a SLURM cluster on the BioHPC Cluster. However, the pipeline should be able to run on any system that Nextflow supports.

Additionally, the pipeline is designed to work with Astrocyte Workflow System using a simple web interface.

To Run:
-------

* Available parameters:
  * **--fastq**
    * path to the fastq location
    * R1 and R2 only necessary but can include I2
    * only fastq's in designFile (see below) are used, not present will be ignored
    * eg: **--fastq '/project/shared/bicf_workflow_ref/workflow_testdata/cellranger/cellranger_count/hu.v3s2r100k/\*.fastq.gz'**
  * **--designFile**
    * path to design file (csv format) location
    * column 1 = "Sample"
    * column 2 = "fastq_R1"
    * column 3 = "fastq_R2"
    * can have repeated "Sample" if there are multiple fastq R1/R2 pairs for the samples
    * can be downloaded [HERE](https://git.biohpc.swmed.edu/BICF/Astrocyte/cellranger_count/blob/master/docs/design.csv)
    * eg: **--designFile '/project/shared/bicf_workflow_ref/workflow_testdata/cellranger/cellranger_count/hu.v3s2r100k/design.csv'**
  * **--genome**
    * reference genome
    * requires workflow/conf/biohpc.config to work
    * name of available 10x Gemomics premade reference genomes:
        * *'GRCh38-3.0.0'* = Human GRCh38 release 93
        * *'GRCh38-1.2.0'* = Human GRCh38 release 84
        * *'hg19-3.0.0'* = Human GRCh37 (hg19) release 87
        * *'hg19-1.2.0'* = Human GRCh37 (hg19) release 84
        * *'mm10-3.0.0'* = Mouse GRCm38 (mm10) release 93
        * *'mm10-3.0.0'* = Mouse GRCm38 (mm10) release 84
        * *'hg19_and_mm10-3.0.0'* = Human GRCh37 (hg19) + Mouse GRCm38 (mm19) release 93
        * *'hg19_and_mm10-1.2.0'* = Human GRCh37 (hg19) + Mouse GRCm38 (mm19) release 84
        * *'ercc92-1.2.0'* = ERCC.92 Spike-In
    * if --genome is used then --genomeLocationFull is not necessary
    * eg: **--genome 'GRCh38-3.0.0'**
  * **--genomeLocationFull**
    * path to a custom genome
    * if --genomeLocationFull is used --genome is not necessary and is ignored
    * eg. **--genomeLocationFull '/project/apps_database/cellranger/refdata-cellranger-GRCh38-3.0.0'**
  * **--expectCells**
    * expected number of cells to be detected
    * guides cellranger in it's cutoff for background/low quality cells
    * as a guide it doesn't have to be exact
    * 0-10000
    * if --expextedCells is used then --forceCells is not necessary
    * only used if --forceCells is not entered or set to 0
    * eg: **--expectCells 10000**
  * **--forceCells**
    * forces filtering of the top number of cells matching this parameter
    * 0-10000
    * if --forceCells is used then --expectedCells is not necessary and is ignored
    * eg: **--forceCells 10000**
  * **--kitVersion**
    * the library chemistry version number for the 10x Genomics Gene Expression kit
    * setting to auto will attempt to autodetect from the detected sequencing strategy in the fastq's
    * version numbers are spelled out
    * --kitversion is only used if --version (cellranger version) is > 2
    * --version (cellranger version) 2.1.1 can only read --kitVersion of two (2)
    * options:
        * *'auto'*
        * *'three'*
        * *'two'*
    * eg: **--kitVersion 'three'**
  * **--version**
    * cellranger version
    * --version (cellranger version) 2.1.1 can only read --kitVersion of two (2)
    * options:
        * *'3.0.2'*
        * *'3.0.1'*
        * *'2.1.1'*
    * eg: **--version '3.0.2'**
  * **--outDir**
    * optional output directory for run
    * eg: **--outDir 'test'**
* FULL EXAMPLE:
  ```
  nextflow run workflow/main.nf --fastq '/project/shared/bicf_workflow_ref/workflow_testdata/cellranger/cellranger_count/hu.v3s2r100k/*.fastq.gz' --designFile '/project/shared/bicf_workflow_ref/workflow_testdata/cellranger/cellranger_count/hu.v3s2r100k/design.csv' --genome 'GRCh38-3.0.0' --kitVersion 'three' --version '3.0.2' --outDir 'test'
  ```
* Design example:

| Sample  | fastq_R1                           | fastq_R2                           |
|---------|------------------------------------|------------------------------------|
| sample1 | pbmc_1k_v2_S1_L001_R1_001.fastq.gz | pbmc_1k_v2_S1_L001_R2_001.fastq.gz |
| sample2 | pbmc_1k_v2_S2_L001_R1_001.fastq.gz | pbmc_1k_v2_S2_L001_R2_001.fastq.gz |
| sample2 | pbmc_1k_v2_S2_L002_R1_001.fastq.gz | pbmc_1k_v2_S2_L002_R2_001.fastq.gz |

[**CHANGELOG**](https://git.biohpc.swmed.edu/BICF/Astrocyte/cellranger_count/blob/develop/CHANGELOG.md)

Credits
-------
This worklow is was developed jointly with the [Bioinformatic Core Facility (BICF), Department of Bioinformatics](http://www.utsouthwestern.edu/labs/bioinformatics/)


Please cite in publications: Pipeline was developed by BICF from funding provided by **Cancer Prevention and Research Institute of Texas (RP150596)**.
