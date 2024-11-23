
;4- Fa?a uma rotina que receba um valor em AX 
;e calcule o seu fatorial. Retorne o valor em AX.
.model small

.stack 100H   ; define uma pilha de 256 bytes (100H)

.data 
;-------------------------------------------------------------------------------------------
    ;Constantes
    
    ; Constantes para pular linha
    CR EQU 13
    LF EQU 10
    
    memoria_video equ 0A000h
    
    bit_alto_DelayMovNaveTelaInicial equ 0000h
    bit_baixo_DelayMovNaveTelaInicial equ 0C350h
    
    bit_alto_DelayTela equ 001Eh
    bit_baixo_DelayTela equ 8480h

    teste equ 86A0h    
    
    posicao_nave       dw       ?
    tecla_cima                  equ 72
    tecla_baixo                 equ 80
    tecla_espaco                equ 32
    limite_inferior             equ 54752 ; 320 * (200 - 29) + 32 (200 - altura do desenho + altura do terreno)
    limite_superior             equ 6432 ; 320 * 20 + 32
;-------------------------------------------------------------------------------------------
    ;MENU
    timer_do_jogo dw 60
    score db "00000$"
;-------------------------------------------------------------------------------------------       
;Variaveis de jogo
timer dw 0
jogando dw 0 ; status do jogo (em jogo=1; menu=0)

;-------------------------------------------------------------------------------------------        
    ;Sprites
    logo_inicio db "       __ __    ______           ", CR, LF
                db "      / // /___/ __/ /____ _____ ", CR, LF
                db "     /    /___/\ \/ __/ _ `/ __/ ", CR, LF
                db "    /_/\_\   /___/\__/\_,_/_/    ", CR, LF
                db "          ___       __           __ ", CR, LF
                db "         / _ \___ _/ /________  / / ", CR, LF
                db "        / ___/ _ `/ __/ __/ _ \/ /  ", CR, LF
                db "       /_/   \_,_/\__/_/  \___/_/   $", CR, LF
                
    nave  db 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh,   0,   0,   0,   0
          db   0,   0, 0Fh, 0Fh,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
          db   0,   0, 0Fh, 0Fh,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
          db   0,   0, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh,   0,   0,   0,   0,   0,   0
          db   0,   0, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh
          db   0,   0, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh,   0,   0,   0,   0,   0,   0
          db   0,   0, 0Fh, 0Fh,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
          db   0,   0, 0Fh, 0Fh,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
          db 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh,   0,   0,   0,   0
          
    nave_inimiga  db  0,  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0
                  db  0,  0,  0,  0,  0,  0,  0,  0,  0, 09h,09H,09H,09H,09H,09H
                  db  0,  0,  0,  0,  0,  0,  0,  0,09H, 09H,  0,  0,  0,  0,  0
                  db  0,  0,  0,09H,09H,09H,09H,09H,  0,   0,  0,  0,  0,  0,  0
                  db 09H,09H,09H,09H,09H,09H,09H,09H,09H, 09H,09H,09H,09H,  0,  0
                  db  0,  0,  0,09H,09H,09H,09H,09H,  0,   0,  0,  0,  0,  0,  0
                  db  0,  0,  0,  0,  0,  0,  0,  0,09H, 09H,  0,  0,  0,  0,  0
                  db  0,  0,  0,  0,  0,  0,  0,  0,  0, 09H,09H,09H,09H,09H,09H
                  db  0,  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0
                
;-------------------------------------------------------------------------------------------
;STRINGS
    botao_start db "Start$"
    botao_exit db "Exit$"
    string_fim db "F"
    string_fase db "FASE - $"
    string_score db "Score: $"
    string_tempo db "Tempo: $"
;-------------------------------------------------------------------------------------------
.code  

; Funcao para desenhar os objetos
; SI: Posicao desenho na memoria
; DI: Posicao do primeiro pixel do desenho no video
; BL: Cor da nave
DESENHA_NAVE proc
    push dx
    push cx
    push di
    push si
    
    mov dx, 9
DESENHA_NAVE_LOOP:
    mov cx, 15
    
