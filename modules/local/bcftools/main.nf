process BCFTOOLS_QUERY {
    tag "$cohort_name"
    publishDir "${params.outdir}/bcftools_query", mode: 'symlink'

    input:
    val cohort_name
    path vcf
    path vcf_index

    output:
    path "${cohort_name}_query_output.txt"

    script:
    """
    bcftools query -f '%CHROM\\t%POS\\t%REF\\t%ALT\\t%INFO/AF\\n' ${vcf} > ${cohort_name}_query_output.txt
    """

    stub:
    """
    touch ${cohort_name}_query_output.txt
    """
}