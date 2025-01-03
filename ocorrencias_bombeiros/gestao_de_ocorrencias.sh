#!/bin/bash

ficheiro_ocorrencias="ocorrencias_bombeiros.txt"

# Função para exibir o menu principal
menu() {
  echo "Sistema de Gestão de Ocorrências - Bombeiros"
  echo "==============================================="
  echo "1. Registar nova ocorrência"
  echo "2. Mostrar todas as ocorrências"
  echo "3. Marcar ocorrência como resolvida"
  echo "4. Apagar ocorrências"
  echo "0. Sair"
  echo "==============================================="
  echo -n "Escolha uma opção: "
}

# Função para registar uma nova ocorrência
registar_ocorrencia() {
  echo -n "Digite a descrição da ocorrência: "
  read ocorrencia_descricao
  echo -n "Digite a localização da ocorrência: "
  read ocorrencia_localizacao
  ocorrencia_numero=$(($(cat "$ficheiro_ocorrencias" | cut -d "|" -f 1 | tail -n 1) + 1))
  ocorrencia_data=$(date +"%Y-%m-%d %H:%M:%S")
  echo "$ocorrencia_numero|Aberto|$ocorrencia_descricao|$ocorrencia_localizacao|$ocorrencia_data" >> "$ficheiro_ocorrencias"
  echo "Ocorrência #$ocorrencia_numero registrada com sucesso!"
}

# Função para listar todas as ocorrências
listar_ocorrencias() {
  echo "=== Ocorrências Registadas ==="
  if [[ ! -s $ficheiro_ocorrencias ]]; then
    echo "Nenhuma ocorrência encontrada."
  else
    column -t -s "|" -N "Número,Estado,Descrição,Localização,Data" "$ficheiro_ocorrencias"
  fi
  echo "================================"
}

# Função para marcar uma ocorrência como resolvida
resolver_ocorrencia() {
  echo -n "Digite o número da ocorrência a ser marcada como resolvida: "
  read ocorrencia_numero
  if grep -q "^$ocorrencia_numero|" "$ficheiro_ocorrencias"; then
    sed -i "s/^$ocorrencia_numero|Aberto/$ocorrencia_numero|Resolvido/" "$ficheiro_ocorrencias"
    echo "Ocorrência #$ocorrencia_numero marcada como resolvida!"
  else
    echo "Ocorrência #$ocorrencia_numero não encontrada."
  fi
}

#Apagar ocorrencia do ficheiro
apagar_ocorrencia() {
  echo "Escolha uma opção:"
  echo "1. Apagar ocorrência por número"
  echo "2. Apagar todas as ocorrências"
  echo -n "Escolha uma opção: "
  read opcao_apagar

  case $opcao_apagar in
    1)
      # Apagar ocorrência específica
      echo -n "Digite o número da ocorrência a ser apagada: "
      read ocorrencia_numero

      # Verifica se a ocorrência existe
      if grep -q "^$ocorrencia_numero|" "$ficheiro_ocorrencias"; then
        sed -i "/^$ocorrencia_numero|/d" "$ficheiro_ocorrencias"
        echo "Ocorrência #$ocorrencia_numero apagada com sucesso!"
      else
        echo "Ocorrência #$ocorrencia_numero não encontrada."
      fi
      ;;
    
    2)
      # Apagar todas as ocorrências após confirmação
      echo -n "Tem certeza de que deseja apagar todas as ocorrências? (sim/nao): "
      read confirmacao

      if [[ "$confirmacao" == "sim" ]]; then
         rm -f "$ficheiro_ocorrencias" 
        touch "$ficheiro_ocorrencias" 
        echo "Todas as ocorrências foram apagadas."
      else
        echo "Operação cancelada."
      fi
      ;;
    
    *)
      echo "Opção inválida"
      ;;
  esac
}

# Criar ficheiro de ocorrencias caso nao exista
if [[ ! -f $ficheiro_ocorrencias ]]; then
  touch "$ficheiro_ocorrencias"
fi

# Loop principal
while true; do
  menu
  read opcao
  case $opcao in
    1) registar_ocorrencia ;;
    2) listar_ocorrencias ;;
    3) resolver_ocorrencia ;;
    4) apagar_ocorrencia ;;
    0) break ;;
    *) echo "Opção inválida" ;;
  esac
done
