section .data

  ; Mensagens de saída
  msg_pergunta db 'Entrada-> Quantidade de discos: ', 0
  msg_movendo_disco db 'Movimentando o disco ', 0
  msg_da_coluna db ' da coluna ', 0
  msg_para_coluna db ' para a coluna ', 0
  msg_fim db '---Fim do Algoritmo---', 0
  nome_coluna_origem db ' A ', 0
  nome_coluna_auxiliar db ' B ', 0
  nome_coluna_destino db ' C ', 0
  nova_linha db 10  ; Nova linha
 
 
section .bss
  ; Buffers de entrada e armazenamento
  num_discos resb 2     ; Armazena quantidade de discos
  tamanho_string resb 3     ; Armazena comprimento da string
  buffer_entrada resb 4        ; Armazena entrada do usuário

section .text
  global _start
    
  ; Constantes para chamadas de sistema
  SYS_EXIT equ 1
  SYS_READ equ 3
  SYS_WRITE equ 4
  STDIN equ 0
  STDOUT equ 1

_start:
  inicio:
  mov ecx, msg_pergunta      ; Carrega pergunta para exibição
  call printar_ecx_todo         ; Exibe a pergunta

  mov ecx, buffer_entrada             ; Prepara buffer de entrada
  call ler_input               ; Lê entrada do usuário

  ; Converte entrada para inteiro
  call converter_string_int    ; Converte string para inteiro
  mov [num_discos], edx        ; Armazena quantidade de discos

  call torre_de_hanoi           ; Executa algoritmo da Torre de Hanói

  mov ecx, msg_fim           ; Carrega mensagem de conclusão
  call printar_ecx_todo         ; Exibe mensagem de conclusão

  ; Encerra o programa
  mov eax, 1                   ; Código de saída do sistema
  xor ebx, ebx                 ; Código de retorno 0
  int 0x80                     ; Chama interrupção do sistema

torre_de_hanoi:               ; Algoritmo da Torre de Hanói
  cmp byte [num_discos], 1    ; Verifica se há apenas um disco
  je caso_base              ; Se sim, trata caso base
  jmp caso_recursivo             ; Se não, trata caso recursivo

  caso_base:                ; Caso base (um disco)
    mov ecx, msg_movendo_disco ; Carrega mensagem de movimento
    call printar_ecx_todo                 ; Exibe mensagem de movimento

    call printar_num_discos       ; Exibe número do disco

    mov ecx, msg_da_coluna   ; Carrega mensagem "da coluna"
    call printar_ecx_todo         ; Exibe mensagem "da coluna"

    mov ecx, nome_coluna_origem      ; Carrega nome da coluna origem
    call printar_ecx_todo         ; Exibe nome da coluna origem

    mov ecx, msg_para_coluna ; Carrega mensagem "para a coluna"
    call printar_ecx_todo         ; Exibe mensagem "para a coluna"

    mov ecx, nome_coluna_destino     ; Carrega nome da coluna destino
    call printar_ecx_todo         ; Exibe nome da coluna destino

    mov ecx, nova_linha    ; Carrega nova linha
    call printar_ecx_todo         ; Exibe nova linha

    jmp fim                    ; Pula para o fim da função

  caso_recursivo:                ; Caso recursivo (mais de um disco)
    dec byte [num_discos]     ; Decrementa contador de discos

    push word [num_discos]    ; Salva contador na pilha
    push word [nome_coluna_origem]  ; Salva colunas na pilha
    push word [nome_coluna_auxiliar] 
    push word [nome_coluna_destino]

    ; Troca colunas auxiliar e destino
    mov dx, [nome_coluna_auxiliar] 
    mov cx, [nome_coluna_destino]
    mov [nome_coluna_destino], dx
    mov [nome_coluna_auxiliar], cx

    call torre_de_hanoi        ; Chama recursivamente

    pop word [nome_coluna_destino]  ; Restaura colunas da pilha
    pop word [nome_coluna_auxiliar]
    pop word [nome_coluna_origem]

    pop word [num_discos]     ; Restaura contador da pilha

    mov ecx, msg_movendo_disco ; Carrega mensagem de movimento
    call printar_ecx_todo                 ; Exibe mensagem de movimento

    inc byte [num_discos]     ; Incrementa temporariamente para exibir
    call printar_num_discos       ; Exibe número do disco
    dec byte [num_discos]     ; Decrementa de volta

    mov ecx, msg_da_coluna   ; Carrega mensagem "da coluna"
    call printar_ecx_todo         ; Exibe mensagem "da coluna"

    mov ecx, nome_coluna_origem      ; Carrega nome da coluna origem
    call printar_ecx_todo         ; Exibe nome da coluna origem

    mov ecx, msg_para_coluna ; Carrega mensagem "para a coluna"
    call printar_ecx_todo         ; Exibe mensagem "para a coluna"

    mov ecx, nome_coluna_destino     ; Carrega nome da coluna destino
    call printar_ecx_todo         ; Exibe nome da coluna destino

    mov ecx, nova_linha    ; Carrega nova linha
    call printar_ecx_1_elemento  ; Exibe nova linha

    ; Troca colunas auxiliar e origem
    mov dx, [nome_coluna_auxiliar]
    mov cx, [nome_coluna_origem]
    mov [nome_coluna_origem], dx
    mov [nome_coluna_auxiliar], cx

    call torre_de_hanoi        ; Chama recursivamente

  fim:                       ; Fim da função
    ret                      ; Retorna

