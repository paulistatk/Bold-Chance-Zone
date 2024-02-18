#!/bin/bash

# Diretório inicial
dir_inicial="$1"

# Verifica se o diretório existe
if [ ! -d "$dir_inicial" ]; then
    echo "O diretório $dir_inicial não existe."
    exit 1
fi

# Lista os diretórios em ordem de quantidade de arquivos
find "$dir_inicial" -mindepth 1 -maxdepth 1 -type d | while read -r dir; do
    # Ignora diretórios que começam com "_"
    if [[ $(basename "$dir") == _* ]]; then
        continue
    fi

    num_arquivos=$(find "$dir" -type f | wc -l)
    echo "$num_arquivos arquivos em $(basename "$dir")"

    if [ "$num_arquivos" -eq 0 ]; then
        echo "Movendo para a lixeira o diretório $(basename "$dir") que contém $num_arquivos arquivos."
        gio trash "$dir"
    fi
    # Encontra a extensão de arquivo mais comum
    extensao_comum=$(find "$dir" -type f | rev | cut -d. -f1 | rev | sort | uniq -c | sort -rn | head -n1 | awk '{print $2}' | tr '[:lower:]' '[:upper:]')
    # echo "No diretório $(basename "$dir"), a extensão de arquivo mais comum é $extensao_comum"

    # Cria um novo diretório com o nome da extensão mais comum
    novo_dir="$dir_inicial/_$extensao_comum"
    mkdir -p "$novo_dir"

    # Move o diretório para o novo diretório
    mv -b "$dir" "$novo_dir/"
    echo "O diretório $(basename "$dir") foi movido para $novo_dir"
done | sort -rn

# Trata os arquivos na raiz do diretório inicial
find "$dir_inicial" -maxdepth 1 -type f | while read -r file; do
    # Encontra a extensão do arquivo
    extensao=$(echo "${file##*.}" | tr '[:lower:]' '[:upper:]')

    # Cria um novo diretório com o nome da extensão
    novo_dir="$dir_inicial/_$extensao"
    mkdir -p "$novo_dir"

    # Move o arquivo para o novo diretório
    mv -b "$file" "$novo_dir/"
    echo "O arquivo $(basename "$file") foi movido para $novo_dir"
done
