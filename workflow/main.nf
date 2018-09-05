#!/usr/bin/env nextflow

// Path to an input file, or a pattern for multiple inputs
// Note - $baseDir is the location of this workflow file main.nf

// Define Input variables
params.fastq = "$baseDir/../test_data/*.fastq.gz"
params.designFile = "$baseDir/../test_data/design.csv"
params.genome = 'GRCh38'
params.genomes = []
params.refIndex = params.genomes[ params.genome ].ref
params.expectCells = 10000
params.forceCells = 0

// Check inputs
if( params.refIndex ){
  refLocation = Channel
    .fromPath(params.refIndex)
    .ifEmpty { exit 1, "referene not found: ${params.refIndex}" }
} else {
  exit 1, "No reference genome specified. ${params.genome}"
}

// Define List of Files
fastqList = Channel
  .fromPath(params.fastq)
  .flatten()
  .map { file -> [ file.getFileName().toString(), file.toString() ].join("\t") }
  .collectFile(name: 'fileList.tsv', newLine: true)

// Define regular variables
expectCells = params.expectCells
forceCells = params.forceCells

process checkDesignFile {

  publishDir "$baseDir/output", mode: 'copy'

  input:

  params.designFile
  file fastqList

  output:

  file("design.csv") into designPaths

  script:

  """
  module load python/3.6.1-2-anaconda
  python3 $baseDir/scripts/check_design.py -d $params.designFile -f $fastqList
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
  """
  module load cellranger/2.1.1
  """
  if (forceCells == 0){
    """
    cellranger count --id="$sample" --transcriptome="$ref" --fastqs=. --sample="$sample" --expect-cells=$expectCells
    """
  } else {
    """
    cellranger count --id="$sample" --transcriptome="$ref" --fastqs=. --sample="$sample" --force-cells=$forceCells
    """
  }
}
