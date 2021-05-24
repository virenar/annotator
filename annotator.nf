#!/usr/bin/env nextflow


def helpMessage() {
  // Display help message
    log.info """
    Usage:
    nextflow run annotator.nf --vcf test/test-GRCh37.vcf 
                              --resources data 
                              --reference data/fasta/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa.gz 
                              --outdir work
    
    Arguments:
        --vcf               [file] vcf file to annotate the variants. DEFAULT: test/test-GRCh37.vcf
        --resources         [path] path to vep annotation resources. DEFAULT: data
        --reference         [path] FASTA reference file. DEFAULT: data/fasta/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa.gz
        --help              [bool] You're reading it
    """.stripIndent()
}

// Show help message
if (params.help) exit 0, helpMessage()


/*
================================================================================
                         SET UP CONFIGURATION VARIABLES
================================================================================
*/

vcf_ch = Channel.fromPath(params.vcf)
resources_ch = Channel.fromPath(params.resources)
reference_ch = Channel.fromPath(params.reference)


log.info "\n\n"
log.info "ANNOTATOR - N F ~ version 0.1"
log.info "====================================="
log.info "VCF                    : ${params.vcf}"
log.info "Output directory       : ${params.outdir}"
log.info "Resources              : ${params.resources}"
log.info "Reference              : ${params.reference}"
log.info "\n"


/*
================================================================================
                         PROCESS
================================================================================
*/

process get_vep_info {
        container "ensemblorg/ensembl-vep:release_104.2"
        publishDir "$params.outdir/", mode: 'copy', pattern: "vep_annotated*.vcf", saveAs: {filename -> "${filename.split('/')[-1]}"}
        

		input:
		file vcf from vcf_ch
		file resources from resources_ch
		file reference from reference_ch

		output:
		file 'vep_annotated_variant.vcf' into vep_annotated_ch


		script:
		"""
		vep --offline --cache --dir_cache ${resources} --input_file ${vcf} --output_file vep_annotated_variant.vcf \
		    --fasta ${reference} --vcf --pick --symbol --af_gnomad --variant_class
		"""
}

process get_coverage_info {
        container "virenar/annotator_utils:0.1"
        publishDir "$params.outdir/", mode: 'copy', pattern: "annotated_*.csv", saveAs: {filename -> "${filename.split('/')[-1]}"}
        
        input:
        file vcf from vep_annotated_ch
        
        output:
        file 'annotated_variant.csv' into coverage_annoated_ch
        
        script:
        """
        python3 /tmp/tools/variant_coverage_annotator.py --input ${vcf} --output annotated_variant.csv
        """

}


/*
================================================================================
=                               F U N C T I O N S                              =
================================================================================
*/


// workflow.onComplete {
//   // Display complete message
// 	def subject = "Annotation Completed"
//   log.info "Completed at: " + workflow.complete
//   log.info "Duration    : " + workflow.duration
//   log.info "Success     : " + workflow.success
//   log.info "Exit status : " + workflow.exitStatus
//   // log.info "Error report: " + (workflow.errorReport ?: '-')
// 	if (workflow.success) {
// 		['mail', '-s', subject, '-r', "${params.email_sender}",
// 		 "${params.email_recipients}"].execute() << """
// 		Workflow Execution Completed
// 		-----------------------------------------------
// 		VCF                   : ${params.vcf}
// 		Workflow Run ID       : ${workflow.runName}
// 		Script                : annotator.nf
// 		Success               : ${workflow.success}
// 		Launch Time           : ${workflow.start.format('MM-dd-yyyy HH:mm:ss')}
// 		End Time              : ${workflow.complete.format('MM-dd-yyyy HH:mm:ss')}
// 		Duration              : ${workflow.duration}
// 		-----------------------------------------------

// 		Hope you found the output useful. Keep Smiling :-)
// 	"""
// 	}
// }

// workflow.onError {
//   // Display error message
// 	def subject = "Run Error"
//   log.info "Workflow execution stopped with the following message:"
//   log.info "  " + workflow.errorMessage
// 	if (workflow.exitStatus != 0) {
// 		['mail', '-s', subject, '-r', "${params.email_sender}",
// 		 "${params.email_recipients}"].execute() << """
// 		Workflow Execution Failed
// 		-----------------------------------------------
// 		VCF                   : ${params.vcf}
// 		Workflow Run ID       : ${workflow.runName}
// 		Script                : annotator.nf
// 		Exit Status           : ${workflow.exitStatus}
// 		Error Report          : ${workflow.errorReport ?: '-'}
// 		-----------------------------------------------

// 	"""
// 	}
// }
