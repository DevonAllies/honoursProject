process VARIANT_FILTERING {

    tag "$cohort_name"
    publishDir "${params.outdir}/vqsr", mode: 'copy'

    input:
    tuple val(cohort_name), path(vcf), path(vcf_index)
    path reference_genome
    path reference_index
    path reference_dict
    path dbsnp
    path mills
    path hapmap
    path omni
    path dbsnp_index
    path hapmap_index
    path omni_index
    path mills_index
    
    output:
    path("${cohort_name}_vqsr_filtered.vcf.gz")
    path("${cohort_name}_vqsr_filtered.vcf.gz.tbi")

    script:
    """
    # Create output directory
    mkdir -p ${cohort_name}

    # Seperate SNP's and INDELs
    gatk SelectVariants -V ${vcf} -select-type SNP -O snps.vcf.gz
    gatk SelectVariants -V ${vcf} -select-type INDEL -O indels.vcf.gz

    # Run VQSR for SNPs
    gatk VariantRecalibrator \
    -R ${reference_genome} \
    -V snps.vcf.gz \
    --resource:hapmap,known=false,training=true,truth=true,prior=15.0 ${hapmap} \
    --resource:omni,known=false,training=true,truth=true,prior=12.0 ${omni} \
    --resource:dbsnp,known=true,training=false,truth=false,prior=2.0 ${dbsnp} \
    -an QD -an MQ -an MQRankSum -an ReadPosRankSum -an FS -an SOR \
    -mode SNP -O snps.recal --tranches-file snps.tranches

    # Apply VQSR to SNPs
    gatk ApplyVQSR \
    -R ${reference_genome} \
    -V snps.vcf.gz \
    -recal-file snps.recal \
    --tranches-file snps.tranches \
    -mode SNP \
    --truth-sensitivity-filter-level 99.0 \
    -O snps.filtered.vcf.gz

    # Run VQSR for INDELS
    gatk VariantRecalibrator \
    -R ${reference_genome} \
    -V indels.vcf.gz \
    --resource:mills,known=false,training=true,truth=true,prior=12.0 ${mills} \
    --resource:dbsnp,known=true,training=false,truth=false,prior=2.0 ${dbsnp} \
    -an QD -an MQRankSum -an ReadPosRankSum -an FS -an SOR \
    -mode INDEL -O indels.recal --tranches-file indels.tranches

    # Apply VQSR to INDELS
    gatk ApplyVQSR \
    -R ${reference_genome} \
    -V indels.vcf.gz \
    --recal-file indels.recal \
    --tranches-file indels.tranches \
    -mode INDEL \
    --truth-sensitivity-filter-level 99.0 \
    -O indels.filtered.vcf.gz

    # Merge VCF's
    gatk MergeVcfs \
    -I snps.filtered.vcf.gz \
    -I indels.filtered.vcf.gz \
    -O ${cohort_name}_vqsr_filtered.vcf.gz

    # Index the final VCF
    gatk IndexFeatureFile \
    -I ${cohort_name}_vqsr_filtered.vcf.gz
    """

    stub:
    """
    sleep 30
    touch ${cohort_name}_vqsr_filtered.vcf.gz
    touch ${cohort_name}_vqsr_filtered.vcf.gz.tbi
    """
}