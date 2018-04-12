%{
#include <stdlib.h>
#include <string.h>
#include "def.tab.hh"
#define INFILE_ERROR 1
#define OUTFILE_ERROR 2
extern int yylineno;
const int yyerror(char *,...);
%}
%%

CK			{return CK;} 
ZM                      {return ZM;} 
TK                      {return TK;} 
PISZ                            {return PISZ;} 
CZYTAJ                          {return CZYTAJ;} 
JEZELI                          {return JEZELI;} 
TO                              {return TO;} 
JEZELINIE                       {return JEZELINIE;} 
DOPOKI                          {return DOPOKI;} 

\=\=			{return EQ;}
\<\=			{return LE;} 
\>\=			{return GE;} 
\!\=			{return NE;} 
\>                      {return GT;} 
\<                      {return LT;} 

\+			{return '+';} 
\*			{return '*';}
\(			{return '(';}
\)			{return ')';}
\/			{return '/';}
\-			{return '-';}
\^			{return '^';}
\=			{return '=';}

[1-9][0-9]*[\.][0-9]+|[0][\.][0-9]+   {yylval.dval = atof(yytext); return LZ;}
[1-9][0-9]*		{yylval.ival = atoi(yytext); return LC;}	
[A-Za-z_][A-Za-z0-9_]*	{yylval.text = strdup(yytext); return ID;}
\ |\t			{;}
\n			{yylineno++;}
.			{yyerror("Blad leksykalny\n");}
%%
const int yyerror(char *msg,...)
{
	printf("%d: %s", yylineno, msg);
	exit(1);
}

