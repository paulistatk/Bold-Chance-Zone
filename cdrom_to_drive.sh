#!/bin/bash

lsblk

# Verifique se os parâmetros de origem e destino foram fornecidos
if [ "$#" -ne 2 ]; then
    echo "Por favor, forneça dois parâmetros: a origem e o destino, conforme saida do lsblk acima."
    exit 1
fi

# Mantenha o dispositivo de origem como sr0
CDROM_DEVICE="/dev/$1"
if [ -z "$CDROM_DEVICE" ]; then
    echo "Erro: CDROM_DEVICE não pode ser nulo ou vazio."
    exit 1
fi
echo CDROM_DEVICE $CDROM_DEVICE

CDROM_MOUNT=$(lsblk $CDROM_DEVICE --output MOUNTPOINT -n | head -n1)
if [ -z "$CDROM_MOUNT" ]; then
    echo "Erro: CDROM_MOUNT não pode ser nulo ou vazio."
    exit 1
fi
echo CDROM_MOUNT $CDROM_MOUNT

# Detecte o dispositivo de destino montado
DEST_DEVICE=$(df | grep "/dev/$2" | awk '{print $1}')
if [ -z "$DEST_DEVICE" ]; then
    echo "Erro: DEST_DEVICE não pode ser nulo ou vazio."
    exit 1
fi
echo DEST_DEVICE $DEST_DEVICE

# Defina o diretório de origem
DEST_DIR=$(df | grep -m 1 "$DEST_DEVICE" | awk '{print $6}')
if [ -z "$DEST_DIR" ]; then
    echo "Erro: DEST_DIR não pode ser nulo ou vazio."
    exit 1
fi
echo DEST_DIR $DEST_DIR

# Restante do script...

# Verifique se o CD-ROM está montado
if [ -z "$CDROM_MOUNT" ]; then
    echo "Nenhum CD-ROM montado encontrado em /dev/sr0"
    eject
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
echo rsync -av --progress $MOUNT_POINT/ $DEST_DIR
rsync -av --progress $MOUNT_POINT/ $DEST_DIR
# Desmonte a imagem ISO
sudo umount $MOUNT_POINT

# Delete a imagem ISO
sudo rm $ISO_IMAGE $LOG_FILE

# Imprima uma mensagem quando a sincronização estiver concluída
echo "Sincronização concluída! rsync -av --progress $MOUNT_POINT/ $DEST_DIR"


eject
