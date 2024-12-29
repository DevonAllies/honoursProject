process INDEX_BAM {

	tag "${sampleId}"
	publishDir "${params.outdir}/sorted", mode: 'symlink'
	
	input:
	tuple val(sampleId), path(sorted_bam)

	output:
	tuple val(sampleId), path(sorted_bam), path("${sorted_bam}.bai")

	script:
	"""
	samtools index ${sorted_bam}
	"""

	stub:
	"""
	touch ${sorted_bam}.bai
	"""
}
