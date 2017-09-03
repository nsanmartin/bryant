#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <fcntl.h>
#include <unistd.h>
#include "obdd.h"
void print_node(obdd_node *n, int tab) ;

int main() {
        
        unsigned i;
        char * pattern = "elm: %s = %d\n";

        struct dictionary_t*d =  dictionary_create();
        dictionary_add_entry (d, "clave");
        dictionary_add_entry (d, "claveu");

        dictionary_add_entry (d, "clavsdfe");
        dictionary_add_entry (d, "clasdfve");

        /* for (i = 0; i< 66; i++) */
        /*   dictionary_add_entry (d, "claves"); */

        obdd_mgr* mgr = obdd_mgr_create();

        obdd_node *n = obdd_mgr_mk_node (mgr, "string", NULL, NULL);

        struct dictionary_t *d0  = mgr -> vars_dict;
        printf("size: %d\n"
               "max size: %d\n",d0 ->size, d0->max_size      );
        
        for (i = 0; i < d0 ->size; i++) {
          printf (pattern,
                  d0 -> entries[i].key,
                  d0 -> entries[i].value);
        }
        char *strg = mgr -> vars_dict -> entries[0].key;
        printf("mgr..: %s\n",strg);



        print_node(n, 1);
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
