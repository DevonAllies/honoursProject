#!/usr/bin/env nextflow

// Channel creation

samples_ch = Channel
    .fromPath(params.csv)
    .splitCsv(header:true)
    .map { row -> tuple(row.sampleId, file(row.read1), file(row.read2)) }

samples_ch.view { "Sample: $it" }

reference_ch        = params.reference_genome
reference_index_ch  = params.reference_index
reference_dict_ch   = params.reference_dict
dbsnp_ch            = params.dbsnp
dbsnp_index_ch      = params.dbsnp_index
mills_ch            = params.mills
mills_index_ch      = params.mills_index
hapmap_ch           = params.hapmap
hapmap_index_ch     = params.hapmap_index
omni_ch             = params.omni
omni_index_ch       = params.omni_index

// Import modules

include { ALIGN }               from "${params.projectDir}/modules/local/align/main.nf"
include { SAM_TO_BAM }          from "${params.projectDir}/modules/local/convert/main.nf"
include { SORT_BAM }            from "${params.projectDir}/modules/local/sort/main.nf"
include { INDEX_BAM }           from "${params.projectDir}/modules/local/index/main.nf"
include { BQSR }                from "${params.projectDir}/modules/local/bqsr/main.nf"
include { HAPLOTYPECALLER }     from "${params.projectDir}/modules/local/haplotypecaller/main.nf"
include { JOINTGENOTYPING }     from "${params.projectDir}/modules/local/jointgenotyping/main.nf"
include { VARIANT_FILTERING }   from "${params.projectDir}/modules/local/vqsr/main.nf"
// include { BCFTOOLS_QUERY }      from "${params.projectDir}/modules/local/bcftools/main.nf"

// Main workflows

workflow {
	// Alignment
	aligned_sams = ALIGN(samples_ch, reference_ch)
	aligned_bams = SAM_TO_BAM(aligned_sams)
	sorted_bams = SORT_BAM(aligned_bams)
	indexed_bams = INDEX_BAM(sorted_bams.sorted_bam)

    // BQSR
	 bqsr_bams = BQSR(
            indexed_bams,
            reference_ch,
            reference_index_ch,
            reference_dict_ch,
            dbsnp_ch,
            dbsnp_index_ch
     )    

     bqsr_bams.view { "BQSR output: $it" }

    // Variant Calling
     gvcfs = HAPLOTYPECALLER(
        bqsr_bams,
        reference_ch,
        reference_index_ch,
        reference_dict_ch
     )    

    // Create a sample map for joint genotyping
    sample_map = gvcfs
        .map { sampleId, gvcf, idx -> "${sampleId}\t${gvcf}\t${idx}\n" }
        .collectFile(name: "${params.cohort_name}_map.tsv")
    
    joint_called_vcf = JOINTGENOTYPING(
        sample_map,
        params.cohort_name,
        reference_ch,
        reference_index_ch,
        reference_dict_ch
    )
    
    // Variant Filtering
    VARIANT_FILTERING(
        joint_called_vcf,
        reference_ch,
        reference_index_ch,
        reference_dict_ch,
        dbsnp_ch,
        mills_ch,
        hapmap_ch,
        omni_ch,
        dbsnp_index_ch,
        hapmap_index_ch,
        omni_index_ch,
        mills_index_ch
    )
     /*
    // BCFtools for exctraction
    BCFTOOLS_QUERY(params.cohort_name, file("${params.outdir}/vqsr/${params.cohort_name}_vqsr_filtered.vcf.gz"),
        file("${params.outdir}/vqsr/${params.cohort_name}_vqsr_filtered.vcf.gz.tbi")
    )
    */
}
