.model small

.stack 100H 

.data 
;Constantes
    CR                                       equ 13
    LF                                       equ 10
    tecla_cima                               equ 72
    tecla_baixo                              equ 80
    tecla_espaco                             equ 32
    limite_array_naves                       equ 20
    Fator_de_progressao_fase                 equ 5
    Qtd_fases                                equ 3
    Tempo_das_fases                          equ 30
    
    progressao_pontuacao_naves_fugitivas     equ 10
    progressao_pontuacao_nave_viva           equ 1000
    
    memoria_video      equ 0A000h
    
;CONSTANTES DE TEMPO
    bit_alto_DelayMovNaveTelaInicial equ 0000h
    bit_baixo_DelayMovNaveTelaInicial equ 030D4h 
    
    bit_alto_DelayTela equ 001Eh
    bit_baixo_DelayTela equ 8480h

;CONSTANTES DE TEMPO 
    posicao_nave       dw       ?

    limite_inferior             equ 51220   ; 320 * (200 - 9) + 20 (200 - altura do desenho (9) - altura do terreno (20) - 11 (espa?o entre a nave vermelha e o terreno)) + coluna
    limite_superior             equ 6420    ; 320 * 20 + 20
    limite_direita              equ 32305   ; usado na tela inicial.
    limite_esquerda             equ 32000   ; usado na tela inicial
    
    posicao_nave_inimiga dw     ?           ; Usado no menu inicial
    nave_atual_inicio db        0           ; Define qual nave sera mostrada na animacao do menu inicial, 0 = nave aliada, 1 = nave inimiga.
    
;-------------------------------------------------------------------------------------------
    ;MENU
    timer_do_jogo dw [Tempo_das_fases]
    last_rtc_timer db ?
    score db "00000$"
;-------------------------------------------------------------------------------------------       
    ;Variaveis de jogo
    jogando db 0 ; status do jogo (em jogo=1; menu=0)
    naves_inimigas_na_fase db 0
    limite_naves_inimigas db 10
    score_num dw 0
    pontuacao_base_fugitivas dw 10
    quantidade_naves_fugitivas dw 0
    array_cores_naves db 09h, 0Ah, 0Ch, 0Dh, 0Eh, 07h, 05h, 04h
    array_naves_aliadas dw 8 dup(0)
    naves_aliadas_vivas db 8
    array_naves_inimigas dw [limite_array_naves] dup(0)
    array_cores_fases db 2, 3, 4
    ponto_por_nave_viva dw 1000
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
            
    ascii_fim_de_jogo db "                                    ", CR, LF
                      db "    _____ _  _        ____  _____   ", CR, LF
                      db "   /    // \/ \__/|  /  _ \/  __/   ", CR, LF
                      db "   |  __\| || |\/||  | | \||  \     ", CR, LF
                      db "   | |   | || |  ||  | |_/||  /_    ", CR, LF
                      db "   \_/   \_/\_/  \|  \____/\____\   ", CR, LF
                      db "                                    ", CR, LF
                      db "       _  ____  _____ ____          ", CR, LF
                      db "      / |/  _ \/  __//  _ \         ", CR, LF
                      db "      | || / \|| |  _| / \|         ", CR, LF
                      db "   /\_| || \_/|| |_//| \_/|         ", CR, LF
                      db "   \____/\____/\____\\____/         ", CR, LF
                      db "                                    $", CR, LF

                
;-------------------------------------------------------------------------------------------
;STRINGS
    botao_start db "Start$"
    botao_exit db "Exit$"
    string_fim db "F"
    string_fase db "SETOR - $"
    string_score db "Score: $"
    string_tempo db "Tempo: $"
;-------------------------------------------------------------------------------------------
.code  

; Funcao para desenhar os objetos
; SI: Posicao desenho na memoria
; DI: Posicao do primeiro pixel do desenho no video
; BL: Cor da nave
DESENHA_ELEMENTO proc
    push AX
    push BX
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
    pop BX
    pop AX
    ret
