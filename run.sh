#!/bin/bash

data_dir=test_data/
data_name=test_data

nj=4

stage=4

if [ $stage -eq 0 ]; then
	echo prepare $data_dir...
	wav_scp=$data_dir/data_list; [[ -f "$wav_scp" ]] && rm $wav_scp
	[ ! -d $data_dir ] && echo "$0: no such directory $data_dir" && exit 1;
	data_dirs=$(find -L ${data_dir}${part} -mindepth 1 -maxdepth 1 -type d | sort -g | sort -u)
	for reader_dir in $data_dirs; do
		reader=$(basename $reader_dir)
		utts=`find -L $reader_dir/ -iname "*.wav" | sort | xargs -I% basename % .wav`
		for utt in $utts; do
			echo "${reader_dir}/${utt} ${reader_dir}/${utt}.wav">>$wav_scp
		done
	done
	echo $data_dir done!
fi

if [ $stage -eq 1 ]; then
	compute-mfcc-feats scp:$data_dir/data_list ark:- | \
		add-deltas ark:- ark:- | \
		apply-cmvn-sliding --norm-vars=false --center=true --cmn-window=300 ark:- ark:test.ark
fi


if [ $stage -eq 2 ]; then
	compute-fbank-feats \
		scp:$data_dir/data_list ark:test.ark
fi


if [ $stage -eq 3 ]; then
	compute-spectrogram-feats scp:$data_dir/data_list ark:test.ark
fi


if [ $stage -eq 4 ]; then
	python print_ark.py
fi

