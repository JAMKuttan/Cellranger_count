#!/usr/bin/env nextflow

// Path to an input file, or a pattern for multiple inputs
// Note - $baseDir is the location of this workflow file main.nf

// Define Input variables
params.fastq = "$baseDir/../test_data/*.fastq.gz"
params.designFile = "$baseDir/../test_data/design.csv"
params.genome = 'GRCh38-3.0.0'
params.genomes = []
params.genomeLocation = params.genome ? params.genomes[ params.genome ].loc ?: false : false
params.expectCells = 10000
params.forceCells = 0
params.kitVersion = '3'
params.chemistry = []
params.chemistryParam = params.kitVersion ? params.chemistry[ params.kitVersion ].param ?: false : false
params.version = '3.0.2'
params.feature = 'yes'
params.outDir = "$baseDir/output"

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
  .fromPath(params.genomeLocation+params.genome)
  .ifEmpty { exit 1, "referene not found: ${params.genome}" }
expectCells = params.expectCells
forceCells = params.forceCells
chemistryParam = params.chemistryParam
version = params.version
feature = params.feature
featurechk = feature
outDir = params.outDir

process checkDesignFile {

  publishDir "$outDir/${task.process}", mode: 'copy'

  input:

  file designLocation
  file fastqList
  featurechk

  output:

  file("*.checked.csv") into designPaths

  script:

  """
  python3 $baseDir/scripts/check_design.test.py -d $designLocation -f $fastqList -t "$featurechk"
  """
}

// Parse design file
samples = designPaths
  .splitCsv (sep: ',', header: true)
  .map { row -> [ row.Sample, file(row.fastq_R1), file(row.fastq_R2) ] }
  .groupTuple()
  //.subscribe { println it }

// Duplicate variables
samples.into {
  samples211
  samples301
  samples302
}
refLocation.into {
  refLocation211
  refLocation301
  refLocation302
}
expectCells211 = expectCells
expectCells301 = expectCells
expectCells302 = expectCells
forceCells211 = forceCells
forceCells301 = forceCells
forceCells302 = forceCells
chemistryParam301 = chemistryParam
chemistryParam302 = chemistryParam
feature301 = feature
feature302 = feature
