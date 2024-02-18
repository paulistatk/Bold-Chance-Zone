# ## Usuário
# script que para cada arquivo executável na pasta crie um atalho em /usr/local/bin
# ## Bing
# Claro, você pode usar um script de shell para isso. Aqui está um exemplo:

#!/bin/bash

# Diretório onde estão os arquivos executáveis
diretorio="$1"

# Para cada arquivo no diretório
for arquivo in "$diretorio"/*; do
    # Se o arquivo for executável
    if [[ -x "$arquivo" ]]; then
        # Cria um atalho em /usr/local/bin
        ln -s `pwd`/$arquivo /usr/local/bin/$arquivo
        echo $arquivo
    fi
done

# Este script irá criar um atalho para cada arquivo executável no diretório especificado em /usr/local/bin. Lembre-se de substituir "/caminho/para/seu/diretorio" pelo caminho do diretório onde estão os arquivos executáveis.
# Nota: Você precisará de permissões de super
