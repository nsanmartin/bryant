void obdd_destroy(obdd* root){
	if(root->root_obdd != NULL){
		obdd_node_destroy(root->root_obdd);
		root->root_obdd		= NULL;
	}
	root->mgr			= NULL;
	free(root);
}
