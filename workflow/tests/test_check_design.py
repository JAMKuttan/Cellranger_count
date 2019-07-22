#!/usr/bin/env python3

import pytest
import pandas as pd
from io import StringIO
import os

test_output_path = os.path.dirname(os.path.abspath(__file__)) + \
		'/../output/misc/checkDesignFile/run/'

@pytest.mark.count211
def test_count211_design():
    assert os.path.exists(os.path.join(test_output_path, 'design.checked.csv'))

@pytest.mark.count302
def test_count302_design():
    assert os.path.exists(os.path.join(test_output_path, 'design.checked.csv'))
