process SAM_TO_BAM {

	tag "${sampleId}"
	publishDir "${params.outdir}/bam", mode: 'symlink'

	input:
	tuple val(sampleId), path(sam)

	output:
	tuple val(sampleId), path("${sampleId}*.bam"), emit: bam

	script:
	def output_bam	= sam.baseName + ".bam"
	"""
	samtools view -bS ${sam} > ${output_bam}
	"""

	stub:
	def stub_output_bam	= sam.baseName + ".bam"
	"""
	touch ${stub_output_bam}
	"""
}
