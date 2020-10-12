#!/usr/bin/env python
# coding=utf-8

import kaldi_io
import numpy as np


for key,mat in kaldi_io.read_mat_ark("test.ark"):
    #print(mat[-1])
    print(mat[-1])
    print(mat.shape)


