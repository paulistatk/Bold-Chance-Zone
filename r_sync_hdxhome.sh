#!/bin/bash

# Detecte o dispositivo de destino montado
DEST_DEVICE=$(df | grep '/dev/sdc1' | awk '{print $1}')
echo $DEST_DEVICE

# Defina o diretório de origem
DEST_DIR=$(df | grep -m 1 "$DEST_DEVICE" | awk '{print $6}')
echo $DEST_DIR

# Obtenha o nome do volume
VOLUME_NAME=$(basename "$DEST_DIR")

# Defina o diretório de destino na home do usuário
USER_HOME_DIR=~/"$VOLUME_NAME"

# Crie o diretório de destino se ele não existir
mkdir -p "$USER_HOME_DIR"

# Sincronize o conteúdo do drive montado com o diretório de destino
rsync -av "$DEST_DIR"/ "$USER_HOME_DIR"

echo "Sincronização concluída."
