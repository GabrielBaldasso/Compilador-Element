using System;
using System.IO;
using System.Text;
using System.Text.Json;
using Antlr4.Runtime;
using Antlr4.Runtime.Tree;
using System.Collections.Generic;

namespace Copilador
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.OutputEncoding = Encoding.UTF8;
            Console.WriteLine("=== CÓDIGO FONTE ===\n");

            string code = @"
                I idade;
                idade = 17;
                Au(idade >= 18) {
                    P(""Maior de idade"");
                } Cu{
                    P(""Menor de idade"");
                }
            ";

            Console.WriteLine(code);

            // Listas de erros
            var lexingErrors = new List<string>();
            var syntaxErrors = new List<string>();
            var semanticErrors = new List<string>();

            // Etapa léxica
            var inputStream = new AntlrInputStream(code);
            var lexer = new ElementLexer(inputStream);
            lexer.RemoveErrorListeners();
            lexer.AddErrorListener(new LexerErrorCollector(lexingErrors));

            // Etapa sintática
            var tokens = new CommonTokenStream(lexer);
            var parser = new ElementParser(tokens);
            parser.RemoveErrorListeners();
            parser.AddErrorListener(new ParserErrorCollector(syntaxErrors));

            var tree = parser.prog();

            parser.RemoveErrorListeners();
            parser.AddErrorListener(new ParserErrorCollector(syntaxErrors));

            // Gerar árvore em JSON
            Console.WriteLine("\nGerando arvore.json ...");
            var jsonTree = BuildJsonTree(tree);
            File.WriteAllText("arvore.json", JsonSerializer.Serialize(jsonTree, new JsonSerializerOptions { WriteIndented = true }));
            Console.WriteLine("Arquivo arvore.json gerado com sucesso.\n");

            // Relatório de erros
            Console.WriteLine("=== RELATÓRIO DE ERROS ===");

            if (lexingErrors.Count > 0)
            {
                Console.WriteLine("\n[ERROS LÉXICOS]:");
                lexingErrors.ForEach(e => Console.WriteLine("- " + e));
            }
            else
            {
                Console.WriteLine("[OK] Nenhum erro léxico encontrado.");
            }

            if (syntaxErrors.Count > 0)
            {
                Console.WriteLine("\n[ERROS SINTÁTICOS]:");
                syntaxErrors.ForEach(e => Console.WriteLine("- " + e));
            }
            else
            {
                Console.WriteLine("\n[OK] Nenhum erro sintático encontrado.");
            }

            // Análise semântica
            Console.WriteLine("\n[ANÁLISE SEMÂNTICA]:");
            var walker = new ParseTreeWalker();
            var semanticAnalyzer = new SemanticAnalyzer();
            walker.Walk(semanticAnalyzer, tree);

            if (semanticAnalyzer.Errors.Count > 0)
            {
                semanticAnalyzer.Errors.ForEach(e => Console.WriteLine("- " + e));
                semanticErrors.AddRange(semanticAnalyzer.Errors);
            }
            else
            {
                Console.WriteLine("[OK] Nenhum erro semântico encontrado.");
            }

            // Geração de código somente se tudo estiver correto
            if (lexingErrors.Count == 0 && syntaxErrors.Count == 0 && semanticErrors.Count == 0)
            {
                Console.WriteLine("\nGerando código intermediário LLVM...");
                var llvmGen = new LLVMCodeGenerator();
                walker.Walk(llvmGen, tree);
                File.WriteAllLines("saida.ll", llvmGen.LLVMCode);
                Console.WriteLine("Arquivo saida.ll gerado com sucesso.");
            }
            else
            {
                Console.WriteLine("\n[!] Código não gerado devido a erros.");
            }

            Console.WriteLine("\n=== FIM DO PROCESSAMENTO ===");
        }

        // Geração de árvore em JSON
        static object BuildJsonTree(IParseTree tree)
        {
            if (tree.ChildCount == 0)
                return tree.GetText();

            var node = new Dictionary<string, object>
            {
                ["node"] = tree.GetType().Name.Replace("Context", "")
            };

            var children = new List<object>();
            for (int i = 0; i < tree.ChildCount; i++)
                children.Add(BuildJsonTree(tree.GetChild(i)));

            node["children"] = children;
            return node;
        }

        // Listener para erros léxicos (ANTLR v4.13.2 usa IAntlrErrorListener<int>)
        class LexerErrorCollector : IAntlrErrorListener<int>
        {
            private readonly List<string> _errors;
            public LexerErrorCollector(List<string> errors) => _errors = errors;

            public void SyntaxError(TextWriter output, IRecognizer recognizer, int offendingSymbol,
                int line, int charPositionInLine, string msg, RecognitionException e)
            {
                _errors.Add($"Linha {line}, coluna {charPositionInLine}: {msg}");
            }
        }

        // Listener para erros sintáticos (BaseErrorListener usa object)
        class ParserErrorCollector : IAntlrErrorListener<IToken>
        {
            private readonly List<string> _errors;

            public ParserErrorCollector(List<string> errors)
            {
                _errors = errors;
            }

            public void SyntaxError(TextWriter output,
                                    IRecognizer recognizer,
                                    IToken offendingSymbol,
                                    int line,
                                    int charPositionInLine,
                                    string msg,
                                    RecognitionException e)
            {
                _errors.Add($"[Sintático] Linha {line}, coluna {charPositionInLine}: {msg}");
            }
        }



    }
}
