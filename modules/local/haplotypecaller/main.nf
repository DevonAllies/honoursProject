process HAPLOTYPECALLER {
	
	tag "$sampleId"
	publishDir "${params.outdir}/haplotypecaller", mode: 'symlink'

	input:
	tuple val(sampleId), path(recal_bam), path(recal_bai)
	val reference_genome
	val reference_index
	val reference_dict

	output:
	tuple val(sampleId), path("${sampleId}.g.vcf"), path("${sampleId}.g.vcf.idx")

	script:
	"""
	echo "Debug: sampleId = $sampleId"
    echo "Debug: recal_bam = $recal_bam"
    echo "Debug: recal_bai = $recal_bai"
    echo "Debug: reference_genome = $reference_genome"

	gatk HaplotypeCaller \
	-R $reference_genome \
	-I $recal_bam \
	-O ${sampleId}.g.vcf \
	-ERC GVCF
	"""

	stub: 
	"""
	sleep 22
	touch ${sampleId}.g.vcf
	touch ${sampleId}.g.vcf.idx
	"""
}