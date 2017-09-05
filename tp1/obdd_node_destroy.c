void obdd_node_destroy(obdd_node* node){
	if(node->ref_count == 0){
		if(node->high_obdd != NULL){
			obdd_node* to_remove = node->high_obdd;
			node->high_obdd	= NULL;
			to_remove->ref_count--;
			obdd_node_destroy(to_remove);
		}
		if(node->low_obdd != NULL){
			obdd_node* to_remove = node->low_obdd;
			node->low_obdd	= NULL;
			to_remove->ref_count--;
			obdd_node_destroy(to_remove);
		}
		node->var_ID	= 0;
		node->node_ID	= 0;
		free(node);
	}
}

