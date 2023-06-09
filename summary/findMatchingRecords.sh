#!/bin/bash

if [ $# -lt 2 ]
then
	echo "Usage : $0 <REPORTS_DIR> <GTU_RIR_DATA_DIR> <BUT_RIR_DATA_DIR>"
	exit 1
fi

REPORTS_DIR=$1
GTU_RIR_DATA_DIR=$2
BUT_RIR_DATA_DIR=$3
## max MSE of  BUT_REVERBDB-FASTRIR-MSE
#ls $REPORTS_DIR

function findAndCopyByMSE {
   MSE_TYPE=$1 # MAX/MIN
   DATASET=$2 # BUT_REVERBDB/GTURIR
   if [ "$MSE_TYPE" = "MAX" ]
   then
      # MX
      MSE_VALUE=$(cat $REPORTS_DIR/$DATASET-FASTRIR-MSE/*/Generated_RIRs_report/*/MSE.db.txt | grep -v 'e-'| cut -d'=' -f2| sort -g | tail -1)
   elif [ "$MSE_TYPE" = "MIN" ]
   then
      # MIN
      MSE_VALUE=$(cat $REPORTS_DIR/$DATASET-FASTRIR-MSE/*/Generated_RIRs_report/*/MSE.db.txt | grep -v 'e-'| cut -d'=' -f2| sort -g | head -1)
   elif [ "$MSE_TYPE" = "AVG" ]
   then
      # AVERAGE
      COUNT=$(cat $REPORTS_DIR/$DATASET-FASTRIR-MSE/*/Generated_RIRs_report/*/MSE.db.txt | grep -v 'e-'| cut -d'=' -f2| sort -g | wc -l)
      #COUNT=$( echo "scale=2 ; $COUNT / 2" | bc)
      COUNT=$(($COUNT/2))
      MSE_VALUE=$(cat $REPORTS_DIR/$DATASET-FASTRIR-MSE/*/Generated_RIRs_report/*/MSE.db.txt | grep -v 'e-'| cut -d'=' -f2| sort -g | head -$COUNT | tail -1)
   fi 
   MSE_ROOM=$(basename $(dirname $(grep $MSE_VALUE $REPORTS_DIR/$DATASET-FASTRIR-MSE/*/Generated_RIRs_report/*/MSE.db.txt| cut -d'=' -f1| cut -d: -f1)))
   MSE_RECORD=$(grep $MSE_VALUE $REPORTS_DIR/$DATASET-FASTRIR-MSE/*/Generated_RIRs_report/*/MSE.db.txt| cut -d'=' -f1| cut -d: -f2)
   RT60=$(echo $MSE_RECORD| sed -e 's/.*RT60-//' | cut -d- -f1 | cut -c 1-3)
   MX=$(echo $MSE_RECORD| sed -e 's/.*MX-//' | cut -d- -f1 | cut -c 1-3)
   MZ=$(echo $MSE_RECORD| sed -e 's/.*MZ-//' | cut -d- -f1 | cut -c 1-3)
   SX=$(echo $MSE_RECORD| sed -e 's/.*SX-//' | cut -d- -f1 | cut -c 1-3)
   SZ=$(echo $MSE_RECORD| sed -e 's/.*SZ-//' | cut -d- -f1 | cut -c 1-3)
   if [ "$DATASET" = "BUT_REVERBDB" ]
   then
       RELATED_RECORD=$(grep "microphoneCoordinatesX=$MX" ../10.reverdb-cross-check-fast-rir/all_records.txt | grep "microphoneCoordinatesZ=$MZ" | grep "speakerCoordinatesX=$SX" | grep "speakerCoordinatesZ=$SZ" | grep "rt60=$RT60" | grep "roomId=$MSE_ROOM")

   else
       RELATED_RECORD=$(grep "microphoneCoordinatesX=$MX" ../08.fast-rir-cross-check/all_records.txt | grep "microphoneCoordinatesZ=$MZ" | grep "speakerCoordinatesX=$SX" | grep "speakerCoordinatesZ=$SZ" | grep "rt60=$RT60" | grep "roomId=$MSE_ROOM")
       #echo $RELATED_RECORD
   fi

   SPEAKER_ITERATION=$(echo $RELATED_RECORD | sed -e 's/.*speakerMotorIterationNo=//'| awk '{print $1}')
   MICROPHONE_ITERATION=$(echo $RELATED_RECORD | sed -e 's/.*microphoneMotorIterationNo=//'| awk '{print $1}')
   PHYSICAL_SPRAKER_NO=$(echo $RELATED_RECORD | sed -e 's/.*physicalSpeakerNo=//'| awk '{print $1}')
   MICROPHONE_NO=$(echo $RELATED_RECORD | sed -e 's/.*micNo=//'| awk '{print $1}')

   #echo "SPEAKER_ITERATION=$SPEAKER_ITERATION"
   #echo "MICROPHONE_ITERATION=$MICROPHONE_ITERATION"
   #echo "PHYSICAL_SPRAKER_NO=$PHYSICAL_SPRAKER_NO"
   #echo "MICROPHONE_NO=$MICROPHONE_NO"

   SUMMARY_DIR=$MSE_TYPE-MSE-$DATASET
   rm -Rf $SUMMARY_DIR
   mkdir -p $SUMMARY_DIR
   cp  $REPORTS_DIR/$DATASET-FASTRIR-MSE/*/Generated_RIRs_report/$MSE_ROOM/$MSE_RECORD*wave.png $SUMMARY_DIR/1-fastrir-mse.$MSE_ROOM.$MSE_RECORD.wave.png
   cp  $REPORTS_DIR/$DATASET-FASTRIR-MSE/*/Generated_RIRs/$MSE_RECORD*.wav $SUMMARY_DIR/1-fastrir-mse.$MSE_ROOM.$MSE_RECORD.wav
   cp  $REPORTS_DIR/$DATASET-FASTRIR-SSIM/*/Generated_RIRs_report/$MSE_ROOM/$MSE_RECORD*wave.png $SUMMARY_DIR/2-fastrir-ssim.$MSE_ROOM.$MSE_RECORD.wave.png
   cp  $REPORTS_DIR/$DATASET-FASTRIR-SSIM/*/Generated_RIRs/$MSE_RECORD*.wav $SUMMARY_DIR/2-fastrir-ssim.$MSE_ROOM.$MSE_RECORD.wav

   cp  $REPORTS_DIR/$DATASET-MESH2IR-MSE/Output.*/$MSE_ROOM/*/SPEAKER_ITERATION-$SPEAKER_ITERATION-MICROPHONE_ITERATION-$MICROPHONE_ITERATION-PHYSICAL_SPEAKER_NO-$PHYSICAL_SPRAKER_NO-MICROPHONE_NO-$MICROPHONE_NO.wave.png $SUMMARY_DIR/3-mesh2ir-mse.$MSE_ROOM.SPEAKER_ITERATION-$SPEAKER_ITERATION-MICROPHONE_ITERATION-$MICROPHONE_ITERATION-PHYSICAL_SPEAKER_NO-$PHYSICAL_SPRAKER_NO-MICROPHONE_NO-$MICROPHONE_NO.wave.png
   cp  $REPORTS_DIR/$DATASET-MESH2IR-MSE/Output.*/$MSE_ROOM/*/SPEAKER_ITERATION-$SPEAKER_ITERATION-MICROPHONE_ITERATION-$MICROPHONE_ITERATION-PHYSICAL_SPEAKER_NO-$PHYSICAL_SPRAKER_NO-MICROPHONE_NO-$MICROPHONE_NO.wav $SUMMARY_DIR/3-mesh2ir-mse.$MSE_ROOM.SPEAKER_ITERATION-$SPEAKER_ITERATION-MICROPHONE_ITERATION-$MICROPHONE_ITERATION-PHYSICAL_SPEAKER_NO-$PHYSICAL_SPRAKER_NO-MICROPHONE_NO-$MICROPHONE_NO.wav
   cp  $REPORTS_DIR/$DATASET-MESH2IR-SSIM/Output.*/$MSE_ROOM/*/SPEAKER_ITERATION-$SPEAKER_ITERATION-MICROPHONE_ITERATION-$MICROPHONE_ITERATION-PHYSICAL_SPEAKER_NO-$PHYSICAL_SPRAKER_NO-MICROPHONE_NO-$MICROPHONE_NO.wave.png $SUMMARY_DIR/4-mesh2ir-ssim.$MSE_ROOM.SPEAKER_ITERATION-$SPEAKER_ITERATION-MICROPHONE_ITERATION-$MICROPHONE_ITERATION-PHYSICAL_SPEAKER_NO-$PHYSICAL_SPRAKER_NO-MICROPHONE_NO-$MICROPHONE_NO.wave.png
   cp  $REPORTS_DIR/$DATASET-MESH2IR-SSIM/Output.*/$MSE_ROOM/*/SPEAKER_ITERATION-$SPEAKER_ITERATION-MICROPHONE_ITERATION-$MICROPHONE_ITERATION-PHYSICAL_SPEAKER_NO-$PHYSICAL_SPRAKER_NO-MICROPHONE_NO-$MICROPHONE_NO.wav $SUMMARY_DIR/4-mesh2ir-ssim.$MSE_ROOM.SPEAKER_ITERATION-$SPEAKER_ITERATION-MICROPHONE_ITERATION-$MICROPHONE_ITERATION-PHYSICAL_SPEAKER_NO-$PHYSICAL_SPRAKER_NO-MICROPHONE_NO-$MICROPHONE_NO.wav

   if [ "$DATASET" == "GTURIR" ]
   then
	   cp $GTU_RIR_DATA_DIR/$MSE_ROOM/micx*/micstep-$MICROPHONE_ITERATION-spkstep-$SPEAKER_ITERATION-spkno-$PHYSICAL_SPRAKER_NO/receivedSongSignal-$MICROPHONE_NO.wav.bz2 $SUMMARY_DIR/real.song.$MSE_ROOM-micstep-$MICROPHONE_ITERATION-spkstep-$SPEAKER_ITERATION-spkno-$PHYSICAL_SPRAKER_NO-micno-$MICROPHONE_NO.wav.bz2
	   bunzip2 $SUMMARY_DIR/real.song.$MSE_ROOM-micstep-$MICROPHONE_ITERATION-spkstep-$SPEAKER_ITERATION-spkno-$PHYSICAL_SPRAKER_NO-micno-$MICROPHONE_NO.wav.bz2
	   cp $GTU_RIR_DATA_DIR/$MSE_ROOM/micx*/micstep-$MICROPHONE_ITERATION-spkstep-$SPEAKER_ITERATION-spkno-$PHYSICAL_SPRAKER_NO/receivedEssSignal-$MICROPHONE_NO.wav.ir.wav $SUMMARY_DIR/real.rir.$MSE_ROOM-micstep-$MICROPHONE_ITERATION-spkstep-$SPEAKER_ITERATION-spkno-$PHYSICAL_SPRAKER_NO-micno-$MICROPHONE_NO.wav
   else
	   cp $BUT_RIR_DATA_DIR/$MSE_ROOM/MicID*/SpkID0$PHYSICAL_SPRAKER_NO*/$MICROPHONE_NO/RIR/IR_sweep_15s_45Hzto22kHz_FS16kHz.v00.wav $SUMMARY_DIR/real.rir.$MSE_ROOM-micstep-$MICROPHONE_ITERATION-spkstep-$SPEAKER_ITERATION-spkno-$PHYSICAL_SPRAKER_NO-micno-$MICROPHONE_NO.wav
   fi
   python3 summary_generator.py $SUMMARY_DIR $SUMMARY_DIR/1-fastrir-mse.$MSE_ROOM.$MSE_RECORD.wave.png $SUMMARY_DIR/2-fastrir-ssim.$MSE_ROOM.$MSE_RECORD.wave.png $SUMMARY_DIR/3-mesh2ir-mse.$MSE_ROOM.SPEAKER_ITERATION-$SPEAKER_ITERATION-MICROPHONE_ITERATION-$MICROPHONE_ITERATION-PHYSICAL_SPEAKER_NO-$PHYSICAL_SPRAKER_NO-MICROPHONE_NO-$MICROPHONE_NO.wave.png $SUMMARY_DIR/4-mesh2ir-ssim.$MSE_ROOM.SPEAKER_ITERATION-$SPEAKER_ITERATION-MICROPHONE_ITERATION-$MICROPHONE_ITERATION-PHYSICAL_SPEAKER_NO-$PHYSICAL_SPRAKER_NO-MICROPHONE_NO-$MICROPHONE_NO.wave.png
}



findAndCopyByMSE MAX BUT_REVERBDB
findAndCopyByMSE MIN BUT_REVERBDB
findAndCopyByMSE AVG BUT_REVERBDB
findAndCopyByMSE MAX GTURIR
findAndCopyByMSE MIN GTURIR
findAndCopyByMSE AVG GTURIR
