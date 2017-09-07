;; -*- mode:nasm -*-    
extern free
extern malloc
extern dictionary_add_entry
extern obdd_mgr_get_next_node_ID
extern dictionary_key_for_value
extern is_constant
extern is_true
extern obdd_mgr_destroy

;; OBDD MANAGER
%define MGR_ID_OFFSET 0
%define MGR_GREATEST_NODE_ID_OFFSET 4
%define MGR_GREATEST_VAR_ID_OFFSET 8
%define MGR_TRUE_OBDD_OFFSET 12
%define MGR_FALSE_OBDD_OFFSET 20
%define MGR_VARS_DICT_OFFSET 28
%define MGR_SIZE 36
        
%define MGR_ID(ptr) dword [ptr]       
%define MGR_GREATEST_NODE_ID(ptr) dword [ptr + MGR_GREATEST_NODE_ID_OFFSET]
%define MGR_GREATEST_VAR_ID(ptr) dword [ptr + MGR_GREATEST_VAR_ID_OFFSET]
%define MGR_TRUE_OBDD(ptr) qword [ptr + MGR_TRUE_OBDD_OFFSET]
%define MGR_FALSE_OBDD(ptr) qword [ptr + MGR_FALSE_OBDD_OFFSET]
%define MGR_VARS_DICT(ptr) qword [ptr + MGR_VARS_DICT_OFFSET ]

;; OBDD NODE
%define OBDD_NODE_VAR_ID_OFFSET 0 
%define OBDD_NODE_NODE_ID_OFFSET 4
%define OBDD_NODE_REF_COUNT_OFFSET 8
%define OBDD_NODE_HIGH_OBDD_OFFSET 12
%define OBDD_NODE_LOW_OBDD_OFFSET 20
%define OBDD_NODE_SIZE 28
       
%define OBDD_NODE_VAR_ID(ptr) dword [ptr + OBDD_NODE_VAR_ID_OFFSET]
%define OBDD_NODE_NODE_ID(ptr) dword [ptr + OBDD_NODE_NODE_ID_OFFSET]
%define OBDD_NODE_REF_COUNT(ptr) dword [ptr +OBDD_NODE_REF_COUNT_OFFSET]
%define OBDD_NODE_HIGH(ptr) qword [ptr + OBDD_NODE_HIGH_OBDD_OFFSET]
%define OBDD_NODE_LOW(ptr) qword [ptr + OBDD_NODE_LOW_OBDD_OFFSET]

;; OBDD
%define OBDD_MGR_OFFSET 0
%define OBDD_ROOT_OFFSET 8
%define OBDD_SIZE 16
        
%define OBDD_MGR(ptr) qword [ptr + OBDD_MGR_OFFSET]
%define OBDD_ROOT(ptr) qword [ptr + OBDD_ROOT_OFFSET]
        
global obdd_mgr_mk_node

;; obdd_node*
;; obdd_mgr_mk_node(obdd_mgr* mgr,
;;                  char* var,
;;                  obdd_node* high,
;;                  obdd_node* low)

TRUE_VAR:    DB '1', 0
FALSE_VAR: DB '0',0

obdd_mgr_mk_node:
        push rbp
        mov rbp, rsp            
        push rbx
        push r12
        push r14
        push r15                ; pila alineada

        mov rbx, rdi		; rbx <- mgr
        mov r12, rsi		; r12 <- var
        mov r14, rdx		; r14 <- high
        mov r15, rcx		; r15 <- low
        
        mov rdi, OBDD_NODE_SIZE 
        call malloc             ; rax <- &nuevo nodo

.set_high:
        mov OBDD_NODE_HIGH(rax), r14
        cmp r14, 0
        je .set_low
        inc OBDD_NODE_REF_COUNT(r14) 
.set_low: 
        mov OBDD_NODE_LOW(rax), r15
        cmp r15, 0
        je .set_var_id
        inc OBDD_NODE_REF_COUNT(r15)
.set_var_id:
        mov r14, rax            ; guardo el puntero al nodo nuevo
        mov rdi, MGR_VARS_DICT(rbx) ; prim param a add_entry
        mov rsi, r12            ; seg param  a add_entry
        call dictionary_add_entry
        mov OBDD_NODE_VAR_ID(r14), eax
.set_node_id:
        mov rdi, rbx            ;1er param es mgr
        call obdd_mgr_get_next_node_ID
        mov OBDD_NODE_NODE_ID(r14), eax
.set_ref_count:
	mov OBDD_NODE_REF_COUNT(r14), 0
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
        push rbp
        push rbx
        push r12
        mov rbp, rsp

        mov rbx, rdi            ; rbx <- node
        mov ecx, OBDD_NODE_REF_COUNT(rbx)
        cmp ecx, 0
        jne .return
.high:
        mov rdi, OBDD_NODE_HIGH(rbx)
        cmp rdi, 0
        je .low
        dec OBDD_NODE_REF_COUNT(rdi)
        mov OBDD_NODE_HIGH(rbx), 0
        call obdd_node_destroy
        