endp

;CH = hora (em formato BCD)
;CL = minutos (em formato BCD)
;DH = segundos (em formato BCD)
;DL = 0 se hor?rio padr?o e 1 se DST (Daylight Saving Time)
;CF = 0 = rel?gio funcionando e 1 = rel?gio parado
LER_RTC proc
    mov ah, 02h         
    int 1Ah            
    ret
endp

SALVAR_TEMPO_ATUAL proc
    PUSH AX
    PUSH DX
    PUSH CX
    
    call LER_RTC
    mov [last_rtc_timer], dh          
    
    POP CX
    POP DX
    POP AX
    ret
endp


INICIA_HUD proc
    push AX
    push BX
    push DX
    push SI
    
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
    
    mov SI, timer_do_jogo
    
    mov AX, SI
    call MUDA_TIMER
    
    pop SI
    pop DX
    pop BX
    pop AX
    stosw
    ret
endp 

LIMPA_TIMER proc
    push AX
    push CX
    PUSH DX
    
    call POS_CURSOR
    MOV BL, 0
    mov AH, 09h
    mov cx, 2
    mov AL, 32
    INT 10H
    
    POP DX
    pop CX
    pop AX
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
    
    CALL LIMPA_TIMER
    
    call POS_CURSOR
    call ESC_UINT16
    
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
    push BX
    push DI
    push AX
    
    call DESENHA_NAVES_ARRAY
    
    ;Inicia desenhando a nave na posi??o correta.
    MOV BL, 0Fh
    MOV [posicao_nave], 28820
    MOV DI, [posicao_nave]
    CALL DESENHA_NAVE
    
    pop AX
    pop DI
    pop BX
    ret
endp

INSTANCIA_NAVES_ARRAY proc
    push AX
    push BX
    push CX
    push DX
    push SI
    
    mov SI, offset array_naves_aliadas
    
    mov AX, 6400
    mov CX, 8
LOOP_POPULA_ARRAY:
    mov [SI], AX
    add AX, 6400
    add SI, 2
    loop LOOP_POPULA_ARRAY
    
    pop SI
    pop DX
    pop CX
    pop BX
    pop AX
    ret
endp

DESENHA_NAVES_ARRAY proc
    push BX
    push CX
    push AX
    push DI
    push SI
    
    mov SI, offset array_naves_aliadas
    xor AX, AX
    xor BX, BX
    
    mov CX, 8
LOOP_DESENHA_ARRAY:
    cmp word ptr [SI], 0
    jz CONTROLA_LOOP     
    
DESENHA:
    mov DI, offset array_cores_naves
    add DI, AX
    
    mov BL, [DI]
    mov DI, [SI]
    call DESENHA_NAVE
CONTROLA_LOOP:
    add SI, 2
    inc AL
    loop LOOP_DESENHA_ARRAY

    pop SI
    pop DI
    pop AX
    pop CX
    pop BX
    ret
endp

;RECEBE em DI o endereco para aonde ser? printado a nave
;RECEBE em BL a cor
DESENHA_NAVE proc
    push SI
    
    mov SI, offset nave
    call DESENHA_ELEMENTO
    
    pop SI
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

;RECEBE em DI o endereco de memoria que a nave quer ser plotada
;RETORNA BL = 1 quando tem algo, BL = 0 quando n?o tem
VERIFICA_SPAWN_NAVE_INIMIGA proc
    push DI
    push DX
    push AX
    push CX
    
    XOR AX, AX
    mov BL, 1
    
    MOV DL, 9
LOOP_REINICIA_LINHA:
    mov CX, 15
LOOP_VERIFICA_SPAWN_LINHA:
    mov AX, [DI]
    cmp AX, 0h
    jnz RET_VERIFICA_SPAWN_NAVE_INIMIGA
    
    inc DI
    loop LOOP_VERIFICA_SPAWN_LINHA
    
    add DI, 305
    
    dec DL
    cmp DL, 0 
    jnz LOOP_REINICIA_LINHA
    
    dec BL
