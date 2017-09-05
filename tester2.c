#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <fcntl.h>
#include <unistd.h>
#include "obdd.h"
void print_node(obdd_node *n, int tab) ;

int main() {
        
        unsigned i;

        /* struct dictionary_t*d =  dictionary_create(); */
        /* dictionary_add_entry (d, "clave"); */
        /* dictionary_add_entry (d, "claveu"); */
        /* dictionary_add_entry (d, "clavsdfe"); */
        /* dictionary_add_entry (d, "clasdfve"); */

        /* obdd_mgr* mgr = obdd_mgr_create(); */
        /* struct dictionary_t *d0  = mgr -> vars_dict; */
        /* obdd_mgr_print(mgr); */
        /* obdd_mgr_destroy(mgr); */
        /* dictionary_destroy(d); */

        return 0;
}



void print_node(obdd_node *n, int tab) {
  printf("%*s_nodo_\n", tab, "");

  if (!n) {
    printf("%*sNULL\n", tab, "");
    return;
  }
  char * pattern =
    "%*svar id: %d\n"
    "%*snode id: %d\n"
    "%*sref count: %d\n";
  printf(pattern,
         tab, "", n->var_ID,
         tab, "", n->node_ID,
         tab, "", n->ref_count);
  tab <<= 2;
  print_node (n->high_obdd, tab); 
  print_node (n->low_obdd,tab);
   
}
