
#!/bin/bash

# Para cada arquivo no diretório
for arquivo in *; do
    # Se o arquivo for executável
    if [[ -x "$arquivo" ]]; then
        # Cria um atalho em /usr/local/bin
        echo ln -s "`pwd`/$arquivo" /usr/local/bin/$arquivo
        ln -s "`pwd`/$arquivo" /usr/local/bin/$arquivo
    fi
done
