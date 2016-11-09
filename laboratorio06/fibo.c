#include <stdio.h>

int fib (int r1, int r2, int i){
    int aux;
    if (i == 0)
        return r1;
    else
        aux = r1;
        r1 = r1 + r2;
        r2 = aux;
        i -= 1;
        r1 = fib(r1, r2, i);
}

int main(){
    int i;
    int r1, r2;
    int ans;
    scanf("%d", &i);
    r1 = 1;
    r2 = 1;
    i = i - 2;
    if (i > 0)
        while (i > 
    else
        ans = r1;
    printf("\nresp: %d\n", ans);
    return 0;
}
