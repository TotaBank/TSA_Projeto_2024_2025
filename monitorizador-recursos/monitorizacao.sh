ficheiro_valores_default="valores_alertas.conf"

# Criar ficheiro de valores default caso nao exista
if [[ ! -f $ficheiro_valores_default ]]; then
    echo "Ficheiro de Configuração com os valores default, inexistente, a criar. Aguarde...."
    echo "# Arquivo de configuração para limites de recursos" > "$ficheiro_valores_default"
    echo "LIMITE_CPU=80" >> "$ficheiro_valores_default"
    echo "LIMITE_RAM=80" >> "$ficheiro_valores_default"
    echo "LIMITE_DISCO=90" >> "$ficheiro_valores_default"
    echo "Ficheiro $ficheiro_valores_default criado com sucesso"
fi

source "$ficheiro_valores_default"


valores_cpu() {
    
}


valores_cpu