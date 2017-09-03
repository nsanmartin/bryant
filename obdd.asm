;; -*- mode:nasm -*-    
extern free
extern malloc
extern dictionary_add_entry
extern  obdd_mgr_get_next_node_ID
;; OBDD MANAGER
%define MNG_ID_OFFSET 0
%define MNG_GREATEST_NODE_ID_OFFSET 4
%define MNG_GREATEST_VAR_ID_OFFSET 8
%define MNG_TRUE_OBDD_OFFSET 12
%define MNG_FALSE_OBDD_OFFSET 20
%define MNG_VARS_DICT_OFFSET 28
%define MNG_SIZE 36
        
%define MNG_ID(ptr) [ptr]
%define MNG_GREATEST_NODE_ID(ptr) [ptr + MNG_GREATEST_NODE_ID_OFFSET]
%define MNG_GREATEST_VAR_ID(ptr) [ptr + MNG_GREATEST_VAR_ID_OFFSET]
%define MNG_TRUE_OBDD(ptr) [ptr + MNG_TRUE_OBDD_OFFSET]
%define MNG_FALSE_OBDD(ptr) [ptr + MNG_FALSE_OBDD_OFFSET]
%define MNG_VARS_DICT(ptr) [ptr + MNG_VARS_DICT_OFFSET ]

;; OBDD NODE
%define OBDD_NODE_VAR_ID_OFFSET 0 
%define OBDD_NODE_NODE_ID_OFFSET 4
%define OBDD_NODE_REF_COUNT_OFFSET 8
%define OBDD_NODE_HIGH_OBDD_OFFSET 12
%define OBDD_NODE_LOW_OBDD_OFFSET 20
%define OBDD_NODE_SIZE 28
        
%define OBDD_NODE_VAR_ID(ptr) [ptr + OBDD_NODE_VAR_ID_OFFSET]
%define OBDD_NODE_NODE_ID(ptr) [ptr + OBDD_NODE_NODE_ID_OFFSET]
%define OBDD_NODE_REF_COUNT(ptr) [ptr +OBDD_NODE_REF_COUNT_OFFSET]
%define OBDD_NODE_HIGH(ptr) [ptr + OBDD_NODE_HIGH_OBDD_OFFSET]
%define OBDD_NODE_LOW(ptr) [ptr + OBDD_NODE_LOW_OBDD_OFFSET]

;; OBDD
%define OBDD_MNG_OFFSET 0
%define OBDD_ROOT_OFFSET 8
%define OBDD_SIZE 16
        
%define OBDD_MNG(ptr) [ptr + OBDD_MNG_OFFSET]
%define OBDD_ROOT(ptr) [ptr + OBDD_ROOT_OFFSET]
        
        

        
global obdd_mgr_mk_node
;; /** implementar en ASM
;; obdd_node*
;;obdd_mgr_mk_node(obdd_mgr* mgr, char* var,
        ;          obdd_node* high, obdd_node* low){

;; 	uint32_t var_ID	= dictionary_add_entry(mgr->vars_dict, var);
;; 	obdd_node* new_node	= malloc(sizeof(obdd_node));
;; 	new_node->var_ID	= var_ID;
;; 	new_node->node_ID	= obdd_mgr_get_next_node_ID(mgr);
;; 	new_node->high_obdd	= high;
;; 	if(high != NULL)
;; 		high->ref_count++;
;; 	new_node->low_obdd	= low;
;; 	if(low != NULL)
;; 		low->ref_count++;
;; 	new_node->ref_count	= 0;
;; 	return new_node;
;; }
;; **/

obdd_mgr_mk_node:
        push rbp
        mov rbp, rbp            
        push rbx
        push r12
        push r14
        push r15                ; pila alineada

        mov rbx, rdi
        mov r12, rsi
        mov r14, rdx
        mov r15, rcx
        ; tenemos:
        ; rbx <- &mgr
        ; r12 <- var
        ; r14 <- &high
        ; r15 <- &low

        ; nuevo nodo
        mov rdi, OBDD_NODE_SIZE
        call malloc             ; rax <- &nuevo nodo
