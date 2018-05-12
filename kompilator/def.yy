%{
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
    id = 2,
    tk = 3
};

struct element {
    types type;
    string varName;
    vals val;
};

stack <element> * s = new stack<element>;
map <int, element> symbols;
vector <string> * codeAsm = new vector <string>();

string lastIfOperator;

fstream outTriples("outTriples.txt",std::ios::out);
fstream outLexValue("outLexValue.txt",std::ios::out);
fstream outSymbols("outSymbols.txt",std::ios::out);
fstream outAsm("outAsm.txt",std::ios::out);
fstream outAll("outAll.asm",std::ios::out);

void addFunction();
void subFunction();
void mulFunction();
void divFunction();
void defFunction();
void writeFunction();
void readFunction();

void ifStartFunction();
void conditionFunction();
void conditionOperatorFunction();
void foo();

void idFunction(string param);
void lzFunction(float param);
void lcFunction(int param);
void tkFunction(string param);

void generateAsmAdd(string variable1, string variable2, string result);
void generateAsmDef(element variable1, string variable2);
void generateAsmMul(string variable1, string variable2, string result);
void generateAsmX(element variable1, element variable2, string result, string operation);
void generateAsmPrint(element variable1);
void generateAsmRead(element variable1);
void generateAsmCondition(element variable1, element variable2);

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
%token <text> ID TK
%token <ival> LC
%token <dval> LZ
%left '+' '-'
%left '*' '/'
%start start
%%
start
        :code_block
        ;
code_block
        :code_block single_instruction  {cout << "\t\t\tcode_block single_instruction" << endl;}
        |single_instruction             {cout << "\t\t\tsingle_instruction" << endl;}
        ;
single_instruction
        :wyr                            {cout << "\t\t\twyr" << endl;}
        |if_expr                        { ifStartFunction(); }
        ;
if_expr
        :if_begin if_mid code_block '}'         {cout << ">>>>>>>>>>>>>>>>>>>>>>>IF" << endl;}
        |if_begin if_mid code_block '}' if_else {cout << ">>>>>>>>>>>>>>>>>>>>>>>IF-else" << endl;}
        ;
if_begin
        :JEZELI '(' cond_expr ')' {cout << ">>>>>>>>>>>>>>>>>>>>>>>IF - poczatek" << endl;}
        ;
if_mid  
        :TO '{'                         { foo(); }
        ;
if_else
        :JEZELINIE '{' code_block '}'
        ;
cond_expr
        :wyr
        |wyr cond_operator wyr          { conditionFunction(); }
        ;
cond_operator
        :LT                             { conditionOperatorFunction(); }
        |GT                     {} //outLexValue << "operator wiekszosci - >" << end;} 
        |EQ                     {printf("operator rownosci - ==\n");} 
        |NE                     {printf("operator nierownosci !=\n");} 
        ;
wyr
	:wyr '+' skladnik	{ addFunction(); }
	|wyr '-' skladnik	{ subFunction(); }
        |PISZ wyr               { writeFunction(); }
        |CZYTAJ wyr             { readFunction(); }
        |wyr '=' wyr            { defFunction(); }
	|skladnik		{printf("wyrazenie pojedyncze \n");}
	;
skladnik
	:skladnik '*' czynnik	{ mulFunction(); }
	|skladnik '/' czynnik	{ divFunction(); }
	|czynnik		{printf("skladnik pojedynczy \n");}
	;
czynnik
	:ID			{ idFunction($1); }
        |LZ                     { lzFunction($1); }
	|LC			{ lcFunction($1); }
        |TK                     { tkFunction($1); }
                                
	|'(' wyr ')'		{printf("wyrazenie w nawiasach\n");}
	;
