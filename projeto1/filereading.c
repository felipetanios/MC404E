#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main (int argc,char *argv[]){
	//argc: numero de parametros do terminal
	// argv: vetor dos parametros (para criar os arquivos)
	FILE *entrada;
	char buffer[150];//linha do texto
	char *k;
	char *token;
	int flag_frase = 1;

	entrada = fopen(argv[1], "r");
	if (entrada == NULL){
		printf("ERROR on input file\n");
		return 0;;
	}
	do{
		k = fgets (buffer,150, entrada);
		if (k != NULL){
			token = strtok(k, " 	");
		
			do{
				if (!flag_frase){					
					printf("%s", token);
					token = strtok(NULL, " 	");
				}
				if (flag_frase){
					token = strtok(k, " 	");
					flag_frase = 0;
				}

			}while (token != NULL);
			
		}
	}while (k != NULL);

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
