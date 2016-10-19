#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//struct de lista
typedef struct list{
	char rotulo[64];
	int endereco;
	char lado;
	struct list *next;
}list;


typedef struct posicao{
	int posicao;
	char lado;
}posicao;


//funcao de inserir na lista
void append_list (list **l, char *buffer, int end, char la);



int main (int argc,char *argv[]){
	//argc: numero de parametros do terminal
	// argv: vetor dos parametros (para criar os arquivos)

	FILE *entrada; //arquivo de entrada em linguagem de montagem
	char buffer[150];//linha do texto
	char *k;
	list **rotulos = malloc (sizeof (list*)); //lista de rotulos
	posicao PC; //marcador da posicao da memoria que vai ser escrita
	int linha = 0; //contador de qual linha esta no arquivo
	//variaveis de contagem: i e j, contar o tamanho da palavra, p para copia da palavra, l para conferencia de rotulo
	int i, j, p, l;
	char *palavra;
	int flag_org = 0;
	int flag_instrucao = 0; //flag que fala se foi inserido uma instrucao anteriormente
	char mem_map[1024][13];
	char *aux_tol;

	long int numero_retorno;




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

	k = fgets (buffer,150, entrada);

	//primeira leitura do arquivo
	
	while (k != NULL){
		linha ++;
		printf("qual linha esta: %03X\n", linha);
		printf("%s\n", k );
		
		//enquanto esta em uma linha
		for(i = 0;i < strlen(k) - 1;){

			//se eh um comentario, vai direto para a proxima linha
			if (k[i] == '#'){
				break;
			}
			
			//se eh espaco pula ate a proxima palavra
			if (k[i] == ' ' || k[i] == '\t'){
				i++;
			}

			//se eh uma palavra ou numero possivel
			else{
				j = i;
				//mede o tamanho de uma palavra, o tamanho dela vai ser j - i
			
				while (k[j] != ' ' && k[j] != '\t' &&  (j <  strlen(k) - 1)){
						j++;
				}
				
				palavra = malloc (sizeof(char) * (j - i));
				for (p = 0; i < j; i++, p++)
					palavra[p] = k[i];


				printf("%s\n", palavra);

				//neste ponto a variavel palavra contem um rotulo, instrucao, diretiva ou variavel

				//se eh uma instrucao
				if (palavra[0]  >= 'A' && palavra[0] <= 'Z'){
					if (flag_instrucao){
						printf("ERROR in line %d\n", linha);
						printf("multiple instructions on the same line!\n");
					}
					flag_instrucao = 1;
					if (!strcmp(palavra, "LD")){
						printf("LD\n");
					}
					else if (!strcmp(palavra, "LD-")){
						printf("LD-\n");
					}
					else if (!strcmp(palavra, "LD|")){
						printf("LD|\n");
					}
					else if (!strcmp(palavra, "LDmq")){
						printf("LDmq\n");
					}
					else if (!strcmp(palavra, "LDmq_mx")){
						printf("LDmq_mx\n");
					}
					else if (!strcmp(palavra, "ST")){
						printf("ST\n");
					}
					else if (!strcmp(palavra, "JMP")){
						printf("JMP\n");
					}
					else if (!strcmp(palavra, "JUMP+")){
						printf("JUMP+\n");
					}
					else if (!strcmp(palavra, "ADD")){
						printf("ADD\n");
					}
					else if (!strcmp(palavra, "ADD|")){
						printf("ADD|\n");
					}
					else if (!strcmp(palavra, "SUB")){
						printf("SUB\n");
					}
					else if (!strcmp(palavra, "SUB|")){
						printf("SUB|\n");
					}
					else if (!strcmp(palavra, "MUL")){
						printf("MUL\n");
					}
					else if (!strcmp(palavra, "DIV")){
						printf("DIV\n");
					}
					else if (!strcmp(palavra, "LSH")){
						printf("LSH\n");
					}
					else if (!strcmp(palavra, "RSH")){
						printf("RSH\n");
					}
					else if (!strcmp(palavra, "STaddr")){
						printf("STaddr\n");
					}
					else{
						flag_instrucao = 0;
						printf("ERROR in line %d\n", linha);
						printf("%s is not a valid mnemonic!\n", palavra);					
					}

				}
				
				//se eh uma diretiva
				else if (palavra[0] == '.'){
					printf("eh diretiva\n");
					
					if (!strcmp(palavra, ".org")){
						flag_org = 1;
					}
					else if (!strcmp(palavra,".word")){
						printf(".word\n");
					}
					else if (!strcmp(palavra, ".align")){
						printf(".align\n");
					}
					else if (!strcmp(palavra, ".wfill")){
						printf(".wfill\n");
					}
					else if (!strcmp(palavra, ".skip")){
						printf(".skip\n");
					}
					else if (strcmp(palavra, ".set")){
						printf(".set\n");
					}
					else{
						printf("ERROR in line %d\n", linha);
						printf("%s is not a valid mnemonic!\n", palavra);					
					}
				}

				//se for um numero depois de ORG
				else if (flag_org){
					if (palavra[0] >= '0' && palavra[0] <= '9'){
						numero_retorno = strtol(palavra, &aux_tol, 0);
						printf("%ld\n", numero_retorno);

					}
					else{
						printf("ERROR in line %d\n", linha);
						printf("%s is not a valid number!\n", palavra);
						break;
					}
					flag_org = 0;
				}

				//se a ultima coisa foi uma instrucao que precisa de uma posicao de memoria ou constante depois;
				else if (flag_instrucao){

					printf("a ultima coisa foi uma instrucao, essa palavra eh %s\n", palavra);
				}

				//se ela for um rotulo
				else{
					printf("eh um rotulo\n");
					//se tiver ":" em qualquer lugar do rotulo menos no ultimo caractere
					for (l = 0; l < strlen(palavra) - 2; l++){
						if (palavra[l] == ':'){
							printf("ERROR in line %d\n", linha);
							printf("%s is not a valid rotule name!\n", palavra);
							break;
						}
					}
					//se o ultimo caractere do rotulo nao for ":"
					if (palavra[strlen(palavra) - 1] != ':'){
						printf("ERROR in line %d\n", linha);
						printf("%s is not a valid rotule name!\n", palavra);				
					}
					//se for um rotulo valido
					else{
					}
				}


				free (palavra);
				
			}

			

		}
			k = fgets (buffer,150, entrada);
	}



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



void append_list (list **l, char *buffer, int end, char la){
	list *k;
	list *aux;

	k = malloc(sizeof(list));
	strcpy(k->rotulo, buffer);
	k->endereco = end;
	k->lado = la;
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

