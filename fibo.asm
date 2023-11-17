section .data
    fib: dq 0
    erro : db "Algo deu errado.", 10, 0
    erroL: equ $ - erro
    inicio_arquivo: db "fib(", 0
    fim_arquivo: db ").bin", 0 ; Os dois se juntarão para formar o nome do arquivo

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
    syscall ; nesimo lido

    cmp byte[input], '-' ; O número é negativo?
    je errorMsg

    cmp byte[input + 1], 10 ; Foi lido apenas um numero?
    je oneNumber

    cmp byte[input + 2], 10 ; 2 números?
    je twoNumbers
    jne handle ; São 3 números ou mais...

    oneNumber:
        mov al, [input]
        mov rbx, [inicio_arquivo]
        mov [f_arquivo], rbx ; fib(
        mov [f_arquivo + 4], al ; fib(x
        mov rbx, [fim_arquivo]
        mov [f_arquivo + 5], rbx ; fib(x)
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
        mov rbx, [inicio_arquivo] ; fib(
        mov [f_arquivo], rbx
        mov [f_arquivo + 4], al ; fib(x
        mov [f_arquivo + 5], cl ; fib(xy
        mov rbx, [fim_arquivo] ; fib(xy).bin
        mov [f_arquivo + 6], rbx
        mov bl, [fim_arquivo + 4]
        mov [f_arquivo + 10], bl
        sub al, 48 ; Convertendo o valor lido em string para numérico
        sub cl, 48 ; Convertendo o valor lido em string para numérico
        imul ax, 10
        add al, cl ; al = cl
        mov [fib_arq], al ; al = fib_arq
        cmp al, 94
        jge errorMsg
        mov r15, 1

    fibonacci:
        mov r13, r15 ; r13 = r15
        add r15, r14 ; r15 = r15 + r14
        mov [fib], r15 ; fib = r15
        mov r14, r13 ; r14 = r13
        dec qword[fib_arq] ; fib_arq -= 1
        cmp qword[fib_arq], 1 ; fib_arq = 1?
        jne fibonacci ; retornar para o começo da função fibonacci caso não seja 1
        jmp arquivo ; caso seja 1, ir para função arquivo

fib_1:
    mov qword[fib], 1

arquivo:
    mov rax, 2
    lea rdi, [f_arquivo]
    mov edx, 664o ; modo do arquivo
    mov esi, 102o ; flags 
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
