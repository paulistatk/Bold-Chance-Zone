#!/bin/bash

# Verifique se todos os parâmetros foram fornecidos
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo "Por favor, forneça o diretório, a extensão original e a extensão para a qual será alterada."
    exit 1
fi

# Diretório onde estão os arquivos
diretorio="$1"

# Extensão original dos arquivos
extensao_original="$2"

# Extensão para a qual os arquivos serão alterados
nova_extensao="$3"

# Altere a extensão dos arquivos
for arquivo in "$diretorio"/*."$extensao_original"; do
    mv "$arquivo" "${arquivo%.$extensao_original}.$nova_extensao"
done
