#!/bin/bash

data_dir=test_data
data_name=test_data

nj=20
stage=$1
type=mfcc

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
	for wav in `find -L ${data_dir} -name "*.wav"`; do
		echo ${wav%.*} $wav >> $wav_scp
	done

	split_scps=""
	for n in $(seq $nj); do
		split_scps="$split_scps ark/sdata/$n"
	done
	utils/split_scp.pl $wav_scp $split_scps || exit 1;
	echo $data_dir done!
fi


if [ $stage -eq 2 ]; then
	echo compute $type
	rm -rf ark/$type
	mkdir -p ark/$type 

	utils/run.pl JOB=1:$nj ark/sdata/log/JOB.log \
		compute-${type}-feats --config="conf/${type}.conf" scp:ark/sdata/JOB ark:- \| \
		apply-cmvn-sliding --norm-vars=false --center=true --cmn-window=300 ark:- ark:ark/${type}/JOB.ark \
		|| exit 1;

	echo make $type
	utils/run.pl JOB=1:$nj ark/sdata/log/JOB.log \
		python local/ark2pt.py \
		--ark_path="ark/${type}/JOB.ark" \
		--suffix="${type}" \
		--min_len=100
fi