RET_VERIFICA_SPAWN_NAVE_INIMIGA:
    pop CX
    pop AX
    pop DX
    pop DI
    ret
endp

CRIA_NAVE_INIMIGA proc
    push AX
    push BX
    push DX
    push SI
    push DI
    
    mov DL, [limite_naves_inimigas]
    cmp DL, naves_inimigas_na_fase
    jz SAIR_CRIA_NAVE
    
LOOP_GERA_ENDERECO_ALEATORIO:
    call GERA_ENDERECO_ALEATORIO
    call VERIFICA_SPAWN_NAVE_INIMIGA
    
    cmp BL, 0
    jnz SAIR_CRIA_NAVE
    
    call GET_ARRAY_NAVES_INIMIGAS
    
    cmp SI, 0
    jz SAIR_CRIA_NAVE
    
    mov [SI], DI
    
    call DESENHA_NAVE_INIMIGA
    
    inc [naves_inimigas_na_fase]
SAIR_CRIA_NAVE:
    pop DI
    pop SI
    pop DX
    pop BX
    pop AX
    ret
endp

GET_ARRAY_NAVES_INIMIGAS proc
    push CX
    push AX
    
    mov CX, limite_array_naves
    mov SI, offset array_naves_inimigas
LOOP_GET_NAVES:
    xor AX, AX
    cmp CX, 0
    jz SAIR_GET_NAVES
    dec CX
    
    mov AX, [SI]
    add SI, 2
    
    cmp AX, 0
    jnz LOOP_GET_NAVES
    
    sub SI, 2
    mov AX, SI
    
SAIR_GET_NAVES:
    mov SI, AX
    
    pop AX
    pop CX
    ret
endp

MOVIMENTAR_NAVES_INIMIGAS proc
    PUSH SI
    PUSH DI
    PUSH CX

    CMP [naves_inimigas_na_fase], 0                       
    JZ SAIR_MOVIMENTAR_NAVES         
    
    XOR CX, CX
    MOV CL, [limite_naves_inimigas]          
    mov SI, offset array_naves_inimigas 
ITERAR_NAVES:
    mov DI, [SI]                        

    CMP DI, 0 
    JZ PROXIMA_ITERACAO
    
    CALL MOVE_NAVE_ESQUERDA
    MOV [SI], DI
    cmp DI, 0
    jnz PROXIMA_ITERACAO
    
    dec [naves_inimigas_na_fase]

PROXIMA_ITERACAO:
    ADD SI, 2
    loop ITERAR_NAVES                   

SAIR_MOVIMENTAR_NAVES:
    POP CX
    POP DI
    POP SI

    ret
endp

;RECEBE em DI o endereco de memoria aonde deve ir a nave
DESENHA_NAVE_INIMIGA proc
    push SI
    push BX

    mov SI, offset nave_inimiga
    mov BL, 09h
    call DESENHA_ELEMENTO
    
    pop BX
    pop SI
    ret
endp

FLUXO_JOGO proc
    push AX
    push DX
    push CX

LOOP_FASE:
    ; Interrupcao de input do teclado, resultado em AX
    MOV AH, 01H
    INT 16h
    
    JZ CONTINUA_LOOP_FASE ; Zero flag significa que n?o houve input, ent?o s? roda o loop novamente
    
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
    
    JMP CONTINUA_LOOP_FASE ; REPETE O LOOP.
    
; Antes de continuar o loop, validaremos 1 segundo j? se passou.
CONTINUA_LOOP_FASE:
    call LER_RTC
    
    cmp dh, [last_rtc_timer]
    JNE ATUALIZA_TEMPO  
    jmp LOOP_FASE

