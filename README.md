10x Genomics scRNA-Seq (cellranger) count Pipeline
========================================

Introduction
------------

This pipeline is a wrapper for the cellranger count tool from 10x Genomics. It takes fastq files from 10x Genomics Single Cell Gene Expression libraries, performs alignment, filtering, barcode counting, and UMI counting. It uses the Chromium cellular barcodes to generate gene-barcode matrices, determine clusters, and perform gene expression analysis.

The pipeline uses Nextflow, a bioinformatics workflow tool.

This pipeline is primarily used with a SLURM cluster on the BioHPC Cluster. However, the pipeline should be able to run on any system that Nextflow supports.

Additionally, the pipeline is designed to work with Astrocyte Workflow System using a simple web interface.