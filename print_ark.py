#!/usr/bin/env python
# coding=utf-8

import kaldi_io
import numpy as np


for key,mat in kaldi_io.read_mat_ark("test.ark"):
    input(key)
    input(mat[-1])
    input(mat.shape)


