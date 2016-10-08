#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//struct de lista
typedef struct list{
	char instr[64];
	struct list *next;
}list;

typedef struct posicao{
	int posicao;
	char lado;
}posicao;

//funcao de inserir na lista
void append_list (list **l, char *buffer);



int main (int argc,char *argv[]){
	//argc: numero de parametros do terminal
	// argv: vetor dos parametros (para criar os arquivos)

	FILE *entrada; //arquivo de entrada em linguagem de montagem
	char buffer[150];//linha do texto
	char *k;
	char *token;
	list **rotulos = malloc (sizeof (list*)); //lista de rotulos
	posicao PC; //marcador da posicao da memoria que vai ser escrita
	int linha = 0; //contador de qual linha esta no arquivo
	int flag_frase = 1;

	//o programa comeca a ser escrito a partir da posicao zero a nao ser que alguma diretiva faca o contrario
	PC.posicao = 0;
	PC. lado = 'e';

	//le o arquivo de entrada
	entrada = fopen(argv[1], "r");

	//testa se o arquivo de entrada realmente existe
	if (entrada == NULL){
		printf("ERROR on input file\n");
		return 0;
	}

	do{
		//le uma linha
		linha ++;
		k = fgets (buffer,150, entrada);
		if (k != NULL){
			token = strtok(k, " 	");
			//separa palavra por palavra de cada linha
			do{
				if (token != NULL && !flag_frase){

					printf("%s\n", token);
					printf("%d\n", strlen(token));
					printf("%d\n", strlen(".word"));
					
					//se eh uma diretiva
					if (token[0] == '.'){
						if (token == ".org"){}
						else if (token == ".word" || token == ".word " || token == ".word	"){
							printf(".word\n");
						}
						else if (token == ".align"){
							printf(".align\n");
						}
						else if (token == ".wfill"){
							printf(".wfill\n");
						}
						else if (token == ".skip"){
							printf(".skip\n");
						}
						else if (buffer == ".set"){
							printf(".set\n");
						}
						else{
							printf("ERROR in line %d\n", linha);
							printf("%s is not a valid directive\n", token);					
						}
					}
					else
						printf("nao eh diretiva\n");
				}

				if (!flag_frase){
					token = strtok(NULL, " ");
				}
				if (flag_frase){
					token = strtok(k, " ");
					flag_frase = 0;
				}

				
			}while (token != NULL);
			
		}
	}while (k != NULL);


/*	
		//se eh uma diretiva
			if (token[0] == '.'){
				if (token == ".org"){}
				else if (token == ".word"){
					printf(".word\n");
				}
				else if (token == ".align"){
					printf(".align\n");
				}
				else if (token == ".wfill"){
					printf(".wfill\n");
				}
				else if (token == ".skip"){
					printf(".skip\n");
				}
				else if (buffer == ".set"){
					printf(".set\n");
				}
				else{
					printf("ERROR in line %d", linha);
				}
			}*/

	//se o nome do arquivo de saida nao esta como parametro
	if (argc == 2){
		printf("imprime mapa de memoria \n");
	}


	//se o nome do arquivo de saida eh parametro
	if (argc == 3){
		printf("salva o arquivo de mapa de memoria com o nome %s", argv[2]);
	}

	return 0;
}



void append_list (list **l, char *buffer){
	list *k;
	list *aux;

	k = malloc(sizeof(list));
	strcpy(k->instr, buffer);
	k->next = NULL;

	if (*l == NULL)
		(*l) = k;

	else{
		aux = *l;
		while (aux->next != NULL)
			aux = aux->next;
		aux->next = k;

	}
	
}
