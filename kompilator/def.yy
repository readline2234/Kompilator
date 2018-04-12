%{
// #include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include <iostream>
#include <stack>

#define INFILE_ERROR 1
#define OUTFILE_ERROR 2
void writeLexValue(char *);
extern int yylineno;

extern "C" int yylex();
extern "C" int yyerror(const char *msg, ...);
extern FILE *yyin;
extern FILE *yyout;

using namespace std;

stack <string> s;
%}
%union 
{
char *text;
int	ival;
double  dval;
};
%type <text> wyr
%token CK ZM TK 
%token PISZ CZYTAJ 
%token JEZELI TO JEZELINIE DOPOKI
%token GT LT EQ GE LE NE
%token <text> ID
%token <ival> LC
%token <dval> LZ
%left '+' '-'
%left '*' '/'
%start start
%%
start
        :wyr                    {writeLexValue("\n");}
        |ww
        |start wyr              {writeLexValue("\n");}
        ;
wyr
	:wyr '+' skladnik	{printf("wyrawiekszoscizenie z + \n"); writeLexValue("+"); }
	|wyr '-' skladnik	{printf("wyrazenie z - \n"); writeLexValue("-"); }
	|skladnik		{printf("wyrazenie pojedyncze \n");}
	;
skladnik
	:skladnik '*' czynnik	{printf("skladnik z * \n"); writeLexValue("*");}
	|skladnik '/' czynnik	{printf("skladnik z / \n"); writeLexValue("/");}
	|czynnik		{printf("skladnik pojedynczy \n");}
	;
czynnik
	:ID			{printf("czynnik znakowy (zmienna) - %s\n",$1); fprintf(yyout, "%s ", $1); s.push($1);} 
        |LZ                     {printf("czynnik liczba zmiennoprzecinkowa %lf\n",$1); fprintf(yyout, "%lf ", $1); s.push();}   
	|LC			{printf("czynnik liczba całkowita - %d\n",$1); fprintf(yyout, "%d ", $1);}
	|'(' wyr ')'		{printf("wyrazenie w nawiasach\n");}
	;
ww
        :wyr opw wyr            {printf("wyrazenie warunkowe\n");} 
	;
opw	
        :LT                     {printf("operator mniejszosci - <\n");} 
        |GT                     {printf("operator wiekszosci - >\n");} 
        |EQ                     {printf("operator rownosci - ==\n");} 
        |NE                     {printf("operator nierownosci !=\n");} 
        |GE                     {printf("operator wiekszosci lub rownosci - >=\n");} 
        |LE                     {printf("operator mniejszosci lub rownosci - <=\n");} 
        ;
%%

//1. main, zeby dzialalo z konsoli ./leks in.txt, a nie jako ./leks < in.txt
//2. zrzut do pliku, nie trzeba nic zmieniać, poprostu zrzut do plku <identifikatory> <liczby> <operatory>, juz będą w odpowiedniej kolejności bo bison to załatwi
//2.cd.zeby w plku dla 2+x+7.14+y bylo >>>> 2x+7.14+y+
//3. testowanie



void writeLexValue(char *value)
{
	fprintf(yyout, "%s ", value);
}

int main(int argc, char *argv[])
{
     	if (argc>1) 
	{
		yyin = fopen(argv[1], "r");
		if (yyin==NULL)
		{
			printf("Błąd\n");
			return INFILE_ERROR;
		}
		if (argc>2)
		{
			yyout=fopen(argv[2], "w");
			if (yyout==NULL)
			{
				printf("Błąd\n");
				return OUTFILE_ERROR;
			}
		}
	}
        
	yyparse(); 
	
	return 0;
}
