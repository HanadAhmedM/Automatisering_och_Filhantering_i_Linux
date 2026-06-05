#!/bin/bash

# Kontrollera om katalogen logs_backup finns
if [ ! -d "logs_backup" ]; then
    mkdir logs_backup
    echo "Katalogen logs_backup skapades."
fi

# Skapa 5 loggfiler
for i in {1..5}
do
    touch "logfile_${i}.log"
done

echo "5 loggfiler skapades."

# Kopiera alla .log-filer till logs_backup
cp *.log logs_backup/

# Bekräftelsemeddelande
echo "Alla loggfiler har kopierats till logs_backup."
echo "Skriptet är klart."