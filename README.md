10x Genomics scRNA-Seq (cellranger) count Pipeline
========================================

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
        * eg: **--fastq '/project/shared/bicf_workflow_ref/workflow_testdata/cellranger/cellranger_count/v2s2r100k/\*.fastq.gz'**
  * **--designFile**
        * path to design file (csv format) location
        * column 1 = "Sample"
        * column 2 = "fastq_R1"
        * column 3 = "fastq_R2"
        * can have repeated "Sample" if there are multiole fastq R1/R2 pairs for the samples
        * eg: **--designFile '/project/shared/bicf_workflow_ref/workflow_testdata/cellranger/cellranger_count/v2s2r100k/design.csv'**
    * **--genome**
        * name of available 10x Gemomics premade reference genomes:
            * *'GRCh38-3.0.0'* = Human GRCh38 release 93
            * *'GRCh38-3.0.0'* = Human GRCh38 release 93
            * *'GRCh38-3.0.0'* = Human GRCh38 release 93
            * *'GRCh38-3.0.0'* = Human GRCh38 release 93
    * **--genomeLocationFull**
    * **--expectCells**
    * **--forceCells**
    * **--kitVersion**
    * **--version**
    * **--outDir**

* Design example:

| Sample  | fastq_R1                           | fastq_R2                           |
|---------|------------------------------------|------------------------------------|
| sample1 | pbmc_1k_v2_S1_L001_R1_001.fastq.gz | pbmc_1k_v2_S1_L001_R2_001.fastq.gz |
| sample2 | pbmc_1k_v2_S2_L001_R1_001.fastq.gz | pbmc_1k_v2_S2_L001_R2_001.fastq.gz |
| sample2 | pbmc_1k_v2_S2_L002_R1_001.fastq.gz | pbmc_1k_v2_S2_L002_R2_001.fastq.gz |