ATUALIZA_TEMPO:
    mov AX, [timer_do_jogo]
    dec AX
    
    cmp AX, 0
    jz SAIR_FLUXO_JOGO
    
    call MOVIMENTAR_NAVES_INIMIGAS
    call CRIA_NAVE_INIMIGA
    
    call MUDA_TIMER
    call SALVAR_TEMPO_ATUAL
    MOV [timer_do_jogo], AX
    jmp LOOP_FASE
    
APERTOU_BAIXO:
    CALL MOVE_NAVE_BAIXO
    JMP CONTINUA_LOOP_FASE

APERTOU_CIMA:
    CALL MOVE_NAVE_CIMA
    JMP CONTINUA_LOOP_FASE

SAIR_FLUXO_JOGO:
    pop CX
    pop DX
    pop AX
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
    pop DX
    pop CX
    pop AX
    ret
endp
  
POS_CURSOR proc
    push ax
    push bx
    mov ah, 02;Codigo da funcao
    int 10h   ;Interrupcao
    pop bx
    pop ax
    ret
endp

;RETORNA em DI o endereco novo
;descricao: Gera endereco para spawn da nave
GERA_ENDERECO_ALEATORIO proc
    push AX
    push BX
    push CX
    push DX
    
;Gera linha retirando 20 da HUD e 20 do terreno
    mov BX, 149
    call GERA_NUM_ALEATORIO
    mov BX, 320         
    mul BX              
    
;Adiciona 20 linhas para pular o HUD
    add ax, 6400
    
    mov DI, AX
    
; Gerar a coluna aleat?ria ate 145 pois a nave tem 15 de largura
    mov BX, 145
    call GERA_NUM_ALEATORIO
    
    ;Soma 160 na coluna - 11 do mapa
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
;Descricao Funcao para pegar o contador de tempo
GERA_NUM_ALEATORIO proc
    push BX
    push CX
    push DX
    
    mov ah, 2Ch 
    int 21h
    
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
    
    POP AX
    pop si
    pop di
    pop cx
    pop dx
    ret
endp

; Verifica se o sprite 1 colide com o sprite 2
; AX = coordenada linear do sprite 1
; BX = coordenada linear do sprite 2
; ZF ativo = houve colis?o 
VERIFICA_COLISAO_SPRITE proc
    PUSH BX
    push CX
    push DX
    push DI
    PUSH SI
    
    ; Converte coordenada do sprite 1 para coordenada cartesiana
    xor DI, DI
    call ENDERECO_LINEAR_PARA_CARTESIANO
    push AX ; x
    mov CX, DX

    
    ; Converte coordenada do sprite 2 para coordenada cartesiana
    mov AX, BX
    call ENDERECO_LINEAR_PARA_CARTESIANO

    push AX
    push CX
    push DX

    ; Stack agora tem
    ; RectA.X
    ; RectB.X
    ; RectA.Y
    ; RectB.Y
    

    ; Verifica colisao na vertical
    ;RectA.Y1 > RectB.Y2 && RectA.Y2 < RectB.Y1
    ;AX > DX && CX < BX
    pop BX ; b.Y1
    pop AX ; a.Y1

    mov DI, 4 ; Itens na pilha


    mov CX, AX
    add CX, 15

    mov DX, BX
    add DX, 15

    cmp AX, DX
    jg __NAO_COLIDE ; RectA.Y1 > RectB.Y2? N?O h? colis?o.

    cmp CX, BX
    jl __NAO_COLIDE ; RectA.Y2 < RectB.Y1? N?O h? colis?o.

    ; Verifica colis?o horizontal
    pop AX ;aX1
    pop BX ;bX1

    xor DI, DI

    mov CX, AX
    add CX, 9 ; aX2

    mov DX, BX
    add DX, 9 ; bX2

    cmp AX, DX
    jg __NAO_COLIDE ; RectA.X1 > RectB.X2? N?O h? colis?o.

    cmp CX, BX
    jl __NAO_COLIDE ; RectA.X2 < RectB.X1? N?O h? colis?o.
    ; AX > DX && CX < BX

    mov CX, 1
    jmp __FIM_VERIFICA_COLISAO_SPRITE

    __NAO_COLIDE:
        mov CX, 0
        jmp __FIM_VERIFICA_COLISAO_SPRITE

    __FIM_VERIFICA_COLISAO_SPRITE:
        add SP, DI ; Desempilha os valores que ainda estao na pilha
 
        cmp CX, 1

        POP SI
        pop DI
        pop DX
        pop CX
        POP BX
    ret
