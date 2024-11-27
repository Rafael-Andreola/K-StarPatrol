.model small

.stack 100H 

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
    
    posicao_nave       dw       ?
    tecla_cima                  equ 72
    tecla_baixo                 equ 80
    tecla_espaco                equ 32
    limite_inferior             equ 54740 ; 320 * (200 - 29) + 20 (200 - altura do desenho + altura do terreno)
    limite_superior             equ 6420  ; 320 * 20 + 20
    
    limite_direita              equ 32305   ; usado na tela inicial.
    limite_esquerda             equ 32000   ; usado na tela inicial
    
    posicao_nave_inimiga dw     ?           ; Usado no menu inicial
    nave_atual_inicio db        0           ; Define qual nave sera mostrada na animacao do menu inicial, 0 = nave aliada, 1 = nave inimiga.
;-------------------------------------------------------------------------------------------
    ;MENU
    timer_do_jogo dw 60
    score db "00000$"
    tempo db "60$"
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
                  
    terreno db 20 dup(0),  9 dup(06H),  20 dup(0),  8 dup(06H),  318 dup(0),  3 dup(06H),  102 dup(0) 
            db 14 dup(0),  17 dup(06H),  15 dup(0),  12 dup(06H),  141 dup(0),  8 dup(06H),  66 dup(0),  4 dup(06H),  58 dup(0),  6 dup(06H),  13 dup(0),  1 dup(06H),  19 dup(0),  5 dup(06H),  101 dup(0) 
            db 11 dup(0),  21 dup(06H),  12 dup(0),  14 dup(06H),  139 dup(0),  11 dup(06H),  63 dup(0),  7 dup(06H),  52 dup(0),  13 dup(06H),  8 dup(0),  5 dup(06H),  16 dup(0),  8 dup(06H),  100 dup(0) 
            db 8 dup(0),  51 dup(06H),  95 dup(0),  5 dup(06H),  24 dup(0),  5 dup(06H),  8 dup(0),  13 dup(06H),  7 dup(0),  3 dup(06H),  8 dup(0),  4 dup(06H),  38 dup(0),  10 dup(06H),  46 dup(0),  32 dup(06H),  13 dup(0),  12 dup(06H),  98 dup(0) 
            db 7 dup(0),  52 dup(06H),  94 dup(0),  7 dup(06H),  20 dup(0),  9 dup(06H),  4 dup(0),  19 dup(06H),  2 dup(0),  6 dup(06H),  6 dup(0),  7 dup(06H),  34 dup(0),  12 dup(06H),  24 dup(0),  4 dup(06H),  18 dup(0),  32 dup(06H),  13 dup(0),  12 dup(06H),  98 dup(0) 
            db 5 dup(0),  55 dup(06H),  81 dup(0),  2 dup(06H),  9 dup(0),  8 dup(06H),  15 dup(0),  46 dup(06H),  3 dup(0),  12 dup(06H),  31 dup(0),  12 dup(06H),  24 dup(0),  6 dup(06H),  14 dup(0),  35 dup(06H),  10 dup(0),  15 dup(06H),  97 dup(0) 
            db 4 dup(0),  57 dup(06H),  77 dup(0),  6 dup(06H),  7 dup(0),  10 dup(06H),  12 dup(0),  66 dup(06H),  26 dup(0),  15 dup(06H),  21 dup(0),  8 dup(06H),  11 dup(0),  40 dup(06H),  8 dup(0),  15 dup(06H),  17 dup(0),  8 dup(06H),  53 dup(0),  6 dup(06H),  13 dup(0) 
            db 3 dup(0),  58 dup(06H),  20 dup(0),  7 dup(06H),  43 dup(0BH),  4 dup(06H),  1 dup(0),  9 dup(06H),  6 dup(0),  10 dup(06H),  7 dup(0),  71 dup(06H),  25 dup(0),  17 dup(06H),  18 dup(0),  11 dup(06H),  9 dup(0),  43 dup(06H),  4 dup(0),  16 dup(06H),  17 dup(0BH),  16 dup(06H),  21 dup(0),  3 dup(06H),  1 dup(0),  5 dup(06H),  13 dup(0),  11 dup(06H),  11 dup(0) 
            db 1 dup(0),  61 dup(06H),  17 dup(0),  11 dup(06H),  40 dup(0BH),  16 dup(06H),  5 dup(0),  88 dup(06H),  12 dup(0),  31 dup(06H),  14 dup(0),  15 dup(06H),  8 dup(0),  63 dup(06H),  17 dup(0BH),  17 dup(06H),  18 dup(0),  14 dup(06H),  9 dup(0),  13 dup(06H),  10 dup(0) 
            db 63 dup(06H),  12 dup(0),  19 dup(06H),  32 dup(0BH),  21 dup(06H),  3 dup(0),  90 dup(06H),  10 dup(0),  34 dup(06H),  11 dup(0),  16 dup(06H),  8 dup(0),  63 dup(06H),  18 dup(0BH),  17 dup(06H),  16 dup(0),  17 dup(06H),  7 dup(0),  13 dup(06H),  6 dup(0),  4 dup(06H) 
            db 67 dup(06H),  2 dup(0),  25 dup(06H),  31 dup(0BH),  23 dup(06H),  1 dup(0),  93 dup(06H),  7 dup(0),  63 dup(06H),  6 dup(0),  65 dup(06H),  16 dup(0BH),  18 dup(06H),  16 dup(0),  38 dup(06H),  3 dup(0),  6 dup(06H) 
            db 95 dup(06H),  29 dup(0BH),  119 dup(06H),  5 dup(0),  64 dup(06H),  6 dup(0),  67 dup(06H),  13 dup(0BH),  28 dup(06H),  6 dup(0),  48 dup(06H) 
            db 95 dup(06H),  29 dup(0BH),  121 dup(06H),  1 dup(0BH),  68 dup(06H),  3 dup(0BH),  69 dup(06H),  11 dup(0BH),  83 dup(06H) 
            db 96 dup(06H),  27 dup(0BH),  264 dup(06H),  10 dup(0BH),  83 dup(06H) 
            db 96 dup(06H),  27 dup(0BH),  264 dup(06H),  10 dup(0BH),  83 dup(06H) 
            db 96 dup(06H),  26 dup(0BH),  266 dup(06H),  6 dup(0BH),  86 dup(06H) 
            db 97 dup(06H),  25 dup(0BH),  358 dup(06H) 
            db 99 dup(06H),  22 dup(0BH),  359 dup(06H) 
            db 100 dup(06H),  20 dup(0BH),  360 dup(06H) 
            db 105 dup(06H),  12 dup(0BH),  363 dup(06H) 
                
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
DESENHA_ELEMENTO proc
    push dx
    push cx
    push di
    push si
    
    mov dx, 9
