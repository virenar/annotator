from cyvcf2 import VCF
import os
import numpy as np
import pandas as pd
import argparse


parser = argparse.ArgumentParser(
            description="Obtain variant coverage data and parse vep info from user provided vcf file generated from vep tool")

parser.add_argument("-i", "--input", help="user specified VCF file generated from vep tool",
                    type=str, required=True)
parser.add_argument("-o", "--output", help="output file name",
                    type=str, required=True)



def _get_vcf_header(path, string):
    """Get particular line from VCF that starts with a specific string.
    
    Args:
        path (str): A path to the vcf file.
        string   (str): A string for which to grep a line
    
    Retruns:
        Line in the vcf file.
    """
    with open(path, 'r') as f:
        for l in f:
            if l.startswith(string):
                header = l.rstrip().split('\t')
                break
    return header


def _get_sample_info(path):
    """Get all sample names from the vcf.
    Args:
        path (str): A path to the vcf file.
        
    Returns:
        Names of all the samples in the vcf file.
        
    """
    header = _get_vcf_header(path, '#CHROM')
    samples = header[9:]
    return samples

def _get_vep_info(path):
    """Get vep info names.
    Args:
        path (str): A path to the vcf file.
        
    Returns:
        All VEP info indentifiers.
        
    """
    header = _get_vcf_header(path, "##INFO=<ID=CSQ,Number=.")
    vep_info = tuple(header[0].split(',')[-1].split('Format: ')[-1].split('">')[0].split('|'))
    return vep_info

def get_coverage_info(path):
    """Get coverage metrics and percent alternate variants for all the samples.
    
    Args:
        path (str): A path to the vcf file.
    
    Returns:
        Pandas Dataframe containing all of the variants sequencing coverage metrics 
        and percent alternate variants for all the samples included in the vcf.
        
    """
    samples = _get_sample_info(path)
    cyvcf = VCF(path, strict_gt=True)
    tup = []
    header_coverage = list(map(str, np.hstack(('Key', 'variant_type', 
                        ['{}_depth'.format(s) for s in samples], 
                        ['{}_alt-reads'.format(s) for s in samples], 
                        ['{}_ref-reads'.format(s) for s in samples], 
                        ['{}_pct-alt-var'.format(s) for s in samples]))))
    header_vep = _get_vep_info(path)
    header = tuple(header_coverage)+header_vep+tuple(['Variant record'])
    for v in cyvcf:
        key = "{}_{}_{}/{}".format(v.CHROM,v.POS,v.REF,"/".join(v.ALT))
        variant_record = tuple([str(v)])
        alt_type = v.INFO['TYPE']
        depth = v.gt_depths
        alt_reads = v.gt_alt_depths
        ref_reads = v.gt_ref_depths
        pct_alt_var = np.round(100*(v.gt_alt_depths/v.gt_depths),decimals=2)
        vep_info = tuple(str(v).split('\t')[7].split(';')[-1].split('|'))
        coverage_info = tuple(list(map(str,(np.hstack((key, alt_type, depth, alt_reads, ref_reads, pct_alt_var))))))
        tup.append(coverage_info+vep_info+variant_record)
    coverage_info = pd.DataFrame(tup)
    coverage_info.columns = header
    return coverage_info
    
    
if __name__ == '__main__':
    args = parser.parse_args()
    
    df = get_coverage_info(os.path.abspath(args.input))
    
    df.to_csv(os.path.abspath(args.output), index=False)