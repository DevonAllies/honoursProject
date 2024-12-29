process ALIGN {

	tag "$sampleId"
	publishDir "${params.outdir}/aligned", mode: 'symlink'

	input:
	tuple val(sampleId), path(read1), path(read2)
	path reference_genome
		
	output:
	tuple val(sampleId), path("${sampleId}.sam"), emit: sam

	script:
	def output_sam
	"""
	bwa mem \
	-R "@RG\\tID:${sampleId}\\tSM:${sampleId}\\tLB:lib1\\tPL:MGI\\tPU:unit1" \
	${reference_genome} \
	${read1} \
	${read2} \
	> "${sampleId}.sam"
	"""

	stub:
	"""
	touch "${sampleId}.sam"
	"""
}
