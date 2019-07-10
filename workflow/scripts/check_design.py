#!/usr/bin/env python3

'''Check if design file is correctly formatted and matches files list.'''

import argparse
import logging
import pandas as pd

EPILOG = '''
For more details:
        %(prog)s --help
'''

# SETTINGS

logger = logging.getLogger(__name__)
logger.addHandler(logging.NullHandler())
logger.propagate = False
logger.setLevel(logging.INFO)


def get_args():
    '''Define arguments.'''

    parser = argparse.ArgumentParser(
        description=__doc__, epilog=EPILOG,
        formatter_class=argparse.RawDescriptionHelpFormatter)

    parser.add_argument('-d', '--design',
                        help="The design file to run QC (tsv format).",
                        required=True )

    parser.add_argument('-f', '--fastq',
                        help="File with list of fastq files (tsv format).",
                        required=True )

    args = parser.parse_args()
    return args


def check_design_headers(design):
    '''Check if design file contains correct headers.'''

    # Default headers
    design_template = [
        'Sample',
	'fastq_R1',
	'fastq_R2',
        ]

    design_headers = list(design.columns.values)

    # Check if headers
    logger.info("Running header check.")

    missing_headers = set(design_template) - set(design_headers)

    if len(missing_headers) > 0:
        logger.error('Missing column headers: %s', list(missing_headers))
        raise Exception("Missing column headers: %s" % list(missing_headers))
    
    return design

def check_files(design, fastq):
    '''Check if design file has the files found.'''

    logger.info("Running file check.")

    files = list(design['fastq_R1']) + list(design['fastq_R2'])

    files_found = fastq['name']

    missing_files = set(files) - set(files_found)

    if len(missing_files) > 0:
        logger.error('Missing files from design file: %s', list(missing_files))
        raise Exception("Missing files from design file: %s" %
            list(missing_files))
    else:
        file_dict = fastq.set_index('name').T.to_dict()
    
    design['fastq_R1'] = design['fastq_R1'].apply(lambda x: file_dict[x]['path'])
    design['fastq_R2'] = design['fastq_R2'].apply(lambda x: file_dict[x]['path'])

    return design


def main():
    args = get_args()
    design = args.design

    # Create a file handler
    handler = logging.FileHandler('design.log')
    logger.addHandler(handler)

    # Read files as dataframes
    design_df = pd.read_csv(args.design, sep=',')
    fastq_df = pd.read_csv(args.fastq, sep='\t', names=['name', 'path'])

    # Check design file
    new_design_df = check_design_headers(design_df)
    check_files(design_df, fastq_df)

    new_design_df.to_csv('design.checked.csv', header=True, sep=',', index=False)

if __name__ == '__main__':
    main()
