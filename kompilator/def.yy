%{
// #include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include <iostream>
#include <sstream>
#include <stack>
#include <fstream>
#include <map>
#include <vector>

#define INFILE_ERROR 1
#define OUTFILE_ERROR 2
void writeLexValue(char *);
extern int yylineno;

extern "C" int yylex();
extern "C" int yyerror(const char *msg, ...);
extern FILE *yyin;
extern FILE *yyout;

using namespace std;

union vals {
    int intVal;
    double doubleVal;
    char * textVal;
};

enum types{
    lc = 0,
    lz = 1,
    id = 2
};

struct element {
    types type;
    string varName;
    vals val;
};

stack <element> * s = new stack<element>;
map <int, element> symbols;

fstream outTriples("outTriples.txt",std::ios::out);
fstream outLexValue("outLexValue.txt",std::ios::out);
fstream outSymbols("outSymbols.txt",std::ios::out);
fstream outAsm("outAsm.txt",std::ios::out);

vector <string> * codeAsm = new vector <string>();
void generateAsmAdd(string variable1, string variable2);

int tempVariableCount = 0;
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
        :wyr                    {writeLexValue("\n"); outTriples << endl;}
        |ww
        |start wyr              {writeLexValue("\n"); outTriples << endl;}
        ;
wyr
	:wyr '+' skladnik	{
                                    printf("wyrazenie z + \n"); 
                                    writeLexValue("+"); 
                                    
                                    cout << "Stack size :" << s->size() << endl;
                                    
                                    element e1 = s->top();
                                    s->pop();
                                    
                                    element e2 = s->top();
                                    s->pop(); 

                                    element e;
                                    e.type = id;
                                    
                                    
                                    stringstream ss;
                                    ss << "_tmp" << tempVariableCount;
                                    e.varName = ss.str();
                                    tempVariableCount++;
                                    
                                    outTriples << e.varName + " = " << e1.varName << " " << e2.varName<< " +" << endl;
                                    
                                    symbols.insert(std::pair<int,element>(0,e));
                                    outSymbols << e.varName << "\t" << e.type << endl;
                                    
                                    s->push(e);
                                    
                                    generateAsmAdd(e1.varName,e2.varName);
                                }
	|wyr '-' skladnik	{
                                    printf("wyrazenie z - \n"); 
                                    writeLexValue("-");
                                    
                                    cout << "Stack size :" << s->size() << endl;
                                    
                                    element e1 = s->top();
                                    s->pop();
                                    
                                    element e2 = s->top();
                                    s->pop(); 

                                    element e;
                                    e.type = id;
                                    
                                    
                                    stringstream ss;
                                    ss << "_tmp" << tempVariableCount;
                                    e.varName = ss.str();
                                    tempVariableCount++;
                                    
                                    outTriples << e.varName + " = " << e1.varName << " " << e2.varName<< " -" << endl;
                                    
                                    symbols.insert(std::pair<int,element>(0,e));
                                    outSymbols << e.varName << "\t" << e.type << endl;
                                    
                                    s->push(e);
                                }
        |wyr '=' wyr       {
                                    printf("wyrazenie z = \n"); 
                                    writeLexValue("=");
                                    
                                    cout << "STACK SIZE: " << s->size() << endl;
                                    
                                    element e1;
                                    e1 = s->top(); 
                                    s->pop();
                                    
                                    element e2;
                                    e2 = s->top();
                                    s->pop();
                                    
                                    element e;
                                    e.type = id;
                                    
                                    stringstream ss;
                                    ss << "_tmp" << tempVariableCount;
                                    e.varName = ss.str();
                                    tempVariableCount++;
                                    
                                    outTriples << e.varName + " = " << e1.varName << " " << e2.varName<< " =" << endl;
                                    
                                    //DODAWANIE DO TABLICY SYMBOLI TUTAJ
                                    symbols.insert(std::pair<int,element>(0,e));
                                    outSymbols << e.varName << "\t" << e.type << endl;
                                }
                                
	|skladnik		{printf("wyrazenie pojedyncze \n");}
	;
skladnik
	:skladnik '*' czynnik	{
                                    printf("skladnik z * \n"); 
                                    writeLexValue("*");
                                                                        
                                    cout << "Stack size :" << s->size() << endl;
                                    
                                    element e1 = s->top();
                                    s->pop();
                                    
                                    element e2 = s->top();
                                    s->pop(); 

                                    element e;
                                    e.type = id;
                                    
                                    
                                    stringstream ss;
                                    ss << "_tmp" << tempVariableCount;
                                    e.varName = ss.str();
                                    tempVariableCount++;
                                    
                                    outTriples << e.varName + " = " << e1.varName << " " << e2.varName<< " *" << endl;
                                    
                                    symbols.insert(std::pair<int,element>(0,e));
                                    outSymbols << e.varName << "\t" << e.type << endl;
                                    
                                    s->push(e);

                                }
	|skladnik '/' czynnik	{
                                    printf("skladnik z / \n");
                                    writeLexValue("/");
                                    
                                    cout << "Stack size :" << s->size() << endl;
                                    
                                    element e1 = s->top();
                                    s->pop();
                                    
                                    element e2 = s->top();
                                    s->pop(); 

                                    element e;
                                    e.type = id;
                                    
                                    
                                    stringstream ss;
                                    ss << "_tmp" << tempVariableCount;
                                    e.varName = ss.str();
                                    tempVariableCount++;
                                    
                                    outTriples << e.varName + " = " << e1.varName << " " << e2.varName<< " /" << endl;

                                    symbols.insert(std::pair<int,element>(0,e));
                                    outSymbols << e.varName << "\t" << e.type << endl;
                                    
                                    s->push(e);
                              

                                }
	|czynnik		{printf("skladnik pojedynczy \n");}
	;
czynnik
	:ID			{
                                    printf("czynnik znakowy (zmienna) - %s\n",$1); 
                                    fprintf(yyout, "%s ", $1);
                                    printf("\n>>PUSHING AT STACK<<\n");
                                    
                                    element e;
                                    e.type = id;
                                    
                                    stringstream ss;
                                    ss << $1;
                                    e.varName = ss.str();

                                    s->push(e);
                                    
                                    
                                    //sprawdź czy symbol istneje
                                    
/*                                     if() */
                                    {
                                        symbols.insert(std::pair<int,element>(0,e));
                                        outSymbols << e.varName << "\t" << e.type << endl;
                                    }   
                                } 
        |LZ                     {
                                    printf("czynnik liczba zmiennoprzecinkowa %lf\n",$1); 
                                    fprintf(yyout, "%lf ", $1);
                                    printf("\n>>PUSHING AT STACK<<\n");
/*                                    std::stringstream ss;
                                    ss << $1;
                                    s->push(ss.str());*/
                                }   
	|LC			{
                                    printf("czynnik liczba całkowita - %d\n",$1); 
                                    fprintf(yyout, "%d ", $1); 
                                    printf("\n>>PUSHING AT STACK<<\n");
                                    
                                    element e;
                                    e.type = lc;
                                    e.val.intVal = $1;
                                    
                                    stringstream ss;
                                    ss << $1;
                                    e.varName = ss.str();

                                    s->push(e);
                                }
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

void generateAsm()
{
    for(int i = 0; i < codeAsm->size(); i++)
    {
        outAsm << codeAsm->back();
        codeAsm->pop_back();
    }
}

void generateAsmAdd(string variable1, string variable2)
{
    stringstream ss;
    
    ss << "li $t0, " << variable1 << "\n";
    codeAsm->push_back(ss.str());
    ss.clear();
    
    ss << "li $t1, " << variable2 << "\n";
    codeAsm->push_back(ss.str());
    ss.clear();
    
    codeAsm->push_back("add $t0, $t0, $t1");
 
     ss << "sw $t0, " << variable1 << "\n";
    codeAsm->push_back(ss.str());
    ss.clear();
}


void writeLexValue(char * value)
{
/*         outLexValue << x << " "; */
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
	
	generateAsm();
	
	return 0;
}
