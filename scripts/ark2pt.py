#!/usr/bin/env python
# coding=utf-8

import kaldi_io
import torch
import numpy as np
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--ark_path', type=str, default="", help='')
parser.add_argument('--suffix', type=str, default="", help='')
args = parser.parse_args()

for key, mat in kaldi_io.read_mat_ark(args.ark_path):
	path = key + ".{}".format(args.suffix)
	torch.save(mat, path)