LOOP_DESENHO:
    
    lodsb
    
    cmp AL, 0
    jnz SET_COR
    
    STOSB
CONTINUA_LOOP_DESENHO:
    
    loop LOOP_DESENHO
    
    dec dx
    add di, 305
    cmp dx, 0
    jnz DESENHA_NAVE_LOOP
    
    jmp SAIR_PROC

SET_COR:
    mov AL, BL
    stosb
    jmp CONTINUA_LOOP_DESENHO

SAIR_PROC:
    pop si
    pop di
    pop cx
    pop dx
    ret
endp

; Funcao para desenhar os objetos
; SI: Posicao desenho na memoria
; DI: Posicao do primeiro pixel do desenho no video
DESENHA_ELEMENTO proc
    push dx
    push cx
    push di
    push si
    
    mov dx, 9
DESENHA_ELEMENTO_LOOP:
    mov cx, 15
    rep movsb
    dec dx
    add di, 305
    cmp dx, 0
    jnz DESENHA_ELEMENTO_LOOP
    
    pop si
    pop di
    pop cx
    pop dx
    ret
endp

GERA_ENDERECI_ALEATORIO proc
    push AX
    push BX
    push CX
    push DX
    ; Gerar a linha aleat?ria (de 0 a 199)
    mov ah, 2Ch         ; Fun??o para pegar o contador de tempo
    int 21h             ; Chama a interrup??o 21h
    mov cx, dx          ; O valor aleat?rio vai para CX
    ;and cx, 0C7FFh      ; Limita o valor para o intervalo de 0 a 199 (200 linhas)
    
    ; Gerar a coluna aleat?ria (de 160 a 319)
    mov ah, 2Ch         ; Fun??o para pegar o contador de tempo novamente
    int 21h             ; Chama a interrup??o 21h
    mov dx, dx          ; O valor aleat?rio vai para DX
    ;and dx, 01FFH      ; Limita o valor para o intervalo 0-511
    ;add dx, 160         ; Desloca o valor para que ele esteja no intervalo 160-319 (colunas)

    ; Agora, CX cont?m a linha aleat?ria e DX cont?m a coluna aleat?ria (160-319)
    ; Calculando o endere?o de v?deo correspondente

    ; Calcular o deslocamento inicial da linha
    mov ax, cx          ; Linha atual
    mov bx, 320         ; 320 pixels por linha
    mul bx              ; AX = linha * 320 (deslocamento inicial da linha)
    
    ; Agora, adicionar a coluna aleat?ria
    add ax, dx          ; AX = (linha * 320) + coluna aleat?ria

    ; O valor de AX agora cont?m o endere?o de mem?ria para o pixel aleat?rio
    ; Agora vamos modificar esse valor de v?deo (exemplo com valor 0x0F
    pop DX
    pop CX
    pop BX
    pop AX
    ret
endp

GERA_NUM_ALEATORIO proc
    push BX
    push CX
    push AX
    
    mov ah, 2Ch         ; Fun??o para pegar o contador de tempo
    int 21h             ; Chama a interrup??o 21h
    div DX
    
    pop AX
    pop CX
    pop BX
    ret
endp

INICIA_HUD proc
    ;Escreve o start de inicio com o botao
    mov BL, 15   ; branca
    mov DH, 0    ; linha
    mov DL, 0    ; coluna
    mov BP, offset string_score
    call ESC_STRING
    
    mov BL, 2 
    add DL, 6    ; coluna
    mov BP, offset score
    call ESC_STRING
    
    mov BL, 15   ; branca
    mov DH, 0    ; linha
    mov DL, 31    ; coluna
    mov BP, offset string_tempo
    call ESC_STRING
    
    mov SI, offset timer
    mov SI, timer_do_jogo
    
    mov AX, SI
    
    call MUDA_TIMER
    
    stosw
    ret
endp 

;recebe em AX o tempo
;Printa no local do tempo correto
MUDA_TIMER proc
    push AX      ; Salvar registradores utilizados na proc
    push BX
    push CX
    push DX 
    
    mov DH, 0    ; linha
    mov DL, 38    ; coluna
    
    call POS_CURSOR
    call ESC_UINT16
    
    mov SI, offset timer
    mov SI, AX
    
    pop DX
    pop CX
    pop BX
    pop AX
    ret
endp 

; Escreve na tela um inteiro sem sinal    
; de 16 bits armazenado no registrador AX
ESC_UINT16 proc 
    push AX      ; Salvar registradores utilizados na proc
    push BX
    push CX
    push DX 
    ; Configurar o loop para processar cada d?gito
    mov bx, 10      ; Divisor para separa??o dos d?gitos (divis?o por 10)
    xor CX, CX      ; SI ser? usado para armazenar o n?mero de d?gitos (inicializa com 0)

convert_loop:
    xor dx, dx      ; Limpar o registrador DX (necess?rio para a divis?o)
    div bx          ; Dividir AX por 10. Quociente vai para AX e resto vai para DX (d?gito)
    push dx         ; Armazenar o d?gito no stack

    inc CX          ; Contar o n?mero de d?gitos
    cmp ax, 0     ; Verificar se ainda h? n?meros em AX
    jnz convert_loop ; Se AX n?o for zero, continuar o loop

    ; Exibir os d?gitos da pilha em ordem correta (do primeiro ao ?ltimo)
    mov AH, 09h    ; Fun??o de exibi??o (Teletype Output) via int 10h
    mov BL, 02h
print_loop:
    pop dx          ; Recuperar um d?gito da pilha
    add dl, '0'     ; Converter o d?gito (resto) para o c?digo ASCII
    mov AL, DL
    int 10h        ; Chamar interrup??o para exibir o caractere com a cor configurada
    
    call LER_CORDENADA_CURSOR
    
    inc DL
    call POS_CURSOR
    
    loop print_loop ; Continuar o loop at? que todos os d?gitos sejam exibidos
    
    pop DX
    pop CX
    pop BX
    pop AX
    ret     
endp

LER_CORDENADA_CURSOR proc
    push AX      ; Salvar registradores utilizados na proc
    push BX
    push CX
    
    mov AH, 03h
    int 10h    

    pop CX
    pop BX
    pop AX
    ret
endp

; Escreve na tela um caractere armazenado em DL     
ESC_CHAR proc
 push AX    ; salvar o reg AX
 mov AH, 2
 int 21H
 pop AX     ; restaurar o reg AX
 ret  
endp

CRIA_NAVES_INICIO proc
    
    mov SI, offset nave
    
    mov AX, 6400

    ;Escreve o start de inicio com o botao
    mov BL, 09h
    mov DI, AX
    call DESENHA_NAVE
    
    mov BL, 0Ah
    add DI, AX
    call DESENHA_NAVE
    
    mov BL, 0Ch
    add DI, AX
    call DESENHA_NAVE
    
    mov BL, 0Dh
    add DI, AX
    call DESENHA_NAVE
    
    mov BL, 0Eh
    add DI, AX
    call DESENHA_NAVE
    
    mov BL, 07h
    add DI, AX
    call DESENHA_NAVE
    
    mov BL, 05h
    add DI, AX
    call DESENHA_NAVE
    
    mov BL, 04h
    add DI, AX
    call DESENHA_NAVE
    
    ;Inicia desenhando a nave na posi??o correta.
    MOV BL, 0Fh
    MOV [posicao_nave], 28820
    MOV DI, [posicao_nave]
    CALL DESENHA_NAVE

    ret
endp

FASE_1 proc
    
    mov BL, 2
    mov AL, 49
    
    call INICIO_FASE
    call INICIA_HUD
    call CRIA_NAVES_INICIO
    
    ;CALL RESETA_TEMPO_DE_JOGO
    ;
    ;call EM_JOGO
    

    ret
endp

LIMPAR_TELA proc
    push AX
    push CX
    push DX
    push DI
    
    mov ax, offset memoria_video
    mov ES, AX
    
    mov DI, 0
    mov AL, 0
    mov CX, 64000
    rep stosb
    
    pop DI
    pop CX
    pop DX
    pop AX
    
    ret
endp
  
POS_CURSOR proc
    push ax
    push bx
    mov ah, 02                   ;Codigo da funcao
    int 10h                      ;Interrupcao
    pop bx
    pop ax
    ret
endp

; Ler os direcionais do teclado
; retorna o caractere em AH
LER_KEY proc
    mov AH, 0
    int 16h
    ret
endp

;Desenha quadrado
; BL cor
; DH linha inicial
; DL coluna inicial
DESENHA_QUADRADO_BOTAO proc
    push AX    
    push BX
    push DX
    
    xor BH, BH
    
    ;Canto superior/esquerdo
    call POS_CURSOR
    mov CX, 7 ;Largura
    mov AL, 218     
    mov CX, 1
    mov AH, 0AH
    int 10h
    ;FIM
    
    inc DL
    
    ;reta Horizontal Superior CX vezes
    call POS_CURSOR
    mov AL, 196
    
    mov CX, 7 ;Largura
    mov AH, 0AH
    int 10h
    ;FIM
    
    add DL, CL
    
    ;Canto superior/direito
    call POS_CURSOR
    mov AL, 191 
    mov CX, 1
    mov AH, 0AH
    int 10h
    ;FIM
    
    inc DH
    
    ;Barra direita
    call POS_CURSOR
    mov AL, 179 
    mov CX, 1
    mov AH, 0AH
    int 10h
    ;FIM
    
    inc DH
    
    ;Canto inferior direito
    call POS_CURSOR
    mov AL, 217 ;reta
    mov CX, 1
    mov AH, 0AH
    int 10h
    ;FIM
    
    mov CX, 8
    
    ;Reta Inferior
    sub DL, CL
    
    call POS_CURSOR
    mov AL, 196  
    mov AH, 0AH
    int 10h
    
    mov CX, 1
    mov AL, 192  
    mov AH, 0AH
    int 10h
    
    dec DH
    call POS_CURSOR
    mov CX, 1
    mov AL, 179  
    mov AH, 0AH
    int 10h
     
    pop DX
    pop BX
    pop AX
    ret
endp

;Funcao para mover um objeto 1px para a esqueda
;si = Recebe posicao atual do objeto
MOVE_OBJETO proc
    push ax
    push bx
    push cx
    push dx
    push di
    push si
    
    mov ax, memoria_video
    mov ds, ax
    
    mov dx, 16
    
LOOP_MOVE_OBJETO:
    mov cx, 16
    mov di, si
    dec di
    rep movsb
    add di, 304
    add si, 304
    dec dx
    cmp dx, 0
    jnz LOOP_MOVE_OBJETO
    
    mov ax, @data
    mov ds, ax
    
    pop si
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp

;Recebe em CX parte alta em microsegundos
;Recebe em DX parte baixa em microsegundos
DELAY proc
    push CX
    push DX
    push AX
    
    mov AH, 86h
    int 15h
    
    pop AX
    pop DX
    pop CX
    ret
endp

animacao_tela_inicial proc
    push AX
    push BX
    push CX
    push DX
    
    mov cx, offset bit_alto_DelayMovNaveTelaInicial
    mov dx, offset bit_baixo_DelayMovNaveTelaInicial
    call DELAY
    
    call MOVE_NAVE_BAIXO
    
    pop DX
    pop CX
    pop BX
    pop AX
    ret
endp

;Funcao para reiniciar o timer do jogo
RESETA_TEMPO_DE_JOGO proc
    push ax
    push bx
    push cx
    push dx
    
    ;add si, cx
    ;mov cx, [si]
    ;xor dx, dx
    mov ax, timer_do_jogo
    ;mul cx
    mov timer, ax
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp

; Proc de LOOP do jogo em funcionamento
EM_JOGO proc
    mov jogando, 1

FLUXO_JOGO:
    
    ;CALL DELAY
    xor dx, dx
    mov ax, timer
    dec ax
    mov timer, ax
    
    mov DI, 10000
    
    stosw
    
    ;mov bx, jogando
    ;cmp bx, 1
    ;je FLUXO_JOGO
    
    ret
endp

MOVE_NAVE_BAIXO proc
    push ax
    push bx
    push cx
    push si
    push di
    
    mov bx, posicao_nave  ; Carrega a posi??o atual da nave
    
    cmp bx, limite_inferior  ; Verifica se a nave atingiu o limite inferior
    jae FIM_MOVE_NAVE_BAIXO  ; Se j? atingiu o limite inferior, n?o move a nave

    mov ax, memoria_video
    mov ds, ax
    
    mov dx, 15         ; N?mero de linhas para mover
    mov si, bx         
    mov di, bx         
    add di, 320       ; Move 5 linha para baixo
    push di            ; Empilha para salvar a nova posi??o da nave
    
    add di, 2880       ; inicio da ultima linha da nave
    add si, 2880
MOVE_NAVE_BAIXO_LOOP:
    mov cx, 15         ; Largura
    rep movsb          
    dec dx             
    sub di, 335        ; Proxima linha
    sub si, 335        
    cmp dx, 0         
    jnz MOVE_NAVE_BAIXO_LOOP

    pop di            
    mov bx, di         
    
    mov ax, @data
    mov ds, ax
    
    mov posicao_nave, bx 

FIM_MOVE_NAVE_BAIXO:
    pop di
    pop si
    pop cx
    pop bx
    pop ax
    ret
endp

;AL = char do numero da fase (ASCII)
;BL = Cor
INICIO_FASE proc
    push BX
    push DX
    push CX
    push AX

    call LIMPAR_TELA
    
    ;Escreve a logo de inicio
    mov DH, 11 ; linha
    mov DL, 15 ; coluna
    mov BP, offset string_fase
    call ESC_STRING
    
    ;Escreve o numero da fase
    mov CX, 1
    mov BH, 1
    mov AH, 09H
    int 10H
    
    ; espera um determinado tempo
    mov CX, offset bit_alto_DelayTela
    mov DX, offset bit_baixo_DelayTela
    call DELAY
    
    call LIMPAR_TELA
    
    pop AX
    pop CX
    pop DX
    pop BX
    ret
endp

TELA_INICIAL proc

    mov ax, memoria_video
    mov ES, AX
    
    ;Escreve a logo de inicio
    mov BL, 2 ; cor VERDE
    mov DH, 0 ; linha
    mov DL, 0 ; coluna
    mov BP, offset logo_inicio
    call ESC_STRING
   
    xor dx,dx
    xor bx, bx
    
    ;Escreve o start de inicio com o botao
    mov BL, 0CH   ; cor VERMELHO
    mov DH, 16    ; linha
    mov DL, 18    ; coluna
    mov BP, offset botao_start
    call ESC_STRING
    
    ;Desenha o botao
    dec DH      ; linha
    sub DL, 2   ; coluna
    call DESENHA_QUADRADO_BOTAO
    ;FIM
    
    ;Escreve o exit do inicio
    mov BL, 15  ;cor BRANCA
    mov DH, 19  ; linha
    mov DL, 18  ; coluna
    mov BP, offset botao_exit
    call ESC_STRING
    
    dec DH                ; linha
    sub DL, 2             ; coluna
    call DESENHA_QUADRADO_BOTAO
    
    ;Inicia desenhando a nave na posi??o correta.
    MOV BL, 0Fh
    MOV [posicao_nave], 32000
    MOV DI, [posicao_nave]
    MOV SI, offset nave
    CALL DESENHA_NAVE
    
    mov dh, 16
LOOP_SELECAO:
    call animacao_tela_inicial
    
    mov AH, 01H
    int 16h
    jz LOOP_SELECAO ; Zero flag significa que n?o houve input, ent?o s? roda o loop novamente
    
    ;verifica se tem teclas pressionadas no buffer, essa parte vai capturar qual tecla foi pressionada.
    call LER_KEY
    
    ; Compara se o usuario apertou a down arrow ou up arrow
    cmp AH, 48H  ;cima
    je TROCA_SELECAO
    cmp AH, 50H  ;baixo
    je TROCA_SELECAO
    
    cmp AH, 1CH ;comp se e tecla enter
    je FIM_MENU_INICIAL
    jne LOOP_SELECAO
    
    JMP LOOP_SELECAO ; REPETE O LOOP.
TROCA_SELECAO:
    cmp dh, 16
    jz TROCA_pra_exit
    jnz TROCA_pra_start

TROCA_pra_start:
    dec dh
    call TROCA_COR_BOTOES
    
    jmp LOOP_SELECAO
TROCA_pra_exit:
    inc DH
    call TROCA_COR_BOTOES
    jmp LOOP_SELECAO
FIM_MENU_INICIAL:
    cmp DH, 16
    jz CHAMA_INICIO
    jnz FIM_TELA_INICIAL
    
CHAMA_INICIO:
    ;call INICIAR_JOGO
    call FASE_1
FIM_TELA_INICIAL:
    
    mov ah, 00h
    int 16h
    ;call LIMPAR_TELA
    ;call FIM_PROGRAMA
    ret
endp

TROCA_COR_BOTOES proc
    push AX
    push BX
    push CX
    push DX

    cmp DH, 16
    je select_exit
    jne select_start
    
select_exit:
    ;Escreve o start de inicio
        mov bl, 0CH                   ; cor
        mov dh, 16                   ; linha
        mov dl, 18                   ; coluna
        mov bp, offset botao_start
        call ESC_STRING
        
        ;DEsenha o botao
        dec dh                ; linha
        sub dl, 2             ; coluna
        call DESENHA_QUADRADO_BOTAO
    
        ;Escreve o exit do inicio
        mov BL, 15
        mov dh, 17                   ; linha
        mov dl, 18                   ; coluna
        add dh, 2                    ; linha
        mov bp, offset botao_exit
        call ESC_STRING
        
        dec dh                ; linha
        sub dl, 2             ; coluna
        call DESENHA_QUADRADO_BOTAO
        
        jmp SAIR
    ;FIM
select_start:
    ;Escreve o start de inicio
        mov bl, 15                   ; cor
        mov dh, 16                   ; linha
        mov dl, 18                   ; coluna
        mov bp, offset botao_start
        call ESC_STRING
        
        ;DEsenha o botao
        dec dh                ; linha
        sub dl, 2             ; coluna
        call DESENHA_QUADRADO_BOTAO
    ;FIM
    
    ;Escreve o exit do inicio
        mov BL, 0CH
        mov dh, 17                   ; linha
        mov dl, 18                   ; coluna
        add dh, 2                    ; linha
        mov bp, offset botao_exit
        call ESC_STRING
        
        dec dh                ; linha
        sub dl, 2             ; coluna
        call DESENHA_QUADRADO_BOTAO
        
        jmp SAIR
SAIR:
    pop DX 
    pop CX
    pop BX
    pop AX
    ret
endp

; Funcao para escrever texto na tela
; bl: cor
; dh: linha
; dl: coluna
; bp: end. inicio da string
ESC_STRING proc
    push es
    push ax
    push bx
    push dx
    push si
    push bp
    
    mov di, sp
    
    mov ax, ds
    mov es, ax
    
    mov bh, 0
    mov si, bp
    call CALCULA_TAM_STRING
    mov ah, 13h
    mov al, 1
    int 10h
    
    mov sp, di
    pop bp
    pop si
    pop dx
    pop bx
    pop ax
    pop es
    ret
endp

CALCULA_TAM_STRING proc
    push ax
    push si
    xor cx, cx
LOOP_TAM_STRING:
    xor ax, ax
    mov al, [si]
    cmp al, 36
    je FIM_TAM_STRING
    inc cx
    inc si
    
    jmp LOOP_TAM_STRING
    
FIM_TAM_STRING:
    pop si
    pop ax
    ret
    endp
    ret
endp

INICIA_VIDEO proc
    push AX

    mov AH, 00H
    mov AL, 13H
    
    int 10H
    
    pop AX
    ret
endp
    
INICIO:   
    ; Configura??o do DS
    mov ax, @data
    mov ds, ax
    mov es, ax
    
    call INICIA_VIDEO
    
    call TELA_INICIAL
    
    mov ah, 4ch
    int 21h
end INICIO 