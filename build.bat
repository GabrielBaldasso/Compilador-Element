@echo off
echo === GERANDO ARQUIVOS ANTLR PARA CSharp ===
java -jar antlr-4.13.2-complete.jar -Dlanguage=CSharp -visitor -o Generated Element.g4
echo === PRONTO! Arquivos gerados na pasta Generated. ===
pause
