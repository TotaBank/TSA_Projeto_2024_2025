#!/bin/bash

URL_API="https://opentdb.com/api.php"
categoria="" #9 - questões gerais, 21 - desporto, 18 - informatica, 19 - matematica, 15 - videojogos
dificuldade="" #easy, medium ou hard
tipo="" #multiple (multipla) ou boolean (verdadeiro ou falso)
respostas=""
echo "Bem vindo ao jogo do Vasco, Tomás e Companhia..."
echo "O jogo é indicado para pessoas que saibam inglês"

echo "Escolha a categoria?"
echo "1 - Conhecimento geral"
echo "2 - Desporto"
echo "3 - Informática"
echo "4 - Matemática"
echo "5 - Videojogos"

read escolherCategoria
case $escolherCategoria in
    1)  categoria="9" ;;
    2)  categoria="21" ;;
    3)  categoria="18" ;;
    4)  categoria="19" ;;
    5)  categoria="15" ;;
    *) echo "Opção Inválida" ;;
    esac

echo "Escolha o nível de dificuldade:"
echo "1 - Fácil"
echo "2 - Médio"
echo "3 - Difícil"

read escolherDificuldade

case $escolherDificuldade in
    1) dificuldade="easy" ;;
    2) dificuldade="medium" ;;
    3) dificuldade="hard" ;;
    *) echo "Opção Inválida" ;;
esac

echo "Escolha o tipo de pergunta:"
echo "1 - Múltipla Escolha"
echo "2 - Verdadeiro ou Falso"


read escolherTipo

case $escolherTipo in
    1) tipo="multiple" ;;
    2) tipo="boolean" ;;
    *) echo "Opção Inválida" ;;
esac

resposta_api=$(curl -s "$URL_API?amount=1&category=$categoria&difficulty=$dificuldade&type=$tipo")
questao=$(echo "$resposta_api" | grep -o '"question":"[^"]*"' | sed 's/"question":"//' | sed 's/"$//')
resposta_correta=$(echo "$resposta_api" | grep -o '"correct_answer":"[^"]*"' | sed 's/"correct_answer"://')
respostas_erradas=$(echo "$resposta_api" | grep -o '"incorrect_answers":\[[^]]*\]' | sed 's/"incorrect_answers":\[//' | sed 's/]$//')

respostas="$respostas_erradas,$resposta_correta"
respostas=$(echo "$respostas" | tr ',' '\n' | shuf)
echo "$questao"
echo "Qual a resposta certa? "
echo "$respostas"

read respostaUtilizador
if [[ $respostaUtilizador == "$(echo $resposta_correta | tr -d '"')" ]]; then
    echo "Parabéns acertou!"
    else
    echo "Infelizmente errou, a resposta certa era $resposta_correta"
fi




