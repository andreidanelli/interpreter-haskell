{
module Parser where
import Lexer
}

%name parser
%tokentype { Token }
%error { parserError }

%left '+'

%token
    num         { TokenNum $$ }
    '+'         { TokenAdd }
    "-"         { TokenSub }
    "*"         { TokenMul }
    "&&"        { TokenAnd }
    true        { TokenTrue }
    false       { TokenFalse }
    if          { TokenIf }
    then        { TokenThen }
    else        { TokenElse } 
    "||"        { TokenOr }
    var         { TokenVar $$ }
    '\\'        { TokenLam }
    "->"        { TokenArrow }
    '('         { TokenLParen }
    ')'         { TokenRParen }
    '='         { TokenEq }
    let         { TokenLet }
    in          { TokenIn }
    Bool        { TokenBoolean }
    Num         { TokenNumber }
    ':'         { TokenColon }
    '>'         { TokenBigger }
    '<'         { TokenSmaller }
    ">="        { TokenGreaterEquals }
    "<="        { TokenLeastEqual }
    "=="        { TokenEquals }

%%

Exp                 : num                           { Num $1 }
                    | true                          { BTrue }
                    | false                         { BFalse }
                    | Exp '+' Exp                   { Add $1 $3 }
                    | Exp "-" Exp                   { Sub $1 $3 }
                    | Exp "*" Exp                   { Mul $1 $3 }
                    | Exp "&&" Exp                  { And $1 $3 }
                    | if Exp then Exp else Exp      { If $2 $4 $6 }
                    | Exp "||" Exp                  { Or $1 $3 }
                    | var                           { Var $1 }
                    | '\\' var ':' Type "->" Exp    { Lam $2 $4 $6 }
                    | Exp Exp                       { App $1 $2 }
                    | '(' Exp ')'                   { Paren $2 }
                    | let var '=' Exp in Exp        { Let $2 $4 $6 }
                    | Exp '>' Exp                   { Bigger $1 $3 }
                    | Exp '<' Exp                   { Smaller $1 $3 }
                    | Exp ">=" Exp                  { GreaterEquals $1 $3 }
                    | Exp "<=" Exp                  { LeastEqual $1 $3 }
                    | Exp "==" Exp                  { Equals $1 $3 }

Type    : Bool                                      { TBool }
        | Num                                       { TNum }
        | '(' Type "->" Type ')'                    { TFun $2 $4 }

{

parserError :: [Token] -> a
parserError _ = error "Syntax error!"

}