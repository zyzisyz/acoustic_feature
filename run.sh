#!/bin/bash


compute-fbank-feats \
	--config="conf/fbank.conf" \
	scp:wav.scp ark,t:test.ark

python print_ark.py

