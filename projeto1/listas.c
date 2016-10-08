#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct list{
	char instr[64];
	struct list *next;
}list;

void append_list (list **l, char *buf){
	list *k;
	list *aux;

	k = malloc(sizeof(list));
	strcpy(k->instr, buf);
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


int main (int argc,char *argv[]){
	list **root;
	list *end;
	char s[64];

	root = malloc (sizeof (list*));

	while (s[1] != '\0'){
		fgets (s, sizeof(s)/sizeof(char), stdin);
		printf("%s\n", s);
		append_list(root, s);
		
	}
	end = *root;
	printf("acabou a aquisicao\n");
	while(end != NULL){
		printf("%s \n", end->instr);
		end = end->next;
	}

}