endp

; AX: Endere?o linear
; Retorno:
; AX = Linha (Y)
; DX = Coluna (X)
ENDERECO_LINEAR_PARA_CARTESIANO PROC
    push BX

    xor DX, DX 
    mov BX, 320
    div BX  ; AX = Linha, DX = Coluna

    pop BX
    ret
endp

; DI: Endereco linear da nave inimiga
; ZF Se houver colisao
CHECK_COLISAO_NAVE_VIVA proc
    PUSH AX
    PUSH DX
    PUSH BX
    PUSH SI
    
    MOV BX, DI
    MOV AX, [posicao_nave]
    CALL VERIFICA_COLISAO_SPRITE
    JE colisao_nave_viva
    JMP fim_check_colisao_nave_viva
    
colisao_nave_viva:
    ; CMP [naves_aliadas_vivas], 0
    ; JE FIM_FASE
    ; CHAMA O FIM DA FASE POIS TODAS AS NAVES FORAM DESTRUÍDAS.
    
    mov SI, offset array_naves_aliadas 
    mov CX, 8                        
iterar_aliadas:
    cmp [SI], 0                        
    je continuar_loop
    
    push DI
    MOV DI, [SI]
    call APAGAR_ELEMENTO
    POP DI
    
    MOV word ptr [SI], 0  
    dec [naves_aliadas_vivas]
    
    ; Força o ZF para retornar.
    XOR CX, CX
    CMP CX, 0
    jmp fim_check_colisao_nave_viva
    
continuar_loop:
    add SI, 2                        
    loop iterar_aliadas          
    
fim_check_colisao_nave_viva:
    POP SI
    POP BX
    POP DX
    POP AX
    ret
endp

; DI: Endereco linear da nave inimiga
; Retorna:
; ZF Se houver colis?es
CHECK_COLISAO_NAVES PROC
    PUSH AX
    PUSH BX
    PUSH SI
    PUSH DI
    PUSH CX
    PUSH DX
    
    CALL CHECK_COLISAO_NAVE_VIVA
    JE colisao_encontrada_nave_viva
    
    MOV BX, DI
    
    mov SI, offset array_naves_aliadas ; SI aponta para o in?cio do array
    mov CX, 8                        ; N?mero de naves no array    
    XOR DX, DX                       ; Flag de colis?o

check_loop:
    mov AX, [SI]                     ; AX = Endere?o linear da nave aliada
    cmp AX, 0                        ; Verificar se o endere?o ? v?lido
    je proximo                       ; Se for 0, v? para a pr?xima nave
   
    CALL VERIFICA_COLISAO_SPRITE
    JE colisao_encontrada             ; ZF n?o est? ativo, n?o h? colis?es.
    JMP proximo

colisao_encontrada_nave_viva:
    MOV DX, 1 
    JMP fim
    
colisao_encontrada:
    MOV DX, 1 
    ; APAGA A NAVE ALIADA.
    MOV DI, [SI]
    call APAGAR_ELEMENTO
    ; Zera o endere?o da nave aliada que foi apagada
    MOV word ptr [SI], 0  
    dec [naves_aliadas_vivas]
    jmp proximo                        

proximo:
    add si, 2                        ; Pr?xima nave no array (2 bytes por endere?o)
    loop check_loop                  ; Repetir para todas as naves
    
