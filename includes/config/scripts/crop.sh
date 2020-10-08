#!/bin/bash

source includes/functions.sh
source includes/variables.sh

ansible-vault decrypt /opt/seedbox/variables/account.yml > /dev/null 2>&1
rm /tmp/team.txt /tmp/crop.txt > /dev/null 2>&1
i=1
sed -i '/#Debut team source/,/#Fin team source/d' /root/.config/rclone/rclone.conf > /dev/null 2>&1
sed -i '/#Debut team backup/,/#Fin team backup/d' /root/.config/rclone/rclone.conf > /dev/null 2>&1
sed -i '/share*/d' /opt/seedbox/variables/account.yml > /dev/null 2>&1
grep "team_drive" /root/.config/rclone/rclone.conf | uniq > /tmp/crop.txt
grep "team_drive" /root/.config/rclone/rclone.conf > /dev/null 2>&1

if [ $? -eq 0 ]; then
  echo -e " ${BWHITE}* Teamdrives disponibles${NC}"
  echo ""
    while read line; do
      team=$(grep -iC 6 "$line" /root/.config/rclone/rclone.conf | head -n 1 | sed "s/\[//g" | sed "s/\]//g")
      echo "$team" >> /tmp/team.txt
      echo -e "${CGREEN}   $i. $team${CEND}"
      let "i+=1"
      done < /tmp/crop.txt
    echo ""
else
  echo -e " ${BWHITE}* Aucun teamdrive/share drive détecté${NC}"
  echo ""
exit
fi

nombre=$(wc -l /tmp/team.txt | cut -d ' ' -f1)
while :
do
  read -rp $'\e[36m   Choisir le stockage principal: \e[0m' RTYPE
  if [ "$RTYPE" -le "$nombre" -a "$RTYPE" -ge "1"  ]; then
    break
  else
    echo -e " ${CRED}* /!\ erreur de saisie /!\{NC}"
    echo ""
  fi
done

## Variables
i="$RTYPE"
teamdrive_sce=$(sed -n "$i"p /tmp/team.txt)
teamdrive_dest=$(sed -n "$i"p /tmp/team.txt)
teamdrive_a=$(sed -n "$i"p /tmp/crop.txt)
teamdrive_b=$(sed -n "$i"p /tmp/crop.txt)
source=_source
dest=_backup
  
## Stockage principal
echo ""
echo -e "${CCYAN}   Source : ${CGREEN}$teamdrive_sce --> $teamdrive_a${CEND}"
id=$(sed -n "$i"p /tmp/crop.txt)
echo -e "#Debut team source\n[$teamdrive_sce$source] \ntype = drive\nscope = drive\nserver_side_across_configs = true\nservice_account_file_path = /opt/sa/\nservice_account_file = /opt/sa/1.json\n$id\n#Fin team source\n" >> /root/.config/rclone/rclone.conf
sed -i "/remote/a \ \ \ share_source: $teamdrive_sce$source" /opt/seedbox/variables/account.yml
echo ""

if [ "$nombre" -lt 2 ]; then
  exit
else
  while :
  do
  read -rp $'\e[36m   Choisir le backup: \e[0m' RTYPE
    if [ "$RTYPE" -le "$nombre" -a "$RTYPE" -ge "1"  ]; then
      break
    else
      echo -e " ${CRED}* /!\ erreur de saisie /!\{NC}"
      echo ""
    fi
  done
fi

## Variables
j="$RTYPE"
teamdrive_sce=$(sed -n "$j"p /tmp/team.txt)
teamdrive_dest=$(sed -n "$j"p /tmp/team.txt)
teamdrive_a=$(sed -n "$j"p /tmp/crop.txt)
teamdrive_b=$(sed -n "$j"p /tmp/crop.txt)
source=_source
dest=_backup

## Backup
echo ""
echo -e "${CCYAN}   Backup : ${CGREEN}$teamdrive_dest --> $teamdrive_b${CEND}"
id=$(sed -n "$j"p /tmp/crop.txt)
echo -e "#Debut team backup\n[$teamdrive_dest$dest] \ntype = drive\nscope = drive\nserver_side_across_configs = true\nservice_account_file_path = /opt/sa/\nservice_account_file = /opt/sa/1.json\n$id\n#Fin team backup\n" >> /root/.config/rclone/rclone.conf
sed -i "/remote/a \ \ \ share_dest: $teamdrive_dest$dest" /opt/seedbox/variables/account.yml
rm /tmp/team.txt /tmp/crop.txt > /dev/null 2>&1

ansible-vault encrypt /opt/seedbox/variables/account.yml > /dev/null 2>&1
echo ""
