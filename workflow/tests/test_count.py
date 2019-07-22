#!/usr/bin/env python3

import pytest
import pandas as pd
from io import StringIO
import os

@pytest.mark.count211
def test_count211():
    test_output_path = os.path.dirname(os.path.abspath(__file__)) + \
                    '/../output/count211/'

@pytest.mark.count301
def test_count301():
    test_output_path = os.path.dirname(os.path.abspath(__file__)) + \
                    '/../output/count301/'


@pytest.mark.count302
def test_count302():
    test_output_path = os.path.dirname(os.path.abspath(__file__)) + \
                    '/../output/count302/'