DESENHA_ELEMENTO_LOOP:
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
    jnz DESENHA_ELEMENTO_LOOP
    
    jmp FIM_DESENHA_ELEMENTO
SET_COR:
    mov AL, BL
    stosb
    jmp CONTINUA_LOOP_DESENHO

FIM_DESENHA_ELEMENTO:
    pop si
    pop di
    pop cx
    pop dx
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
    call DESENHA_ELEMENTO
    
    mov BL, 0Ah
    add DI, AX
    call DESENHA_ELEMENTO
    
    mov BL, 0Ch
    add DI, AX
    call DESENHA_ELEMENTO
    
    mov BL, 0Dh
    add DI, AX
    call DESENHA_ELEMENTO
    
    mov BL, 0Eh
    add DI, AX
    call DESENHA_ELEMENTO
    
    mov BL, 07h
    add DI, AX
    call DESENHA_ELEMENTO
    
    mov BL, 05h
    add DI, AX
    call DESENHA_ELEMENTO
    
    mov BL, 04h
    add DI, AX
    call DESENHA_ELEMENTO
    
    ;Inicia desenhando a nave na posi??o correta.
    MOV BL, 0Fh
    MOV [posicao_nave], 28820
    MOV DI, [posicao_nave]
    CALL DESENHA_ELEMENTO

    ret
endp

CRIAR_TERRENO proc
    push dx
    push cx
    push di
    push si

    mov si, offset terreno  
    mov di, 57600          
    mov dx, 20              
    mov cx, 320             
CRIAR_TERRENO_LOOP:      
    mov cx, 320            
    rep movsb               
    add si, 160             
    
    dec dx                  
    cmp dx, 0               
    jnz CRIAR_TERRENO_LOOP 

    pop si
    pop di
    pop cx
    pop dx
    ret
endp

FASE_1 proc
    mov BL, 2
    mov AL, 49 ;1 em char
    
    call INICIO_FASE
    call INICIA_HUD
    call CRIA_NAVES_INICIO
    call CRIAR_TERRENO
    ;call GERA_ENDERECO_ALEATORIO
    ;mov BL, 04h
    ;call DESENHA_NAVE
    ;CALL RESETA_TEMPO_DE_JOGO
    
