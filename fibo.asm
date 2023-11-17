section .data
    fib: dq 0
    erro : db "Algo deu errado.", 10, 0
    erroL: equ $ - erro
    inicio_arquivo: db "fib(", 0
    fim_arquivo: db ").bin", 0 ; Os dois se juntaram para formar o nome do arquivo

section .bss
    input: resb 3 ; 2 digitos + espaco
    lixo: resb 1
    fib_arq : resq 1
    f_arquivo: resb 30

section .text
    global _start

_start:
    mov rax, 0
    mov rdi, 0
    lea rsi, [input]
	mov rdx, 3
    syscall

    cmp byte[input], '-'
    je errorMsg

    cmp byte[input + 1], 10
    je oneNumber

    cmp byte[input + 2], 10
    je twoNumbers
    jne handle

    oneNumber:
        mov al, [input]
        mov rbx, [inicio_arquivo]
        mov [f_arquivo], rbx ; fib(
        mov [f_arquivo + 4], al ;fib(x
        mov rbx, [fim_arquivo]
        mov [f_arquivo + 5], rbx; fib(x)
        mov bl, [fim_arquivo + 4]
        mov [f_arquivo + 9], bl
        sub al, 48
        mov [fib_arq], al ; nome do arquivo completo

        cmp al, 0
        je arquivo
        cmp al, 1
        je fib_1
        mov r15, 1
        mov r14, 0
        jmp fibonacci

    twoNumbers:
        mov cl, [input + 1]
        mov al, [input]
        mov rbx, [inicio_arquivo]
        mov [f_arquivo], rbx
        mov [f_arquivo + 4], al
        mov [f_arquivo + 5], cl
        mov rbx, [fim_arquivo]
        mov [f_arquivo + 6], rbx
        mov bl, [fim_arquivo + 4]
        mov [f_arquivo + 10], bl
        sub al, 48
        sub cl, 48
        imul ax, 10
        add al, cl
        mov [fib_arq], al
        cmp al, 94
        jge errorMsg
        mov r15, 1

    fibonacci:
        mov r13, r15
        add r15, r14
        mov [fib], r15
        mov r14, r13
        dec qword[fib_arq]
        cmp qword[fib_arq], 1
        jne fibonacci
        jmp arquivo

fib_1:
    mov qword[fib], 1

arquivo:
    mov rax, 2
    lea rdi, [f_arquivo]
    mov edx, 664o
    mov esi, 102o
    syscall

    mov r9, rax
    mov rax, 1
    mov rdi, r9
    mov rsi, fib
    mov rdx, 8
    syscall

    mov rax, 3
    mov rdi, r9
    syscall
    jmp fim

handle:
    mov rax, 0
    mov rdi, 0
    lea rsi, [lixo]
    mov rdx, 1
    syscall

    cmp byte[lixo], 10
    jne handle

errorMsg:
    mov rax, 1
    mov rdi, 1
    mov rsi, erro
    mov rdx, erroL
    syscall


fim:
    mov rax, 60
    mov rdi, 0
    syscall