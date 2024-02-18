#!/bin/bash

# Mantenha o dispositivo de origem como sr0
CDROM_DEVICE="/dev/sr0"
CDROM_MOUNT=$(lsblk $CDROM_DEVICE --output MOUNTPOINT -n | head -n1)

# Detecte o dispositivo de destino montado
DEST_DEVICE=$(df | grep '/dev/sdc1' | awk '{print $1}')

# Defina o diretório de origem
DEST_DIR=$(df | grep -m 1 "$DEST_DEVICE" | awk '{print $6}')
echo destino $DEST_DIR

# Verifique se o CD-ROM está montado
if [ -z "$CDROM_MOUNT" ]; then
    echo "Nenhum CD-ROM montado encontrado em /dev/sr0"
    exit 1
fi

# Use ddrescue para criar uma imagem ISO do CD-ROM
ISO_IMAGE="/tmp/cdrom_image.iso"
LOG_FILE="/tmp/ddrescue.log"
echo sudo ddrescue -n -b2048 $CDROM_DEVICE $ISO_IMAGE $LOG_FILE
sudo ddrescue -n -b2048 $CDROM_DEVICE $ISO_IMAGE $LOG_FILE 

# Monte a imagem ISO
MOUNT_POINT="/mnt/cdrom_image"
sudo mkdir -p $MOUNT_POINT
echo sudo mount -o loop $ISO_IMAGE $MOUNT_POINT
sudo mount -o loop $ISO_IMAGE $MOUNT_POINT

# Use rsync para sincronizar os arquivos
rsync -av --progress $MOUNT_POINT/ $DEST_DIR

# Desmonte a imagem ISO
sudo umount $MOUNT_POINT

# Delete a imagem ISO
sudo rm $ISO_IMAGE $LOG_FILE

# Imprima uma mensagem quando a sincronização estiver concluída
echo "Sincronização concluída!"

eject