fim:
    cmp DX, 1
    
    POP DX
    POP CX
    POP DI
    POP SI
    POP BX
    POP AX
    ret
endp

;DI: Posicao da nave inimiga
MOVE_NAVE_ESQUERDA proc
    push bx
    push si
    PUSH CX
    PUSH DX
    PUSH AX
    
    call APAGAR_ELEMENTO
    
    MOV AX, DI
    call ENDERECO_LINEAR_PARA_CARTESIANO
    MOV CX, DX 
    
    sub di, 10
    
    MOV AX, DI
    call ENDERECO_LINEAR_PARA_CARTESIANO
    CMP DX, CX 
    JG nave_fugiu
    
    CALL CHECK_COLISAO_NAVES
    jz zera_posicao_nave
    jmp continuar_move_nave_esquerda
    
nave_fugiu:
    inc [quantidade_naves_fugitivas]
    jmp zera_posicao_nave
    
continuar_move_nave_esquerda:
    MOV SI, offset nave_inimiga
    mov BL, 09H                     
    call DESENHA_ELEMENTO 
    JMP fim_move_nave_esquerda
    
zera_posicao_nave:
    mov di, 0
    jmp fim_move_nave_esquerda
    
fim_move_nave_esquerda:
    POP AX
    POP DX
    POP CX
    pop si
    pop bx
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
    mov di, limite_superior      
    
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
    mov di, limite_inferior
    
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
    MOV DI, [posicao_nave_inimiga]
    call MOVE_NAVE_ESQUERDA
    MOV [posicao_nave_inimiga], DI
    cmp DI, limite_esquerda
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

;AL = char do numero da fase (ASCII)
;BL = Cor
TELA_INICIAL_SETOR proc
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
    call INICIAR_JOGO
    ;call FASE_1
FIM_TELA_INICIAL:
    
    mov ah, 00h
    int 16h
    ;call LIMPAR_TELA
    ;call FIM_PROGRAMA
    ret
endp

INICIAR_JOGO proc
    push AX
    push BX
    push DX
    push CX
    
    call INSTANCIA_NAVES_ARRAY
    
    inc jogando
    mov [score_num], 0
    
    xor DL, DL
    mov CX, Qtd_fases
LOOP_DE_FASES:
    inc DL
    mov AL, 48
    
    add AL, DL
    mov BL, [array_cores_fases]
    inc array_cores_fases
    
    call TELA_INICIAL_SETOR
    call RESETA_VARIAVEIS_JOGO
    call ATUALIZA_SCORE
    call INICIA_HUD
    call CRIA_NAVES_INICIO
    call CRIAR_TERRENO
    
    call SALVAR_TEMPO_ATUAL
    
    call FLUXO_JOGO
    
    cmp jogando, 0
    jz FIM_JOGO
    
    call PROGRESSAO
    CALL PONTUACAO_FIM_FASE
    
    loop LOOP_DE_FASES
    
FIM_JOGO:
    call TELA_FINAL_JOGO

    pop CX
    pop DX
    pop BX
    pop AX
    ret
endp

PONTUACAO_FIM_FASE proc
    push SI
    push AX
    PUSH BX
    PUSH DX
    
    mov SI, offset ponto_por_nave_viva
    mov AX, [SI]
    
    mov SI, offset naves_aliadas_vivas
    MOV BX, [SI]
    MUL BX
    
    MOV DX, AX 
    
    mov SI, offset pontuacao_base_fugitivas
    MOV AX, [SI]
    
    mov SI, offset quantidade_naves_fugitivas
    MOV BX, [SI]
    MUL BX
    
    SUB AX, DX
    
    mov SI, offset score_num
    add AX, [SI]
    call MUDA_SCORE
    
    POP DX
    POP BX
    pop AX
    pop SI
    ret
endp

ATUALIZA_SCORE proc
    push BX
    push DX
    push BP
    
    mov BL, 2
    xor DX, DX
    mov DL, 6    ; coluna
    mov BP, offset score
    call ESC_STRING
    
    pop BP
    pop DX
    pop BX
    ret
