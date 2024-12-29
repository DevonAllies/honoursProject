# honoursProject
This repository contains the code for my Honours project, where I developed a bioinformatics pipeline. The pipeline automates the process of aligning sequencing reads to a reference genome, identifying genetic variants, and generating a VCF file for downstream analysis.

Alignment / Variant Calling Pipeline:
A Nextflow pipeline for variant calling, from FASTQ alignment through VCF file production using BWA-MEM, SAMtools, and GATK.

Overview:
This pipeline performs the following operations:
    Read alignment using BWA-MEM
    SAM to BAM conversion and sorting using SAMtools
    Variant calling using GATK
    VCF file generation as final output

Prerequisites:
    Nextflow
    BWA
    SAMtools
    GATK
    Reference genome (must be indexed)

Usage:
    Modify the samplesheet Excel file with your input data locations:
        Column 1: Sample ID (sampleId)
        Column 2: Path to R1 (read1) FASTQ file
        Column 3: Path to R2 (read2) FASTQ file
    Update the configuration:
        Edit nextflow.config to match your computing environment
        Modify resource allocations as needed
        Update software module versions/paths
    
Run the pipeline:

    nextflow run script.nf -c nextflow.config


  Configuration:
        Edit nextflow.config to set:
            Reference genome path
            Computing resources
            Software module versions
            Output directories

            params {
                ref = '/path/to/reference/genome.fa'
                outdir = 'results'
            }

            process {
                executor = 'PBS'  // Change based on your HPC system
                queue = 'normal'
            }


  Output:
      The pipeline generates:
          Aligned BAM files
          Sorted and indexed BAM files
          VCF files with variant calls
      
