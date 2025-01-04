ficheiro_valores_default="valores_alertas.conf"
ficheiro_logs="logs_sistema.txt"

se_for_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "Para podermos instalar o script, precisas de estar no utilizador root"
        exit 1
    fi
}

verifica_dependencias() {
    if ! command -v $1 >/dev/null 2>&1; then #https://stackoverflow.com/questions/33297857/how-to-check-dependency-in-bash-script
        echo "O comando $1 não está instalado. A tentar instalar, por favor, aguarda..."

        se_for_root

        #Primeiro de tudo, dar update, lembra-se professor? ehehehe
        apt update -y

        apt install -y $1 || { echo "Erro ao instalar o comando $1. Verifica as tuas permissões."; exit 1; }

        echo "Comando $1 instalado com sucesso"
    else
        echo " - $1 já instalado, a prossegir..."
    fi
}

echo "A Verificar Dependências:"
verifica_dependencias "top"
verifica_dependencias "free"
verifica_dependencias "mailutils" #Dependencia para poder enviar emails | https://stackoverflow.com/questions/55199692/sending-e-mail-from-bash-script

#Configuraçao SMTP | https://medium.com/@ikpemosi.braimoh/smtp-how-to-send-mails-via-the-terminal-using-mailutils-82d41527a8d4
verifica_dependencias "msmtp" #Dependencia para poder enviar emails | https://arnaudr.io/2020/08/24/send-emails-from-your-terminal-with-msmtp/
verifica_dependencias "msmtp-mta" #Dependencia para poder enviar emails | https://arnaudr.io/2020/08/24/send-emails-from-your-terminal-with-msmtp/

# Informações fixas do servidor de e-mail
EMAIL="universidade.alertas@vascodias.pt"        ##NÃO MEXERRRRRRR
SENHA="Testes_Universidade_Alertas2024"      ##NÃO MEXERRRRRRR
SMTP_SERVER="vascodias.pt"                ##NÃO MEXERRRRRRR
SMTP_PORT="587"                             ##NÃO MEXERRRRRRR

# Criar o arquivo de configuração do msmtp
FICHEIRO_CONFIGURACAO_EMAIL="$HOME/.msmtprc"


if [[ ! -f FICHEIRO_CONFIGURACAO_EMAIL ]]; then
cat <<EOL > $FICHEIRO_CONFIGURACAO_EMAIL
account default
host $SMTP_SERVER
port $SMTP_PORT
from $EMAIL
user $EMAIL
password $SENHA
tls on
auth on
EOL

    chmod 600 $FICHEIRO_CONFIGURACAO_EMAIL

    echo "Configuração do msmtp concluída!"
fi


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

registar_alerta_em_log(){
    #Criar Ficheiro, se não existir
    if [[ ! -f $ficheiro_logs ]]; then
        touch "$ficheiro_logs"
    fi

    echo "$(date '+%Y-%m-%d %H:%M:%S') - Uso abusivo de $1, tendo tido o valor: $2%" >> $ficheiro_logs
}

gerar_alerta_email() {
    PARA="eu@vascodias.pt" ##EMAIL DO GESTOR QUE RECEBE OS ALERTAS, PODE SER ALTERADO
    ASSUNTO="Alerta de Abuso de Recursos - $(date '+%Y-%m-%d %H:%M:%S')"
    CONTEUDO="Atenção! Por volta das $(date '+%Y-%m-%d %H:%M:%S') o recurso $1, teve um pico de $2%."

    echo -e "Subject:$ASSUNTO\nContent-Type: text/plain; charset=UTF-8\n\n$CONTEUDO" | msmtp "$PARA"

    if [ $? -ne 0 ]; then
    echo "Falha no envio do e-mail."
    else
    echo "E-mail enviado com sucesso."
    fi
}

valores_cpu() {
    
    uso_CPU=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')

    if (( $(echo "$uso_CPU < $LIMITE_CPU" | bc -l) )); then ## PARA EFEITOS DE TESTES, A CONDIÇÃO ESTA AO CONTRÁRIO, PARA COLOCAR EM PRODUÇAO DEVE SER ALTERADO DE < PARA  > 
        gerar_alerta_email "CPU" "$uso_CPU" 
        registar_alerta_em_log "CPU" "$uso_CPU" 
    fi   
}

valores_ram() {
    uso_RAM=$(free | grep Mem | awk '{print $3/$2 * 100.0}')

    if (( $(echo "$uso_RAM < $LIMITE_RAM" | bc -l) )); then  ## PARA EFEITOS DE TESTES, A CONDIÇÃO ESTA AO CONTRÁRIO, PARA COLOCAR EM PRODUÇAO DEVE SER ALTERADO DE < PARA  > 
        gerar_alerta_email "RAM" "$uso_RAM"
        registar_alerta_em_log "RAM" "$uso_RAM"
    fi   
}


valores_cpu
valores_ram