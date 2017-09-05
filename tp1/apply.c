obdd*
obdd_apply (bool (*apply_fkt)(bool,bool),
            obdd *left, obdd* right)
{
    if(left->mgr != right->mgr)
        return NULL;
	
    obdd* applied_obdd
        = obdd_create(left->mgr,
                      obdd_node_apply(apply_fkt,
                                      left->mgr,
                                      left->root_obdd,
                                      right->root_obdd));
    obdd_reduce(applied_obdd);
    return applied_obdd;
}	


obdd_node*
obdd_node_apply (bool (*apply_fkt)(bool,bool),
                 obdd_mgr* mgr,
                 obdd_node* left_node,
                 obdd_node* right_node){

    uint32_t left_var_ID =  left_node->var_ID;
    uint32_t right_var_ID =  right_node->var_ID;

    char* left_var =
        dictionary_key_for_value(mgr->vars_dict,left_var_ID);
    char* right_var =
        dictionary_key_for_value(mgr->vars_dict,right_var_ID);

    bool is_left_constant  = is_constant(mgr, left_node);
    bool is_right_constant  = is_constant(mgr, right_node);

    if ( is_left_constant && is_right_constant ) {
      
        if ( (*apply_fkt)(is_true(mgr, left_node), is_true(mgr, right_node))) {
          
            return obdd_mgr_mk_node(mgr, TRUE_VAR, NULL, NULL);
            
        } else {
          
            return obdd_mgr_mk_node(mgr, FALSE_VAR, NULL, NULL);
        }
    }

    obdd_node* applied_node;
    
    if ( is_left_constant ) {
        applied_node =
            obdd_mgr_mk_node (mgr, right_var, 
                              obdd_node_apply(apply_fkt,
                                              mgr,
                                              left_node,
                                              right_node->high_obdd),
                              obdd_node_apply(apply_fkt,
                                              mgr,
                                              left_node,
                                              right_node->low_obdd));
    } else if ( is_right_constant ) {

        applied_node =
            obdd_mgr_mk_node (mgr,
                              left_var, 
                              obdd_node_apply (apply_fkt,
                                               mgr,
                                               left_node->high_obdd,
                                               right_node), 
                              obdd_node_apply(apply_fkt,
                                              mgr,
                                              left_node->low_obdd,
                                              right_node));
    } else if ( left_var_ID == right_var_ID ) {

        applied_node =
            obdd_mgr_mk_node (mgr,
                              left_var, 
                              obdd_node_apply (apply_fkt,
                                               mgr,
                                               left_node->high_obdd,
                                               right_node->high_obdd), 
                              obdd_node_apply (apply_fkt,
                                               mgr,
                                               left_node->low_obdd,
                                               right_node->low_obdd));
    } else if ( left_var_ID < right_var_ID ) {
        applied_node
            = obdd_mgr_mk_node (mgr,
                                left_var, 
                                obdd_node_apply (apply_fkt,
                                                 mgr,
                                                 left_node->high_obdd,
                                                 right_node), 
                                obdd_node_apply (apply_fkt,
                                                 mgr,
                                                 left_node->low_obdd,
                                                 right_node));
    } else {
        applied_node
            = obdd_mgr_mk_node (mgr,
                                right_var, 
                                obdd_node_apply (apply_fkt,
                                                 mgr,
                                                 left_node,
                                                 right_node->high_obdd), 
                                obdd_node_apply (apply_fkt,
                                                 mgr,
                                                 left_node,
                                                 right_node->low_obdd));
    }

    return applied_node; 
}
