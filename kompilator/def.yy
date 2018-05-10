%{
// #include <string.h>

//TODO: Powtarzanie zmiennych w tablicy symboli - sprawdzanie przed dodaniem czy nie znajduje się w tablicy SYMBOLI
//TODO: 

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
fstream outAll("outAll.asm",std::ios::out);

vector <string> * codeAsm = new vector <string>();
void generateAsmAdd(string variable1, string variable2, string result);
void generateAsmDef(element variable1, string variable2);
void generateAsmMul(string variable1, string variable2, string result);
void generateAsmX(element variable1, element variable2, string result, string operation);
void generateAsmPrint(element variable1);

bool isInSymbols(string name);

int tempVariableCount = 0;
int tempIDcount = 0;
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
                                    
/*                                     symbols.insert(std::pair<int,element>(0,e)); */
                                    symbols[tempIDcount] = e;
                                    tempIDcount++;
                                    outSymbols << e.varName << "\t" << e.type << endl;
                                    
                                    s->push(e);
                                    
/*                                     generateAsmAdd(e1.varName,e2.varName,e.varName); */
                                    generateAsmX(e1, e2, e.varName,"add");
                                    
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
                                    
/*                                     symbols.insert(std::pair<int,element>(0,e)); */
                                    symbols[tempIDcount] = e;
                                    tempIDcount++;
                                    outSymbols << e.varName << "\t" << e.type << endl;
                                    
                                    s->push(e);
                                    
                                    generateAsmX(e1 ,e2, e.varName,"sub");
                                }  
       |PISZ wyr            {
                                element e1 = s->top();
                                s->pop();
                                generateAsmPrint(e1);
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
/*                                     symbols.insert(std::pair<int,element>(tempIDcount,e)); */
                                    cout << ">>>>>>>>>" << isInSymbols(e.varName) << endl;

                                    symbols[tempIDcount] = e;
                                    tempIDcount++;
                                    outSymbols << e.varName << "\t" << e.type << endl;
                                    
                                    generateAsmDef(e1, e2.varName);
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
                                    
/*                                     symbols.insert(std::pair<int,element>(0,e)); */
                                    symbols[tempIDcount] = e;
                                    tempIDcount++;
                                    outSymbols << e.varName << "\t" << e.type << endl;
                                    
                                    s->push(e);
                                    
/*                                     generateAsmMul(e1.varName, e2.varName, e.varName); */
                                    generateAsmX(e1, e2, e.varName, "mul");

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

/*                                     symbols.insert(std::pair<int,element>(tempIDcount,e));  //albo ten sam KLUCZ  do mapy i nie mozna //albo wywolywanie tylko jeden raz */
                                    symbols[tempIDcount] = e;
                                    tempIDcount++;
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
                                    
/*                                         symbols.insert(std::pair<int,element>(tempIDcount,e)); */
                                        cout << ">>>>>>>>>ID" << isInSymbols(e.varName) << endl;
                                        
if(isInSymbols(e.varName))
                                        {
                                            cout << "Symbol <" << e.varName << "> juz znajduje sie w tablicy symboli.";
                                        }
                                        else
                                        {
                                            symbols[tempIDcount] = e;
                                            tempIDcount++;
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

void generateAll()
{
    stringstream ss;
    outAll << ".data" << "\n";
    
/*    for(int i = 0; i < symbols.size(); i++)
    {
        outAll << "\t" << symbols[i] << "" << "\n";
    }*/
    
    for (auto& t : symbols)
        outAll << "\t" << t.second.varName << ": \t" << ".word\t0" << "\n";
    
    outAll << ".text" << "\n";
    
    for(int i = 0; i < codeAsm->size(); i++)
    {
        outAll << "\t" << codeAsm->at(i);
    }
}

void generateAsm()
{
    for(int i = 0; i < codeAsm->size(); i++)
    {
        outAsm << codeAsm->at(i);
    }
}

void generateAsmDef(element variable1, string variable2)
{
    //tutaj rozroznic czy x = 5 czy x = y
    stringstream ss;
    
    if(variable1.type == types::lc)
    {
        ss << "li $t0, " << variable1.varName << "\t#type: \t" << (int)variable1.type << "\tdef to value\n";
    }
    if(variable1.type == types::id)
    {
        ss << "lw $t0, " << variable1.varName << "\t#type: \t" << (int)variable1.type << "\tdef to variable\n";
    }
    
    codeAsm->push_back(ss.str());
    ss.str("");
 
    ss << "sw $t0, " << variable2 << "\n\n";
    codeAsm->push_back(ss.str());
    ss.str("");
}

void generateAsmX(element variable1, element variable2, string result, string operation)
{
    stringstream ss;
    if(variable2.type == types::lc)
    {
        ss << "li $t0, " << variable2.varName << "\t#type: \t" << (int)variable2.type << "\t" << operation << " to value\n";
    }
    if(variable2.type == types::id)
    {
        ss << "lw $t0, " << variable2.varName << "\t#type: \t" << (int)variable2.type << "\t" << operation << " to variable\n";
    }
    
/*    ss << "lw $t0, " << variable2 << "\n";
    codeAsm->push_back(ss.str());
    ss.str("");*/
    
    ss << "\tli $t1, " << variable1.varName << "\n";
    codeAsm->push_back(ss.str());
    ss.str("");
    
    ss << operation << " $t0, $t0, $t1" << "\n";
    codeAsm->push_back(ss.str());
    ss.str("");
 
    ss << "sw $t0, " << result << "\n\n";
    codeAsm->push_back(ss.str());
    ss.str("");
}

void generateAsmPrint(element variable1) 
{
    stringstream ss;
    
    ss << "li $v0, 1\n";
    codeAsm->push_back(ss.str());
    ss.str("");
    
    ss << "li $a0, " << variable1.varName << "\n";
    codeAsm->push_back(ss.str());
    ss.str("");
 
    ss << "syscall\n\n";
    codeAsm->push_back(ss.str());
    ss.str("");
}

bool isInSymbols(string name)
{
    for (auto& t : symbols)
    {
        if(t.second.varName == name)
        {
            return true;    
        }
    }
    return false;
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
	generateAll();
	
	return 0;
}
