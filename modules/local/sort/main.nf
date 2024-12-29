process SORT_BAM {

	tag "${sampleId}"
	publishDir "${params.outdir}/sorted", mode: 'symlink'

	input:
	tuple val(sampleId), path(bam)

	output:
	tuple val(sampleId), path("${sampleId}*.sorted.bam"), emit: sorted_bam

	script:
	def output_sorted_bam = bam.simpleName + ".sorted.bam"
	"""
	samtools sort -o ${output_sorted_bam} ${bam}
	"""

	stub:
	def stub_sorted_bam	= bam.simpleName + ".sorted.bam"
	"""
	touch ${stub_sorted_bam}
	"""
}
