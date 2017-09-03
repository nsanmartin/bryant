#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <fcntl.h>
#include <unistd.h>
#include "obdd.h"

int main() {

        struct dictionary_t*d =  dictionary_create();
        dictionary_add_entry (d, "clave");
        dictionary_add_entry (d, "claveu");

        dictionary_add_entry (d, "clavsdfe");
        dictionary_add_entry (d, "clasdfve");



        obdd_mgr* mgr = obdd_mgr_create();
        obdd_mgr_mk_node (mgr, "string", NULL, NULL);


        char * pattern = "elm: %s = %d\n";

        
        unsigned i;
        
        for (i = 0; i < d -> size; i++)  
                printf (pattern,
                        d -> entries[i].key,
                        d -> entries[i].value);
	return 0;
}