LOOP_FASE:
    ; Interrupcao de input do teclado, resultado em AX
    MOV AH, 01H
    INT 16h
    
    JZ LOOP_FASE ; Zero flag significa que n?o houve input, ent?o s? roda o loop novamente
    
    ; AH = 01h verifica se tem teclas pressionadas no buffer, essa parte vai capturar qual tecla foi pressionada.
    MOV AH, 00h
    INT 16h
    
    ; Compara se o usuario apertou a arrow down
    CMP AH, tecla_baixo
    JZ APERTOU_BAIXO
    
    ; Compara se o usuario apertou a arrow up
    CMP AH, tecla_cima
    JZ APERTOU_CIMA
    
    ; Compara se o usuario apertou a barra de espaco
    ;CMP AL, 32
    ;JZ APERTOU_ESPACO
    
    JMP LOOP_FASE ; REPETE O LOOP.

APERTOU_BAIXO:
    CALL MOVE_NAVE_BAIXO
    JMP LOOP_FASE

APERTOU_CIMA:
    CALL MOVE_NAVE_CIMA
    JMP LOOP_FASE
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

;RETORNA em DI o endereco novo
GERA_ENDERECO_ALEATORIO proc
    push AX
    push BX
    push CX
    push DX
    
    ;Gera linha retirando 20 da HUD e 20 do terreno
    mov BX, 160
    call GERA_NUM_ALEATORIO
    mov BX, 320         
    mul BX              
    
    ;Adiciona 20 linhas para pular o HUD
    add ax, 6400
    
    mov DI, AX
    
    ; Gerar a coluna aleat?ria ate 145 pois a nave tem 15 de largura
    mov BX, 145
    call GERA_NUM_ALEATORIO
    
    ;Soma 160 na coluna
    add AX, 160
    add DI, AX
    
    pop DX
    pop CX
    pop BX
    pop AX
    ret
endp

;RECEBE BX o limite
;RETORNA valor em AX
GERA_NUM_ALEATORIO proc
    push BX
    push CX
    push DX
    
    mov ah, 2Ch         ; Fun??o para pegar o contador de tempo
    int 21h             ; Chama a interrup??o 21h
    
    mov AX, DX
    xor DX, DX
    
    div BX
    
    mov AX ,DX
    
    pop DX
    pop CX
    pop BX
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
    mov AL, 218     
    mov CX, 1
    mov AH, 0AH
    int 10h
    ;FIM
    
    inc DL
    
    ;reta Horizontal Superior CX vezes
    call POS_CURSOR
    mov AL, 196
    mov CX, 7
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

; DI: Posicao do primeiro pixel do desenho na tela
APAGAR_ELEMENTO proc
    push dx
    push cx
    push di
    push si
    PUSH AX

    xor cx, cx
    mov al, 0h  
    mov dx, 9
APAGAR_ELEMENTO_LOOP:
    mov cx, 15 
    rep stosb    
    dec dx
    add di, 305
    cmp dx, 0
    jnz APAGAR_ELEMENTO_LOOP
    
    pop si
    pop di
    pop cx
    pop dx
    POP AX
    ret
endp

MOVE_NAVE_ESQUERDA proc
    push ax
    push bx
    push cx
    push si
    push di
    
    mov di, [posicao_nave_inimiga]              
    call APAGAR_ELEMENTO
    
    mov di, [posicao_nave_inimiga]
    sub di, 1                   ; Move 1 pixel para a esquerda.
    mov [posicao_nave_inimiga], di
    MOV SI, offset nave_inimiga
    mov BX, 9
    mov AX, 15
    mov BL, 0CH   ; VERMELHO
    call DESENHA_ELEMENTO   

    pop di
    pop si
    pop cx
    pop bx
    pop ax
    ret
endp

MOVE_NAVE_DIREITA proc
    push ax
    push bx
    push cx
    push si
    push di
    
    mov di, [posicao_nave]              
    call APAGAR_ELEMENTO
    
    mov di, [posicao_nave]
    add di, 1                   ; Move 1 p?xel para a direita.
    mov [posicao_nave], di
    MOV SI, offset nave
    mov BX, 9
    mov AX, 15
    mov BL, 0Fh                 ; branco
    call DESENHA_ELEMENTO   

    pop di
    pop si
    pop cx
    pop bx
    pop ax
    ret
endp

