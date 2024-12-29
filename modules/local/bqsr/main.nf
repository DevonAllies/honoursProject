process BQSR {
    tag "$sampleId"
    publishDir "${params.outdir}/bqsr", mode: 'symlink'

    input:
    tuple val(sampleId), path(bam), path(bai)
    path(reference_genome)
    path(reference_index)
    path(reference_dict)
    path(dbsnp)
    path(dbsnp_index)

    output:
    tuple val(sampleId), path("${sampleId}.recal.bam"), path("${sampleId}.recal.bai")

    script:
    """
    gatk BaseRecalibrator \
    -R $reference_genome \
    -I $bam \
    --known-sites ${dbsnp} \
    -O ${sampleId}.recal_data.table

    gatk ApplyBQSR \
    -R $reference_genome \
    -I $bam \
    --bqsr-recal-file ${sampleId}.recal_data.table \
    -O ${sampleId}.recal.bam

    gatk BuildBamIndex \
    -I ${sampleId}.recal.bam
    """
    
    stub:
    """
    sleep 32
    touch ${sampleId}.recal.bam
    touch ${sampleId}.recal.bai
    """
}

