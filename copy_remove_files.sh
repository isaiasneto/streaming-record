#!/bin/bash

nowDateTime() {
	date +'%F_%X'
}

daysBeforeIso=$(date -d '-1 days 03:00 BRT' '+%Y-%m-%d')
daysBeforeEpoch=$(date -d "${daysBeforeIso} 03:00 BRT" +%s)

rootDir="/applications/record/files"
midiaDir="/tv/MIDIA"
radioDir="/radio"

echo "$(nowDateTime)" "- Script Start" # >> "/var/log/remove_files.log"

for recDeviceDir in $(ls -d ${rootDir}/*) ; do
	# echo "${recDeviceDir}"
	monthsDir=${recDeviceDir}${midiaDir}
	for monthDir in $(ls -d ${monthsDir}/*) ; do
		# echo "${monthDir}"
		for dateDir in $(ls "${monthDir}") ; do
			# echo "Current dayDir" "${dateDir}"
			dateDirEpoch=$(date -d "${dateDir} 03:00 BRT" +%s)
			if [[ ${dateDirEpoch} -le ${daysBeforeEpoch} ]] ; then
				currentMediaDir=${monthDir}/${dateDir}
				currentAudioDir=${rootDir}/${radioDir}
				currentThumbDir=${currentMediaDir//MIDIA/THUMB}
				#echo ${currentMediaDir}
				#echo ${currentThumbDir}
				# echo "${dateDir}" "is less or equal" "${daysBeforeIso}"
				echo "$(nowDateTime)" "- Copying dir" "${currentMediaDir}" "to remote server..." # >> "/var/log/remove_files.log"
				rsync -e "ssh -p 2134" -Rru --remove-source-files "${currentMediaDir}" root@serverclip.ddns.net:/disks/honda/
				echo "$(nowDateTime)" "- Copying dir" ${currentThumbDir} "to remote server..." # >> "/var/log/remove_files.log"
				rsync -e "ssh -p 2134" -Rru --remove-source-files "${currentThumbDir}" root@serverclip.ddns.net:/disks/honda/
				echo "$(nowDateTime)" "- Copying dir" ${currentAudioDir} "to remote server..." # >> "/var/log/remove_files.log"
				rsync -e "ssh -p 2134" -Rru --remove-source-files "${currentAudioDir}" root@serverclip.ddns.net:/disks/honda/

				# rm -rf ${midiaDir}/${monthDir}/${dateDir}
				# rm -rf ${radioDir}/${monthDir}/${dateDir}

				# echo "$(nowDateTime)" "- Removing" "${currentMediaDir}" # >> "/var/log/remove_files.log"
				# rm -rf "${currentMediaDir}"
				# echo "$(nowDateTime)" "- Removing" "${currentThumbDir}" # >> "/var/log/remove_files.log"
				# rm -rf "${currentThumbDir}"
				# echo "$(nowDateTime)" "- Removing" "${currentAudioDir}" # >> "/var/log/remove_files.log"
				# rm -rf "${currentAudioDir}"
			fi
		done
	done
done

echo echo "$(nowDateTime)" "- Script End" # >> "/var/log/remove_files.log"
echo >> "/var/log/remove_files.log"
