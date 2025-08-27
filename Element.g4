grammar Element;

// ------------- PARSER RULES -------------

prog: statement* EOF;

statement
    : variableDeclaration SEMICOLON
    | assignmentStatement SEMICOLON
    | functionDeclaration
    | expression SEMICOLON                     
    | ifStatement
    | whileStatement
    | forStatement
    | printStatement SEMICOLON
    | returnStatement SEMICOLON
    | inputStatement SEMICOLON
    | classDeclaration
    | block
    ;



block: LBRACE statement* RBRACE;

variableDeclaration: type IDENTIFIER (ASSIGN expression)?;

assignmentStatement
    : IDENTIFIER assignmentOperator expression
    | IDENTIFIER LBRACKET expression RBRACKET ASSIGN expression
    ;

assignmentOperator
    : ASSIGN | PLUS_ASSIGN | MINUS_ASSIGN | MUL_ASSIGN | DIV_ASSIGN;

functionDeclaration: KW_FN type IDENTIFIER LPAREN parameterList? RPAREN block;

parameterList: (type IDENTIFIER) (',' type IDENTIFIER)*;

functionCall: IDENTIFIER LPAREN argumentList? RPAREN;

argumentList: expression (COMMA expression)*;

returnStatement: KW_RETURN expression?;

ifStatement: KW_IF LPAREN expression RPAREN block (KW_ELSE block)?;

whileStatement: KW_WHILE LPAREN expression RPAREN block;

forStatement: KW_FOR LPAREN variableDeclaration? SEMICOLON expression? SEMICOLON assignmentStatement? RPAREN block;

printStatement: KW_PRINT LPAREN expression RPAREN;

inputStatement: KW_SCANF LPAREN IDENTIFIER RPAREN;

classDeclaration: KW_CLASS IDENTIFIER block;

expression: logicalOrExpr;

logicalOrExpr: logicalAndExpr (OR logicalAndExpr)*;

logicalAndExpr: equalityExpr (AND equalityExpr)*;

equalityExpr: relationalExpr ((EQ | NEQ) relationalExpr)*;

relationalExpr: additiveExpr ((GT | GTE | LT | LTE) additiveExpr)*;

additiveExpr: multiplicativeExpr ((PLUS | MINUS) multiplicativeExpr)*;

multiplicativeExpr: unaryExpr ((MUL | DIV) unaryExpr)*;

unaryExpr: (PLUS | MINUS | NOT)? primary;

primary
    : IDENTIFIER
    | NUMBER
    | FLOAT_NUMBER
    | CHAR_LITERAL
    | STRING_LITERAL
    | KW_TRUE
    | KW_FALSE
    | LPAREN expression RPAREN
    | functionCall
    | IDENTIFIER LBRACKET expression RBRACKET
    | IDENTIFIER DOT IDENTIFIER LPAREN argumentList? RPAREN
    ;

type
    : KW_TYPE_INT
    | KW_TYPE_FLOAT
    | KW_TYPE_CHAR
    | KW_TYPE_STRING
    | KW_TYPE_BOOL
    | KW_TYPE_ARRAY LT type GT
    | KW_TYPE_VOID
    | IDENTIFIER  
    ;

// ------------- LEXER RULES -------------

// Palavras-chave
KW_IF: 'Au';
KW_ELSE: 'Cu';
KW_WHILE: 'W';
KW_FOR: 'Fe';
KW_FUNCTION: 'Ds';
KW_RETURN: 'Rn';
KW_PRINT: 'P';
KW_SCANF: 'L';
KW_CLASS: 'Cl';
KW_FN: 'Fn';

// Tipos primitivos
KW_TYPE_INT: 'I';
KW_TYPE_FLOAT: 'Fl';
KW_TYPE_CHAR: 'Ch';
KW_TYPE_STRING: 'S';
KW_TYPE_BOOL: 'B';
KW_TYPE_ARRAY: 'Ar';
KW_TYPE_VOID: 'V';

// Booleanos
KW_TRUE: 'O';
KW_FALSE: 'N';

// Identificadores
IDENTIFIER: [a-zA-Z_] [a-zA-Z0-9_]*;

// Literais
NUMBER: [0-9]+;
FLOAT_NUMBER: [0-9]+ '.' [0-9]+;
CHAR_LITERAL: '\'' ( ~['\\\r\n] | '\\' . ) '\'';
STRING_LITERAL: '"' ( '\\' . | ~["\\\r\n] )*? '"';

// Operadores
PLUS_ASSIGN: '+=';
MINUS_ASSIGN: '-=';
MUL_ASSIGN: '*=';
DIV_ASSIGN: '/=';
DOT: '.';

EQ: '==';
NEQ: '!=';
LTE: '<=';
GTE: '>=';

ASSIGN: '=';
PLUS: '+';
MINUS: '-';
MUL: '*';
DIV: '/';

GT: '>';
LT: '<';
AND: '&&';
OR: '||';
NOT: '!';

// Delimitadores
LPAREN: '(';
RPAREN: ')';
LBRACE: '{';
RBRACE: '}';
LBRACKET: '[';
RBRACKET: ']';
SEMICOLON: ';';
COMMA: ',';

// Comentários e espaços
LINE_COMMENT: '//' ~[\r\n]* -> skip;
BLOCK_COMMENT: '/*' .*? '*/' -> skip;
WS: [ \t\r\n]+ -> skip;