.set_high:
        mov OBDD_NODE_HIGH(rax), r14
        cmp r14, 0
        je .set_low
        inc dword OBDD_NODE_REF_COUNT(r14) 
.set_low: 
        mov OBDD_NODE_LOW(rax), r15
        cmp r15, 0
        je .set_var_id
        inc dword OBDD_NODE_REF_COUNT(r15)
.set_var_id:
        mov r14, rax            ; guardo el puntero al nodo nuevo
        mov rdi, MNG_VARS_DICT(rbx) ; prim param a add_entry
        mov rsi, r12            ; seg param  a add_entry
        call dictionary_add_entry
        mov OBDD_NODE_VAR_ID(r14), rax
.set_node_id:
        mov rdi, rbx            ;1er param es mgr
        call obdd_mgr_get_next_node_ID
        mov OBDD_NODE_NODE_ID(r14), rax
.return:
        mov rax, r14
        pop r15
        pop r14
        pop r12
        pop rbx
        pop rbp
        
        ret 

global obdd_node_destroy
obdd_node_destroy:
        ret

global obdd_create
obdd_create:
        push rbp
        mov rbp, rsp
        push rbx
        push r12

        mov rbx, rdi            ; rbx <- mgr
        mov r12, rsi            ; r12 <- root

        mov rdi, OBDD_SIZE
        call malloc
        mov OBDD_MNG(rax), rbx
        mov OBDD_ROOT(rax), r12

        pop r12
        pop rbx
        pop rbp
        ret

global obdd_destroy
obdd_destroy:
        push rbp
        mov rbp, rsp
        push rbx
        push r12

        mov r12, rdi            ; r12 <- &root 
        mov rbx, OBDD_ROOT(rdi) ; rbx <- root -> root_obdd
        cmp rbx, 0x0
        je .return
        mov rdi, rbx
        call obdd_node_destroy
        mov qword OBDD_ROOT(r12), 0x0
.return:
        mov qword OBDD_MNG(r12), 0x0
        mov rdi, r12
        call free
        
        pop r12
        pop rbx
        pop rbp
        ret

global obdd_node_apply
obdd_node_apply:
        ret

global is_tautology
is_tautology:
        ret

global is_sat
is_sat:
        ret

;; uint32_t str_len(char* a);
global str_len
str_len:
        xor rax, rax            ; en rax <- 0
.loop:
        mov cl, [rdi + rax]     ; cl <- next char
        cmp cl, 0               
        je .return
        inc rax
        jmp .loop
.return:
        ret

;; char* str_copy(char* a) ;
global str_copy
str_copy:
                push rbp                
        mov rbp, rsp
        push rbx
        push r12                ; pila alineada a 16
        
        mov rbx, rdi            ; guardo la str a copiar en rbx

        call str_len            ; obtengo len en eax (32 bits)
        xor rdi, rdi
        mov edi, eax            ; paso len como parametro a malloc
        xor r12, r12
        mov r12d, eax           ; y lo guardo tambien para despues
        inc edi                 ; el ultimo byte es para el 0
        call malloc             ; ahora tengo en rax el puntero a la copia
        mov rcx, r12            ; rcx <- len
        mov byte [rax + rcx], 0 ; la string termina en 0
.loop:
        jrcxz .return
        mov r12b, [rbx + rcx - 1]
        mov [rax + rcx - 1], r12b 
        dec rcx
        jmp .loop

.return:
        pop r12
        pop rbx
        pop rbp
        ret

;; int32_t str_cmp(char* a, char* b);
global str_cmp
str_cmp:
        push rbp
        mov rbp, rsp
        push rbx
        xor rax, rax
.loop:

        mov bl, [rdi + rax]     ; en rdi esta el puntero al string
        mov cl, [rsi + rax]     ; en rsi al segundo
        cmp bl, cl
        jg .mayor
        jl .menor
        cmp cl, 0
        je .igual
        inc rax
        jmp .loop

.mayor:
        mov rax, -1
        jmp .return

.menor: mov rax, 1
        jmp .return
        
.igual:
        mov rax, 0
        jmp .return
.return:
        pop rbx
        pop rbp
	ret
