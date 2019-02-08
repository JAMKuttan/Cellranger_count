#!/usr/bin/env nextflow

// Path to an input file, or a pattern for multiple inputs
// Note - $baseDir is the location of this workflow file main.nf

// Define Input variables
params.fastq = "$baseDir/../test_data/*.fastq.gz"
params.designFile = "$baseDir/../test_data/design.csv"
params.genome = '/project/apps_database/cellranger/refdata-cellranger-GRCh38-1.2.0'
params.expectCells = 10000
params.forceCells = 0

// Define regular variables
designLocation = Channel
  .fromPath(params.designFile)
  .ifEmpty { exit 1, "design file not found: ${params.designFile}" }
fastqList = Channel
  .fromPath(params.fastq)
  .flatten()
  .map { file -> [ file.getFileName().toString(), file.toString() ].join("\t") }
  .collectFile(name: 'fileList.tsv', newLine: true)
refLocation = Channel
  .fromPath(params.genome)
  .ifEmpty { exit 1, "referene not found: ${params.genome}" }
expectCells = params.expectCells
forceCells = params.forceCells

process checkDesignFile {

  publishDir "$baseDir/output", mode: 'copy'

  input:

  file designLocation
  file fastqList

  output:

  file("design.checked.csv") into designPaths

  script:

  """
  module load python/3.6.1-2-anaconda
  python3 $baseDir/scripts/check_design.py -d $designLocation -f $fastqList
  """
}

// Parse design file
samples = designPaths
  .splitCsv (sep: ',', header: true)
  .map { row -> [ row.Sample, file(row.fastq_R1), file(row.fastq_R2) ] }
  .groupTuple()
  //.subscribe { println it }


process count {
  tag "$sample"

  publishDir "$baseDir/output", mode: 'copy'

  input:

  set sample, file("${sample}_S1_L00?_R1_001.fastq.gz"), file("${sample}_S1_L00?_R2_001.fastq.gz") from samples
  file ref from refLocation.first()
  expectCells
  forceCells

  output:

  file("**/outs/**") into outPaths

  script:
  if (forceCells == 0){
    """
    module load cellranger/2.1.1
    cellranger count --id="$sample" --transcriptome="./$ref" --fastqs=. --sample="$sample" --expect-cells=$expectCells
    """
  } else {
    """
    module load cellranger/2.1.1
    cellranger count --id="$sample" --transcriptome="./$ref" --fastqs=. --sample="$sample" --force-cells=$forceCells
    """
  }
}