.low:
        mov rdi, OBDD_NODE_LOW(rbx)
        cmp rdi, 0
        je .free_node
        dec OBDD_NODE_REF_COUNT(rdi)
        mov OBDD_NODE_LOW(rbx), 0
        call obdd_node_destroy
        
.free_node:
        mov OBDD_NODE_VAR_ID(rbx), 0
        mov OBDD_NODE_NODE_ID(rbx), 0
        mov rdi, rbx
        call free

.return:
        pop r12
        pop rbx
        pop rbp
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
        mov OBDD_MGR(rax), rbx
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
        mov OBDD_ROOT(r12), 0x0
        mov rdi, rbx
        call obdd_node_destroy

.return:
        mov OBDD_MGR(r12), 0x0
        mov rdi, r12
        call free   ; obdd_mgr_destroy
        
        pop r12
        pop rbx
        pop rbp
        ret


global obdd_node_apply
%define LEFT_VAR(ptr) qword [ptr- 0x8]
%define RIGHT_VAR(ptr) qword [ptr - 0x10]
%define IS_LEFT_CONST(ptr) qword [ptr - 0x18]
%define IS_RIGHT_CONST(ptr) qword [ptr - 0x20]
                
obdd_node_apply:
        push rbp
        push rbx
        push r12
        push r13
        push r14
        push r15

        mov rbp, rsp
;; reservo para variables locales
        sub rsp, 0x28           ; 0x20 == sizeof(void*) * 4
        
        mov rbx, rdi            ; rbx <- apply_fkt
        mov r12, rsi            ; r12 <- mgr
        mov r14, rdx            ; r14 <- left_node
        mov r15, rcx            ; r15 <- right_node

        ; debbug
        mov LEFT_VAR(rbp), 0
        mov RIGHT_VAR(rbp),0
        mov IS_LEFT_CONST(rbp),0
        mov IS_RIGHT_CONST(rbp),0
        
        mov rdi, MGR_VARS_DICT(r12) ; rdi <- dictionary
        mov esi, OBDD_NODE_VAR_ID(r14)
        xor rax, rax            ; no se el tamaño de bool
        call dictionary_key_for_value
        mov LEFT_VAR(rbp), rax

        mov rdi, MGR_VARS_DICT(r12) ; rdi <- dictionary 
        mov esi, OBDD_NODE_VAR_ID(r15)
        xor rax, rax            ; no se el tamaño de bool
        call dictionary_key_for_value 
        mov RIGHT_VAR(rbp), rax

        mov rdi, r12		
        mov rsi, r14
        xor rax, rax
        call is_constant        ; IS_LEFT_CONST <- is_constant(mgr, left_node);
        mov IS_LEFT_CONST(rbp), rax
        cmp rax, 0		; 0 == false
        ;je .l_and_r_const_is_false
        ; is_left_constant == true

        mov rdi, r12
        mov rsi, r15
        xor rax, rax
        call is_constant        ; IS_RIGHT_CONST <- is_constant(mgr, right_node);
        mov IS_RIGHT_CONST(rbp), rax        
        and rax, IS_LEFT_CONST(rbp)
        jz .l_and_r_const_is_false
        ; vale:
        ; is_right_constant && is_right_constant

        mov rdi, r12
        mov rsi, r14
        call is_true
        mov r13, rax            ; r13 <- is_true(left)
        
        mov rdi, r12
        mov rsi, r15
        call is_true            ; rax <- is_true(right)

        mov rdi, r13
        mov rsi, rax
        call rbx

        cmp rax, 0
        jne .ret_mk_node_true
        jmp .ret_mk_node_false


.l_and_r_const_is_false:
        cmp IS_LEFT_CONST(rbp),0
        jne .is_left_constant
        cmp IS_RIGHT_CONST(rbp),0
        jne .is_right_constant
        mov r13d, OBDD_NODE_VAR_ID(r14) ; r13 <- left_var_ID
        cmp r13d, OBDD_NODE_VAR_ID(r15) ; 
        je .l_var_eq_r_var
        jl .l_var_less_than_r_var
        jmp .l_var_gter_than_r_var

        
.is_left_constant:
        mov rdi, rbx            ; fkt
        mov rsi, r12            ; mgr
        mov rdx, r14            ; left_node
        mov rcx, OBDD_NODE_HIGH(r15) ; right_node -> high_obdd 
        call obdd_node_apply
        mov r13, rax

        mov rdi, rbx            ; fkt
        mov rsi, r12            ; mgr
        mov rdx, r14            ; left_node
        mov rcx, OBDD_NODE_LOW(r15) ;  right_node -> low_obdd 
        call obdd_node_apply

        mov rdi, r12            ; mgr
        mov rsi, RIGHT_VAR(rbp)      
        mov rdx, r13            
        mov rcx, rax
        call obdd_mgr_mk_node
        jmp .return

