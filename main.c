#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <fcntl.h>
#include <unistd.h>
#include "obdd.h"

char *formulasFile  =  "formulas.txt";

void print_sat_y_tau (obdd * o) ;

//TODO: implementar
void run_tests(){
	char * linea = "\n-------------------------------------------------------------";
	obdd_mgr* new_mgr	= obdd_mgr_create();
	
	obdd* x1 = obdd_mgr_var(new_mgr, "x1");
	obdd* x2 = obdd_mgr_var(new_mgr, "x2");
	
	puts(linea);
	//2.1
	obdd *disyuncion_1 = obdd_apply_or (x1, x2);

	puts("2.1\tx1 || x2\n");
	obdd_print (disyuncion_1);
	print_sat_y_tau (disyuncion_1);
	puts(linea);
	//2.2
	obdd *conjuncion_2 = obdd_apply_and (x1, x2);
	puts("2.2\tx1 && x2\n");
	obdd_print (conjuncion_2);
	print_sat_y_tau (conjuncion_2);
	puts(linea);
	//2.3
	obdd *not_x1 = obdd_apply_not (x1);
	obdd *si_y_no_3 =  obdd_apply_and (x1, not_x1);
	puts("2.3\tx1 && ~x1\n");
	obdd_print (si_y_no_3);
	print_sat_y_tau (si_y_no_3);
	puts(linea);

	//2.4
	obdd* not_conj = obdd_apply_not (conjuncion_2);
	obdd *conj_impl_4 = obdd_apply_or (not_conj, x1);
	puts("2.4\t(x1 && x2) -> x1\n");
	obdd_print (conj_impl_4);
	print_sat_y_tau (conj_impl_4);
	puts(linea);

	//2.5
	obdd *not_eq = obdd_apply_xor (x2, si_y_no_3);
	obdd *not_not_eq = obdd_apply_not (not_eq);
	obdd *existencial_5 = obdd_exists (not_not_eq, "x2");
	puts("2.5\t(existe x2) : x2 <=> (x1 && ~x1)\n");
	obdd_print (existencial_5);
	print_sat_y_tau (existencial_5);
	puts(linea);


        obdd_destroy (x1);
        obdd_destroy (x2);
        obdd_destroy (disyuncion_1 );
        obdd_destroy (conjuncion_2 );
        obdd_destroy (not_x1 );
        obdd_destroy (si_y_no_3 );
        obdd_destroy (not_conj);
        obdd_destroy (conj_impl_4 );
        obdd_destroy (not_eq );
        obdd_destroy (not_not_eq );
        obdd_destroy (existencial_5 );
        obdd_mgr_destroy (new_mgr);        

}

int main (void){
	run_tests();
	int save_out = dup(1);
	remove(formulasFile);
	int pFile = open(formulasFile, O_RDWR|O_CREAT|O_APPEND, 0600);
	if (-1 == dup2(pFile, 1)) { perror("cannot redirect stdout"); return 255; }
	run_tests();
	fflush(stdout);
	close( pFile );
	dup2(save_out, 1);
	return 0;    
}


void print_sat_y_tau (obdd * o) {
	printf("\nLa formula es %s y %s",
	       is_sat (o -> mgr, o -> root_obdd) ? "satisfacible" 
	       : "no satisfacible (contradiccion)",
	       is_tautology (o -> mgr, o -> root_obdd) ? "tautologia" : "no tautologia");
	
}
