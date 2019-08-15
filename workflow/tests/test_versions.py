#!/usr/bin/env python3
#test_versions.py
#*
#* --------------------------------------------------------------------------
#* Licensed under MIT (https://git.biohpc.swmed.edu/BICF/Astrocyte/cellranger_count/blob/develop/LICENSE)
#* --------------------------------------------------------------------------
#*

import pytest
import pandas as pd
from io import StringIO
import os

test_output_path = os.path.dirname(os.path.abspath(__file__)) + \
                '/../output/misc/versions/run/'

@pytest.mark.count211
def test_count211_versions():
    assert os.path.exists(os.path.join(test_output_path, 'versions_mqc.yaml'))
    assert os.path.exists(os.path.join(test_output_path, 'references_mqc.yaml'))

@pytest.mark.count301
def test_count301_versions():
    assert os.path.exists(os.path.join(test_output_path, 'versions_mqc.yaml'))
    assert os.path.exists(os.path.join(test_output_path, 'references_mqc.yaml'))

@pytest.mark.count302
def test_count302_versions():
    assert os.path.exists(os.path.join(test_output_path, 'versions_mqc.yaml'))
    assert os.path.exists(os.path.join(test_output_path, 'references_mqc.yaml'))

@pytest.mark.count310
def test_count310_versions():
    assert os.path.exists(os.path.join(test_output_path, 'versions_mqc.yaml'))
    assert os.path.exists(os.path.join(test_output_path, 'references_mqc.yaml'))