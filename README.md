# ANNOTATOR

annotator is a tool that annotates vcf file to provide meaningful information to interpret variants. It is scalable and portable workflow. It uses nextflow and docker to orchestrate the variant annotation workflow. 

The tool annotates the variants in the VCF and outputs a csv file containing following information for all the variants

- Type of variation (SNP, INDEL, CNV, etc.) and their effect. If there are multiple effects, annotates the most deleterious possibility
- Allele frequency of variants from public data sources - gnomAD and 1000 Genomes (ExAC is deprecated and all the data from ExAC are now in gnomAD)

    For all samples in the vcf it also provides:
- Depth of sequence coverage at the site of variation
- Number of reads supporting the variant
- Percentage reads supporting the variant versus those supporting reference reads 



# Installation

### 1. Install Docker, Nextflow, clone ANNOTATOR git repo

Docker - https://docs.docker.com/get-docker/

Nextflow - https://www.nextflow.io/docs/latest/getstarted.html

ANNOTATOR - git clone https://github.com/virenar/annotator.git

### 2. Install annotation resources

#### **Manual**

Annotation resource is ~15 gb of data that needs to be downloaded. Depending on your network speed, it may take up to 10-30 mins (at 30 MB/s it took me ~15 mins).  

```
mkdir annotator/data
cd annotator/data
wget -r -nd ftp://ftp.ensembl.org/pub/release-104/variation/indexed_vep_cache/homo_sapiens_vep_104_GRCh37.tar.gz .
tar xzf homo_sapiens_vep_104_GRCh37.tar.gz
rm homo_sapiens_vep_104_GRCh37.tar.gz
```

You also need human fasta sequence. Run following to install fasta sequence. If tabix is not installed, you can install in ubuntu by `sudo apt install tabix`.
```
mkdir annotator/data/fasta
cd annotator/data/fasta
wget -r -nd ftp://ftp.ensembl.org/pub/release-75/fasta/homo_sapiens/dna/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa.gz
gzip -d Homo_sapiens.GRCh37.75.dna.primary_assembly.fa.gz
bgzip Homo_sapiens.GRCh37.75.dna.primary_assembly.fa
```





Following data and version are in the annotation resources

|Source|Version (GRCh37)|
|--|--|
|Ensembl database version| 104|
|Genome assembly| GRCh37.p13|
|Regulatory build| 1.0|
|PolyPhen| 2.2.2|
|SIFT| 5.2.2|
|dbSNP| 154|
|COSMIC| 92|
|HGMD-PUBLIC| 2020.4|
|ClinVar| 2020-12|
|1000 Genomes| Phase 3|
|NHLBI-ESP| V2-SSA137|
|gnomAD| r2.1, exomes only|
|genebuild| 2011-04|
|gencode| GENCODE 19|





## 3. Run the workflow


Trigger the nextflow app by running following command
```
nextflow run annotator.nf --help
```

Example to run test vcf
```
nextflow run annotator.nf --vcf test/test-GRCh37.vcf --resources data --reference data/fasta/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa.gz --outdir test/test-output
```

Should expect to see following output. And it typically takes < 2 mins to annotate test vcf file.

```
$ nextflow run annotator.nf
N E X T F L O W  ~  version 21.04.1
Launching `annotator.nf` [mad_lovelace] - revision: 510263e8c9



ANNOTATOR - N F ~ version 0.1
=====================================
VCF                 : test/test-GRCh37.vcf
Output directory    : test/test-output
Resources           : data
Reference           : data/fasta/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa.gz


executor >  local (2)
[82/889c47] process > get_vep_info (1)      [100%] 1 of 1 ✔
[18/5bb5ad] process > get_coverage_info (1) [100%] 1 of 1 ✔
Completed at: 23-May-2021 23:44:23
Duration    : 1m 47s
CPU hours   : (a few seconds)
Succeeded   : 2
```

### Output 

Tool output 4 files

|File|Description|
|--|--|
|**annotated_variant.csv**|contains all the annotated variants in a csv file format|
|**vep_annotated_variant.vcf**|contains all the annotated variants in a vcf file format|
|**report.html**|nextflow generated report that provides an overview of the resource utlization|
|**timeline.html**|nextflow generated report that provides an overview of the execution timeline of the processes in the workflow|