%%
void idFunction(string param)
{
    
/*                                     printf("czynnik znakowy (zmienna) - %s\n",$1);  */
/*                                     fprintf(yyout, "%s ", $1); */
/*                                     printf("\n>>PUSHING AT STACK<<\n"); */
                                    
                                    element e;
                                    e.type = id;
                                    
                                    stringstream ss;
                                    ss << param;
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
void lzFunction(float param)
{
    
/*                                     printf("czynnik liczba zmiennoprzecinkowa %lf\n",$1);  */
/*                                     fprintf(yyout, "%lf ", $1); */
/*                                     printf("\n>>PUSHING AT STACK<<\n"); */
/*                                    std::stringstream ss;
                                    ss << $1;
                                    s->push(ss.str());*/
}
void lcFunction(int param)
{

/*                                     printf("czynnik liczba całkowita - %d\n",$1);  */
/*                                     fprintf(yyout, "%d ", $1);  */
                                    printf("\n>>PUSHING AT STACK<<\n");
                                    
                                    element e;
                                    e.type = lc;
                                    e.val.intVal = param;
                                    
                                    stringstream ss;
                                    ss << param;
                                    e.varName = ss.str();

                                    s->push(e);
}
void tkFunction(string param)
{

                                    cout << "czynnik - tekst" << endl;
                                    element e;
                                    e.type = tk;
                                    //e.val.textVal = param;
                                    // cannot convert ‘std::__cxx11::string {aka std::__cxx11::basic_string<char>}’ to ‘char*’ in assignment

                                    
                                    stringstream ss;
                                    ss << param;
                                    e.varName = ss.str();

                                    s->push(e);
}


void addFunction()
{
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
void subFunction()
{
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
void mulFunction()
{
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
void divFunction()
{
    
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
void defFunction()
{
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
void writeFunction()
{
    element e1 = s->top();
    s->pop();
    generateAsmPrint(e1);
}
void readFunction()
{
    element e1 = s->top();
    s->pop();
    generateAsmRead(e1);
}
void ifStartFunction()
{
    cout << ">>>>>>>>>>>>>>>>>>>> IF-START" << endl;
/*    cout << "STACK SIZE: " << s->size() << endl;
    
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
    
    //DODAWANIE DO TABLICY SYMBOLI TUTAJ
/*                                     symbols.insert(std::pair<int,element>(tempIDcount,e)); */
/*    cout << ">>>>>>>>>" << isInSymbols(e.varName) << endl;

    symbols[tempIDcount] = e;
    tempIDcount++;
    outSymbols << e.varName << "\t" << e.type << endl;
    */
/*     generateAsmDef(e1, e2.varName); */
}
void conditionFunction()
{
    element e1;
    e1 = s->top(); 
    s->pop();
    
    element e2;
    e2 = s->top();
    s->pop();
    
    cout << "\t\t\t <><><><><><><><><>" << e1.varName << endl;
    cout << "\t\t\t <><><><><><><><><>" << e2.varName << endl;
    generateAsmCondition(e1, e2);
}
void conditionOperatorFunction()
{
    cout << "\t\t\t <><><><><><><><><>operator mniejszosci - <" << endl;
    
    lastIfOperator = "LT";
}
void foo()
{
        stringstream ss;
    ss << lastIfOperator << " $t2, $t3, LBL5" << "\n\n";
    //TODO: tutaj powinno być odpowiednio BGE
    codeAsm->push_back(ss.str());
    ss.str("");
}




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
    
    if(variable1.type == types::lc)
    {
        ss << "\tli $t1, " << variable1.varName << "\t#type: \t" << (int)variable1.type << "\t" << operation << " to value\n";
    }
    if(variable1.type == types::id)
    {
        ss << "\tlw $t1, " << variable1.varName << "\t#type: \t" << (int)variable1.type << "\t" << operation << " to variable\n";
    }
    
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
    
    if(variable1.type == types::lc)
    {
        ss << "li $a0, " << variable1.varName << "\t#type: \t" << (int)variable1.type << "\tprint - value\n";
    }
    if(variable1.type == types::id)
    {
        ss << "lw $a0, " << variable1.varName << "\t#type: \t" << (int)variable1.type << "\tprint - variable\n";
    }
 
    ss << "\tsyscall\n\n";
    codeAsm->push_back(ss.str());
    ss.str("");
}
void generateAsmRead(element variable1)
{
    stringstream ss;
    
    ss << "li $v0, 5\n";
    codeAsm->push_back(ss.str());
    ss.str("");
    
    ss << "syscall\n";
    codeAsm->push_back(ss.str());
    ss.str("");
    
/*   if(variable1.type == types::lc)
    {*/
        ss << "sw $v0, " << variable1.varName << "\t#type: \t" << (int)variable1.type << "\tread - value\n\n";
/*     } */
/*    if(variable1.type == types::id)
    {
        ss << "lw $a0, " << variable1.varName << "\t#type: \t" << (int)variable1.type << "\tprint - variable\n";
    }*/
    
    codeAsm->push_back(ss.str());
    ss.str("");
}
void generateAsmCondition(element variable1, element variable2)
{
    stringstream ss;
    
    ss << "lw $t2, " << variable2.varName << "\n";
    codeAsm->push_back(ss.str());
    ss.str("");
    
    ss << "lw $t3, " << variable1.varName << "\n";
    codeAsm->push_back(ss.str());
    ss.str("");
    
/*    ss << "sw $v0, " << variable1.varName << "\t#type: \t" << (int)variable1.type << "\tread - value\n\n";
    codeAsm->push_back(ss.str());
    ss.str("");*/
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
