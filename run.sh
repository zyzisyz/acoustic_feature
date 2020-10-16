#!/bin/bash

data_dir=test_data
data_name=test_data

nj=4
stage=0

if [ $stage -le 0 ]; then
	echo prepare $data_dir...
	rm -rf ark/sdata
	mkdir -p ark/sdata

	# make data list
	wav_scp=ark/data_list; [[ -f "$wav_scp" ]] && rm $wav_scp
	[ ! -d $data_dir ] && echo "$0: no such directory $data_dir" && exit 1;
	data_dirs=$(find -L ${data_dir}${part} -mindepth 1 -maxdepth 1 -type d | sort -g | sort -u)
	for reader_dir in $data_dirs; do
		reader=$(basename $reader_dir)
		utts=`find -L $reader_dir/ -iname "*.wav" | sort | xargs -I% basename % .wav`
		for utt in $utts; do
			echo "${reader_dir}/${utt} ${reader_dir}/${utt}.wav">>$wav_scp
			echo "${reader_dir}/${utt} ${reader_dir}/${utt}.wav"
		done
	done

	split_scps=""
	for n in $(seq $nj); do
		split_scps="$split_scps ark/sdata/$n"
	done
	utils/split_scp.pl $wav_scp $split_scps || exit 1;
	echo $data_dir done!
fi


if [ $stage -le 1 ]; then
	rm -rf ark/mfcc
	mkdir -p ark/mfcc 
	utils/run.pl JOB=1:$nj ark/sdata/log/JOB.log \
		compute-mfcc-feats scp:ark/sdata/JOB ark:ark/mfcc/JOB.ark
fi


if [ $stage -le 2 ]; then
	rm -rf ark/fbank
	mkdir -p ark/fbank 
	utils/run.pl JOB=1:$nj ark/sdata/log/JOB.log \
		compute-fbank-feats scp:ark/sdata/JOB ark:ark/fbank/JOB.ark
fi


if [ $stage -le 3 ]; then
	rm -rf ark/spectrogram
	mkdir -p ark/spectrogram 
	utils/run.pl JOB=1:$nj ark/sdata/log/JOB.log \
		compute-spectrogram-feats scp:ark/sdata/JOB ark:ark/spectrogram/JOB.ark
fi


if [ $stage -eq 4 ]; then
	python print_ark.py
fi

