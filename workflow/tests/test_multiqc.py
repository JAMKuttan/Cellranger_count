#!/usr/bin/env python3

import pytest
import pandas as pd
from io import StringIO
import os

test_output_path = os.path.dirname(os.path.abspath(__file__)) + \
                '/../output/multiqc/run/'

@pytest.mark.count211
def test_count211_multiqc():
    assert os.path.exists(os.path.join(test_output_path, 'multiqc_report.html'))

@pytest.mark.count301
def test_count301_multiqc():
    assert os.path.exists(os.path.join(test_output_path, 'multiqc_report.html'))

@pytest.mark.count302
def test_count302_multiqc():
    assert os.path.exists(os.path.join(test_output_path, 'multiqc_report.html'))

@pytest.mark.count310
def test_count310_multiqc():
    assert os.path.exists(os.path.join(test_output_path, 'multiqc_report.html'))
