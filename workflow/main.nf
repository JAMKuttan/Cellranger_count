#!/usr/bin/env nextflow

// Path to an input file, or a pattern for multiple inputs
// Note - $baseDir is the location of this workflow file main.nf

// Define Input variables
params.fastq = "$baseDir/../test_data/*.fastq.gz"
params.designFile = "$baseDir/../test_data/design.csv"
params.genome = 'GRCh38-3.0.0'
params.expectCells = 10000
params.forceCells = 0
params.kitVersion = 'three'
params.version = '3.0.2'
params.astrocyte = false
params.outDir = "$baseDir/output"

// Assign variables if astrocyte
if (params.astrocyte) {
  print("Running under astrocyte")
  params.genomeLocation = '/project/apps_database/cellranger/refdata-cellranger-'
  if (params.kitVersion == "one") {
    params.chemistryParam ='SC3Pv1'
  } else if (params.kitVersion == "two") {
    params.chemistryParam ='SC3Pv2'
  } else if (params.kitVersion == "three") {
    params.chemistryParam ='SC3Pv3'
  } else {
    params.chemistryParam = 'auto'
  }
} else {
  params.genomes = []
  params.genomeLocation = params.genome ? params.genomes[ params.genome ].loc ?: false : false
  params.chemistry = []
  params.chemistryParam = params.kitVersion ? params.chemistry[ params.kitVersion ].param ?: false : false
}
params.genomeLocationFull = params.genomeLocation+params.genome

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
  .fromPath(params.genomeLocationFull)
  .ifEmpty { exit 1, "referene not found: ${params.genome}" }
expectCells = params.expectCells
forceCells = params.forceCells
chemistryParam = params.chemistryParam
version = params.version
outDir = params.outDir

process checkDesignFile {

  publishDir "$outDir/${task.process}", mode: 'copy'

  input:

  file designLocation
  file fastqList

  output:

  file("design.checked.csv") into designPaths

  script:

  """
  hostname
  ulimit -a
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

process count211 {
  queue '128GB,256GB,256GBv1,384GB'
  tag "$sample"

  publishDir "$outDir/${task.process}", mode: 'copy'

  input:

  set sample, file("${sample}_S1_L00?_R1_001.fastq.gz"), file("${sample}_S1_L00?_R2_001.fastq.gz") from samples211
  file ref from refLocation211.first()
  expectCells211
  forceCells211

  output:

  file("**/outs/**") into outPaths211

  when:
  version == '2.1.1'

  script:
  if (forceCells211 == 0){
    """
	  hostname
    ulimit -a
    module load cellranger/2.1.1
    cellranger count --id="$sample" --transcriptome="./$ref" --fastqs=. --sample="$sample" --expect-cells=$expectCells211
    """
  } else {
    """
	  hostname
    ulimit -a
    module load cellranger/2.1.1
    cellranger count --id="$sample" --transcriptome="./$ref" --fastqs=. --sample="$sample" --force-cells=$forceCells211
    """
  }
}

process count301 {
  queue '128GB,256GB,256GBv1,384GB'
  tag "$sample"

  publishDir "$outDir/${task.process}", mode: 'copy'

  input:

  set sample, file("${sample}_S1_L00?_R1_001.fastq.gz"), file("${sample}_S1_L00?_R2_001.fastq.gz") from samples301
  file ref from refLocation301.first()
  expectCells301
  forceCells301
  chemistryParam301

  output:

  file("**/outs/**") into outPaths301

  when:
  version == '3.0.1'

  script:
  if (forceCells301 == 0){
    """
	  hostname
    ulimit -a
    module load cellranger/3.0.1
    cellranger count --id="$sample" --transcriptome="./$ref" --fastqs=. --sample="$sample" --expect-cells=$expectCells301 --chemistry="$chemistryParam301"
    """
  } else {
    """
	  hostname
    ulimit -a
    module load cellranger/3.0.1
    cellranger count --id="$sample" --transcriptome="./$ref" --fastqs=. --sample="$sample" --force-cells=$forceCells301 --chemistry="$chemistryParam301"
    """
  }
}

process count302 {
  queue '128GB,256GB,256GBv1,384GB'
  tag "$sample"

  publishDir "$outDir/${task.process}", mode: 'copy'

  input:

  set sample, file("${sample}_S?_L001_R1_001.fastq.gz"), file("${sample}_S?_L001_R2_001.fastq.gz") from samples302
  file ref from refLocation302.first()
  expectCells302
  forceCells302
  chemistryParam302

  output:

  file("**/outs/**") into outPaths302

  when:
  version == '3.0.2'

  script:
  if (forceCells302 == 0){
    """
	  hostname
    ulimit -a
    module load cellranger/3.0.2
    cellranger count --id="$sample" --transcriptome="./$ref" --fastqs=. --sample="$sample" --expect-cells=$expectCells302 --chemistry="$chemistryParam302"
    """
  } else {
    """
	  hostname
    ulimit -a
    module load cellranger/3.0.2
    cellranger count --id="$sample" --transcriptome="./$ref" --fastqs=. --sample="$sample" --force-cells=$forceCells302 --chemistry="$chemistryParam302"
    """
  }
}
