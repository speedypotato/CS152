grammar Expr;

// ***Lexing rules***

INT     : [0-9]+ ;
NEWLINE : '\r'? '\n' ;
WS      : [ \t]+ -> skip ; // ignore whitespace
ID		: [a-zA-Z]+ ; // Part 2.1

MUL : '*' ;
DIV : '/' ;
ADD : '+' ;
SUB : '-' ;


// ***Parsing rules ***

/** The start rule */
prog: stat+ ;

stat: expr NEWLINE              # printExpr
    | NEWLINE                   # blank
    ;

expr: expr op=( '*' | '/' ) expr   # MulDiv
    | expr op=( '+' | '-' ) expr   # AddSub
    | INT                       # int
    | '(' expr ')'              # parens
	| ID # id //Part 2.3
	| ID '=' expr # Assign //Part 2.2
    ;