converter_string_int:         ; Converte string em inteiro
  mov edx, 0                  ; Inicializa acumulador com 0
  mov ecx, 10                  ; Base de conversão (decimal)

  mov esi, buffer_entrada            ; Aponta para início da string
  mov edi, 4                  ; Contador de dígitos (máximo 4)

.loop:
  mov al, [esi]              ; Lê um caractere
  inc esi                    ; Avança para o próximo caractere
  cmp al, 0x0a               ; Verifica se é fim de linha
  je .fim                    ; Se sim, termina a conversão

  sub al, '0'                ; Converte ASCII para numérico
  imul edx, ecx              ; Multiplica acumulador pela base
  add edx, eax              ; Adiciona valor numérico ao acumulador
  dec edi                    ; Decrementa contador de dígitos
  jnz .loop                  ; Repete se ainda houver dígitos

.fim:
  ret                        ; Retorna

printar_ecx_1_elemento:       ; Imprime um caractere de ECX
  mov eax, SYS_WRITE          
  mov ebx, SYS_EXIT         
  mov edx, 1                  ; Número de bytes a escrever
  int 0x80                    ; Chama interrupção do sistema
  ret                        ; Retorna

printar_ecx_todo:             ; Imprime string terminada em 0 de ECX
  printar_loop:
    mov al, [ecx]            ; Carrega caractere atual
    cmp al, 0                ; Verifica se é o final da string
    je printar_exit          ; Se sim, sai da função
    call printar_ecx_1_elemento ; Imprime o caractere
    inc ecx                  ; Avança para o próximo caractere
    jmp printar_loop          ; Repete o loop

  printar_exit:               ; Saída do loop
    ret                      ; Retorna

ler_input:                
  mov eax, SYS_READ
  mov ebx, STDIN
  mov edx, 3                  ; Número máximo de bytes a ler
  int 0x80                    ; Chama interrupção do sistema
  ret                        ; Retorna

converter_int_string:         ; Converte inteiro para string
  dec edi                    ; Decrementa ponteiro para string
  xor edx, edx               ; Zera EDX para resto da divisão
  mov ecx, 10                 ; Base de conversão (decimal)
  div ecx                    ; Divide EAX por 10, quociente em EAX, resto em EDX
  add dl, '0'                ; Converte dígito para ASCII
  mov [edi], dl              ; Armazena caractere convertido
  test eax, eax              ; Verifica se quociente é zero
  jnz converter_int_string   ; Repete se não for zero
  ret                        ; Retorna

calcular_comprimento:         ; Calcula comprimento de string
  xor eax, eax               ; Inicializa contador com zero
  mov ecx, edi               ; Aponta para início da string

.loop:
  cmp byte [ecx], 0          ; Verifica se é o terminador nulo
  je .fim                    ; Se sim, termina o loop
  inc ecx                    ; Avança para o próximo byte
  inc eax                    ; Incrementa o contador
  jmp .loop                  ; Repete o loop

.fim:
  ret                        ; Retorna comprimento em EAX

printar_num_discos:             ; Imprime número do disco
  movzx eax, byte [num_discos] ; Carrega número do disco em EAX
  lea edi, [tamanho_string + 2]   ; Prepara buffer para conversão

  call converter_int_string   ; Converte inteiro para string
  call calcular_comprimento   ; Calcula comprimento da string
  mov edx, eax               ; Armazena comprimento em EDX

  mov eax, SYS_WRITE
  mov ebx, STDOUT
  lea ecx, [edi]              ; Carrega endereço da string convertida
  int 0x80                    ; Chama interrupção do sistema
  ret                        ; Retorna


    
    
    
    
    
    
    
    
    
    

