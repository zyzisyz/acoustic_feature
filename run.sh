#!/bin/bash

data_dir=test_data
data_name=test_data

nj=20
stage=$1


if [ $stage -eq 0 ]; then
	rm -rf ark
	for type in mfcc fbank spectrogram; do
		for file in $(find ${data_dir} -name *.${type}); do
			rm -rf $file
		done
	done
fi

if [ $stage -eq 1 ]; then
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
		done
	done

	split_scps=""
	for n in $(seq $nj); do
		split_scps="$split_scps ark/sdata/$n"
	done
	utils/split_scp.pl $wav_scp $split_scps || exit 1;
	echo $data_dir done!
fi


if [ $stage -eq 2 ]; then
	for type in mfcc fbank spectrogram; do
		rm -rf ark/$type
		mkdir -p ark/$type 

		utils/run.pl JOB=1:$nj ark/sdata/log/JOB.log \
			compute-${type}-feats scp:ark/sdata/JOB ark:ark/${type}/JOB.ark

		utils/run.pl JOB=1:$nj ark/sdata/log/JOB.log \
			python local/ark2pt.py \
			--ark_path="ark/${type}/JOB.ark" \
			--suffix="${type}" \
			--min_len=100
	done
fi