.is_right_constant:
        mov rdi, rbx            ; fkt
        mov rsi, r12            ; mgr
        mov rdx, OBDD_NODE_HIGH(r14) ; left_node -> high
        mov rcx, r15            ; right_node
        call obdd_node_apply
        mov r13, rax

        mov rdi, rbx            ; fkt
        mov rsi, r12            ; mgr
        mov rdx, OBDD_NODE_LOW(r14) ; left_node -> low
        mov rcx, r15 ;  right_node
        call obdd_node_apply

        mov rdi, r12            ; mgr
        mov rsi, LEFT_VAR(rbp)      
        mov rdx, r13            
        mov rcx, rax
        call obdd_mgr_mk_node
        jmp .return
        
.l_var_eq_r_var:
        mov rdi, rbx            ; fkt
        mov rsi, r12            ; mgr
        mov rdx, OBDD_NODE_HIGH(r14) ; left_node -> high
        mov rcx, OBDD_NODE_HIGH(r15) ; right_node -> high
        call obdd_node_apply
        mov r13, rax

        mov rdi, rbx            ; fkt
        mov rsi, r12            ; mgr
        mov rdx, OBDD_NODE_LOW(r14) ; left_node -> low
        mov rcx, OBDD_NODE_LOW(r15) ; right_node -> low
        call obdd_node_apply

        mov rdi, r12            ; mgr
        mov rsi, LEFT_VAR(rbp)      
        mov rdx, r13            
        mov rcx, rax
        call obdd_mgr_mk_node
        jmp .return

.l_var_less_than_r_var:
        mov rdi, rbx            ; fkt
        mov rsi, r12            ; mgr
        mov rdx, OBDD_NODE_HIGH(r14) ; left_node -> high
        mov rcx, r15 ; right_node
        call obdd_node_apply
        mov r13, rax

        mov rdi, rbx            ; fkt
        mov rsi, r12            ; mgr
        mov rdx, OBDD_NODE_LOW(r14) ; left_node -> low
        mov rcx, r15 ; right_node
        call obdd_node_apply

        mov rdi, r12            ; mgr
        mov rsi, LEFT_VAR(rbp)      
        mov rdx, r13            
        mov rcx, rax
        call obdd_mgr_mk_node
        jmp .return

.l_var_gter_than_r_var:         ; else
        mov rdi, rbx            ; fkt
        mov rsi, r12            ; mgr
        mov rdx, r14 ; left_node
        mov rcx, OBDD_NODE_HIGH(r15) ; right_node -> high
        call obdd_node_apply
        mov r13, rax

        mov rdi, rbx            ; fkt
        mov rsi, r12            ; mgr
        mov rdx, r14 ; left_node
        mov rcx, OBDD_NODE_LOW(r15) ; right_node -> low
        call obdd_node_apply

        mov rdi, r12            ; mgr
        mov rsi, RIGHT_VAR(rbp)      
        mov rdx, r13            
        mov rcx, rax
        call obdd_mgr_mk_node
        jmp .return

.ret_mk_node_true:
        mov rdi, r12
        mov rsi, TRUE_VAR
        mov rdx, 0x0
        mov rcx, 0x0
        call obdd_mgr_mk_node
        jmp .return

.ret_mk_node_false:
        mov rdi, r12
        mov rsi, FALSE_VAR
        mov rdx, 0x0
        mov rcx, 0x0
        call obdd_mgr_mk_node
        jmp .return
        
.return:
        add rsp, 0x28
        pop r15
        pop r14
        pop r13
        pop r12
        pop rbx
        pop rbp
        ret

%undef LEFT_VAR
%undef RIGHT_VAR
%undef IS_LEFT_CONST
%undef IS_RIGHT_CONST

        
global is_tautology
is_tautology:
	push rbp
	push rbx
	push r12
	mov rbp, rsp

	mov rbx, rdi 		; rbx <- mgr
	mov r12, rsi 		; rsi <- root
	call is_constant
	cmp rax, 0
	je .no_es_const
	mov rdi, rbx
	mov rsi, r12
	call is_true
	jmp .return

.no_es_const:
	mov rdi, rbx
	mov rsi, OBDD_NODE_HIGH(r12)
	call is_tautology
	cmp rax, 0
	je .return
	mov rdi, rbx
	mov rsi, OBDD_NODE_LOW(r12)
	call is_tautology
	jmp .return

.return:
	
	pop r12
	pop rbx
	pop rbp
        ret

global is_sat
is_sat:
	push rbp
	push rbx
	push r12
	mov rbp, rsp
	
	mov rbx, rdi 		; rbx <- mgr
	mov r12, rsi 		; rsi <- root
	call is_constant
	cmp rax, 0
	je .no_es_const
	mov rdi, rbx
	mov rsi, r12
	call is_true
	jmp .return
	
.no_es_const:
	mov rdi, rbx
	mov rsi, OBDD_NODE_HIGH(r12)
	call is_sat
	cmp rax, 0
	jne .return
	mov rdi, rbx
	mov rsi, OBDD_NODE_LOW(r12)
	call is_sat
	jmp .return
	
.return:
	
	pop r12
	pop rbx
	pop rbp
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
