process JOINTGENOTYPING {
    tag "$cohort_name"
    publishDir "${params.outdir}/jointgenotyping", mode: 'symlink'

    input:
    path(sample_map)
    val(cohort_name)
    path(reference_genome)
    path(reference_index)
    path(reference_dict)

    output:
    tuple val(cohort_name), path("${cohort_name}.vcf.gz"), path("${cohort_name}.vcf.gz.tbi")
    
    script:
    """
    gatk GenomicsDBImport \
    --sample-name-map ${sample_map} \
    --genomicsdb-workspace-path ${cohort_name}_gdb \
    --intervals chr1 \
    --intervals chr2 \
    --intervals chr3 \
    --intervals chr4 \
    --intervals chr5 \
    --intervals chr6 \
    --intervals chr7 \
    --intervals chr8 \
    --intervals chr9 \
    --intervals chr10 \
    --intervals chr11 \
    --intervals chr12 \
    --intervals chr13 \
    --intervals chr14 \
    --intervals chr15 \
    --intervals chr16 \
    --intervals chr17 \
    --intervals chr18 \
    --intervals chr19 \
    --intervals chr20 \
    --intervals chr21 \
    --intervals chr22 \
    --intervals chrX \
    --intervals chrY

    gatk GenotypeGVCFs \
    -R ${reference_genome} \
    -V gendb://${cohort_name}_gdb \
    -O ${cohort_name}.vcf.gz
    """

    stub:
    """
    sleep 40
    touch ${cohort_name}.vcf.gz ${cohort_name}.vcf.gz.tbi
    """
}