endp

;recebe em AX o score
MUDA_SCORE proc
    push ax
    push bx
    push cx
    push dx
    push DI
    push SI
    
    cmp AX, 0
    JNL continua_muda_score
    MOV AX, 0
    
continua_muda_score:
    mov di, offset score_num
    mov [di], AX

    mov di, offset score   ; Apontar DI para o buffer
    add di, 4        ; Come?ar a preencher o buffer do ?ltimo d?gito (posi??o 4)

    mov cx, 5        ; N?mero de casas decimais a preencher
    xor bx, bx       ; Limpar BX para divis?o
    mov BX, 10
    
convert_loop_score:
    xor dx, dx       ; Limpar DX (divis?o de 16 bits por 10)
    div BX           ; Dividir AX por 10 (DX:AX / 10)
    add dl, '0'      ; Converter o resto (em DL) para ASCII
    mov [di], dl     ; Salvar o d?gito convertido no buffer
    dec di           ; Mover para o pr?ximo d?gito no buffer
    loop convert_loop_score

    ; Preencher zeros ? esquerda, se necess?rio
    mov si, offset score   ; Apontar SI para o in?cio do buffer
    mov cx, 5        ; Tamanho fixo de 5 d?gitos
fill_zeros:
    cmp byte ptr [si], '0' ; Verificar se ? zero
    jnz done_fill     ; Sair se encontrar o primeiro d?gito n?o-zero
    inc si            ; Avan?ar no buffer
    loop fill_zeros

done_fill:
    pop SI
    pop DI
    pop dx           ; Restaurar registradores
    pop cx
    pop bx
    pop ax
    ret
endp

TELA_FINAL_JOGO proc
    push BX
    push DX
    push BP
    push CX
    
    call LIMPAR_TELA
    
    ;Escreve a logo de inicio
    mov BL, 2 ; cor VERDE
    mov DH, 5 ; linha
    mov DL, 2 ; coluna
    mov BP, offset ascii_fim_de_jogo
    call ESC_STRING
    
    ; espera um determinado tempo
    mov CX, offset bit_alto_DelayTela
    mov DX, offset bit_baixo_DelayTela
    call DELAY
    
    call LIMPAR_TELA
    
    pop CX
    pop BP
    pop DX
    pop BX
    ret
endp

RESETA_VARIAVEIS_JOGO proc
    push AX
    push CX
    push SI
    
    mov [timer_do_jogo], Tempo_das_fases
    mov [quantidade_naves_fugitivas], 0
    
    mov SI, offset array_naves_inimigas
    mov CX, limite_array_naves
    mov AX, 0
LOOP_RESETA_ARRAY_NAVES:
    mov [SI], AX
    add SI, 2
    
    loop LOOP_RESETA_ARRAY_NAVES
    
    mov [naves_inimigas_na_fase], 0
    
    pop SI
    pop CX
    pop AX
    ret
endp

PROGRESSAO proc
    push SI
    push AX
    
    mov AX, Fator_de_progressao_fase
    mov SI, offset limite_naves_inimigas
    add [SI], AX
    
    MOV AX, progressao_pontuacao_naves_fugitivas
    MOV SI, offset pontuacao_base_fugitivas
    add [SI], AX
    
    MOV AX, progressao_pontuacao_nave_viva
    MOV SI, offset ponto_por_nave_viva
    add [SI], AX
    
    pop AX
    pop SI
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
    push CX
    
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
    
    pop CX
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

INICIA_VIDEO proc
    push AX

    mov AH, 00H
    mov AL, 13H
    
    int 10H
    
    pop AX
    ret
endp
    
INICIO:   
    mov ax, @data
    mov ds, ax
    mov es, ax
    
    call INICIA_VIDEO
    
    call TELA_INICIAL
    
    mov ah, 4ch
    int 21h
end INICIO
