obdd_node*
obdd_mgr_mk_node (obdd_mgr* mgr, char* var,
                  obdd_node* high, obdd_node* low)
{
  uint32_t var_ID = dictionary_add_entry(mgr->vars_dict, var);
  obdd_node* new_node	= malloc(sizeof(obdd_node));
  new_node->var_ID	= var_ID;
  new_node->node_ID	= obdd_mgr_get_next_node_ID(mgr);
  new_node->high_obdd	= high;
  if(high != NULL)
    high->ref_count++;
  new_node->low_obdd	= low;
  if(low != NULL)
    low->ref_count++;
  new_node->ref_count	= 0;
  return new_node;
}
