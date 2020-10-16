#!/usr/bin/env python
# coding=utf-8

import kaldi_io
import torch
import numpy as np
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--ark_path', type=str, default="", help='')
parser.add_argument('--suffix', type=str, default="", help='')
parser.add_argument('--min_len', type=int, default=100, help='')
args = parser.parse_args()

for key, mat in kaldi_io.read_mat_ark(args.ark_path):
	path = key + ".{}".format(args.suffix)
	if mat.shape[0] >= args.min_len:
		torch.save(mat, path)