MOVE_NAVE_CIMA proc
    push ax
    push bx
    push cx
    push si
    push di
    
    mov di, [posicao_nave]        
    call APAGAR_ELEMENTO            
    
    mov di, [posicao_nave]
    sub di, 1600                   ; Move 5 linhas para cima (5 * 320)
    cmp di, limite_superior        
    jbe  ajusta_limite_superior 
    jmp continua_move_nave_cima

    
ajusta_limite_superior:
    mov di, [limite_superior]       
    
continua_move_nave_cima:
    mov [posicao_nave], di
    mov si, offset nave            
    mov bx, 9                      
    mov ax, 15          
    mov BL, 0Fh ;branco  
    call DESENHA_ELEMENTO          
    pop di
    pop si
    pop cx
    pop bx
    pop ax
    ret
endp

MOVE_NAVE_BAIXO proc
    push ax
    push bx
    push cx
    push si
    push di

    mov di, [posicao_nave] 
    call APAGAR_ELEMENTO
    
    mov di, [posicao_nave]
    add di, 1600                   ; Move 5 linhas para baixo (5 * 320)
    cmp di, limite_inferior       
    jae  ajusta_limite_inferior 
    jmp continua_move_nave_baixo
    
ajusta_limite_inferior:
    mov di, [limite_inferior] 
    
continua_move_nave_baixo:
    mov [posicao_nave], di
    mov si, offset nave            
    mov bx, 9                      
    mov ax, 15
    mov BL, 0Fh ;branco
    call DESENHA_ELEMENTO  
    pop di
    pop si
    pop cx
    pop bx
    pop ax
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

    cmp nave_atual_inicio, 0
    jz MOVER_ALIADA
    jmp MOVER_INIMIGA

MOVER_ALIADA:
    call MOVE_NAVE_DIREITA
    mov bx, [posicao_nave]
    cmp bx, limite_direita
    jae TROCAR_PARA_INIMIGA
    jmp FIM_ANIMACAO

MOVER_INIMIGA:
    call MOVE_NAVE_ESQUERDA
    mov bx, [posicao_nave_inimiga]
    cmp bx, limite_esquerda
    jbe TROCAR_PARA_ALIADA 
    jmp FIM_ANIMACAO

TROCAR_PARA_INIMIGA:
    mov di, [posicao_nave]
    call APAGAR_ELEMENTO
    mov [posicao_nave_inimiga], limite_direita 
    mov nave_atual_inicio, 1                   
    jmp FIM_ANIMACAO

TROCAR_PARA_ALIADA:
    mov di, [posicao_nave_inimiga]
    call APAGAR_ELEMENTO
    mov [posicao_nave], limite_esquerda       
    mov nave_atual_inicio, 0                  
    jmp FIM_ANIMACAO

FIM_ANIMACAO:
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

FLUXO_JOGO:
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

;AL = char do numero da fase (ASCII)
;BL = Cor
INICIO_FASE proc
    push BX
    push DX
    push CX
    push AX

    call LIMPAR_TELA
    
    ;Escreve a string de inicio da fase
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
    CALL DESENHA_ELEMENTO
    
    mov dh, 16
LOOP_SELECAO:
    call animacao_tela_inicial
    
    mov AH, 01H
    int 16h
    jz LOOP_SELECAO ; Zero flag significa que n?o houve input, ent?o s? roda o loop novamente
    
    ;verifica se tem teclas pressionadas no buffer, essa parte vai capturar qual tecla foi pressionada.
    mov AH, 0
    int 16h
    
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
    mov dh, 19 ; linha
    mov dl, 18 ; coluna
    mov bp, offset botao_exit
    call ESC_STRING
    
    dec dh    ; linha
    sub dl, 2 ; coluna
    call DESENHA_QUADRADO_BOTAO
    
    jmp SAIR
    ;FIM
select_start:
    ;Escreve o start de inicio
    mov bl, 15 ; cor
    mov dh, 16 ; linha
    mov dl, 18 ; coluna
    mov bp, offset botao_start
    call ESC_STRING
    
    ;DEsenha o botao
    dec dh     ; linha
    sub dl, 2  ; coluna
    call DESENHA_QUADRADO_BOTAO
    
    ;Escreve o exit do inicio
    mov BL, 0CH
    mov dh, 19 ; linha
    mov dl, 18 ; coluna
    mov bp, offset botao_exit
    call ESC_STRING
    
    dec dh ; linha
    sub dl, 2 ; coluna
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
