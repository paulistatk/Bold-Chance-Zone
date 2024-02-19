#!/bin/bash
lsblk
# Se nenhum parâmetro for fornecido, exiba a mensagem de ajuda
if [ "$#" -eq 0 ]; then
    echo "Uso: $0 <origem> <destino> [-R] [tempo limite]"
    echo "  origem: O dispositivo de origem (por exemplo, sr0 para /dev/sr0)"
    echo "  destino: O dispositivo de destino (por exemplo, sda1 para /dev/sda1)"
    echo "  -r: (opcional) Se fornecido, ddrescue será executado em ordem reversa"
    echo "  tempo limite: (opcional) O tempo limite para ddrescue em minutos"
    exit 1
fi

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

DEST_DEVICE=$(df | grep "/dev/$2" | awk '{print $1}')
if [ -z "$DEST_DEVICE" ]; then
    echo "Erro: DEST_DEVICE não pode ser nulo ou vazio."
    exit 1
fi
echo DEST_DEVICE $DEST_DEVICE

DEST_DIR=$(df | grep -m 1 "$DEST_DEVICE" | awk '{print $6}')
if [ -z "$DEST_DIR" ]; then
    echo "Erro: DEST_DIR não pode ser nulo ou vazio."
    exit 1
fi
echo DEST_DIR $DEST_DIR

# Verifique se o CD-ROM está montado
if [ -z "$CDROM_MOUNT" ]; then
    echo "Nenhum CD-ROM montado encontrado em /dev/sr0"
    eject
    exit 1
fi

# Use ddrescue para criar uma imagem ISO do CD-ROM
ISO_IMAGE="/tmp/cdrom_image.iso"
LOG_FILE="/tmp/ddrescue.log"

# Verifique se a opção -R foi fornecida
if [ "$3" == "-r" ]; then
    # Verifique se o tempo limite foi fornecido
    if [ -n "$4" ]; then
        TIMEOUT=$(($4 * 60))
        echo sudo timeout $TIMEOUT ddrescue -n -R -b2048 $CDROM_DEVICE $ISO_IMAGE $LOG_FILE
        sudo timeout $TIMEOUT ddrescue -n -R -b2048 $CDROM_DEVICE $ISO_IMAGE $LOG_FILE
    else
        echo sudo ddrescue -n -R -b2048 $CDROM_DEVICE $ISO_IMAGE $LOG_FILE
        sudo ddrescue -n -R -b2048 $CDROM_DEVICE $ISO_IMAGE $LOG_FILE
    fi
else
    # Verifique se o tempo limite foi fornecido
    if [ -n "$3" ]; then
        TIMEOUT=$(($3 * 60))
        echo sudo timeout $TIMEOUT ddrescue -n -b2048 $CDROM_DEVICE $ISO_IMAGE $LOG_FILE
        sudo timeout $TIMEOUT ddrescue -n -b2048 $CDROM_DEVICE $ISO_IMAGE $LOG_FILE
    else
        echo sudo ddrescue -n -b2048 $CDROM_DEVICE $ISO_IMAGE $LOG_FILE
        sudo ddrescue -n -b2048 $CDROM_DEVICE $ISO_IMAGE $LOG_FILE
    fi
fi

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

# Definindo o local do arquivo e a URL de download
arquivo="/tmp/sunflower-street-drumloop-85bpm-163900.mp3"
url="https://cdn.pixabay.com/download/audio/2023/08/26/audio_a6ee15a317.mp3?filename=sunflower-street-drumloop-85bpm-163900.mp3"

# Verificando se o arquivo já existe
if [ ! -f "$arquivo" ]; then
    # Baixando o arquivo
    curl -o "$arquivo" "$url"
fi

# Executando o arquivo
mpg123 "$arquivo"

eject
