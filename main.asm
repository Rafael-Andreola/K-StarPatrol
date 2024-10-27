;4- Fa?a uma rotina que receba um valor em AX 
;e calcule o seu fatorial. Retorne o valor em AX.
.model small

.stack 100H   ; define uma pilha de 256 bytes (100H)

.data 
    ; Constantes para pular linha
    CR EQU 13
    LF EQU 10
   
    memoria_video equ 0A000h

;Desenhos
    desenho_nave db 0Fh,0Fh,0Fh,0Fh,0Fh, 4 , 4 , 4 , 0 , 0
                 db 0Fh,0Fh,0Fh,0Fh,0Fh, 0 , 0 , 0 , 0 , 0
                 db  0 ,0Fh,0Fh,0Fh, 0 , 0 , 0 , 0 , 0 , 0
                 db  0 , 4 ,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh, 0 , 0
                 db  0 , 0 , 4 ,0Fh, 1 , 1 ,0Fh,0Fh,0Fh, 4
                 db  0 , 0 , 4 ,0Fh, 1 , 1 ,0Fh,0Fh,0Fh, 4
                 db  0 , 4 ,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh, 0 , 0
                 db  0 ,0Fh,0Fh,0Fh, 0 , 0 , 0 , 0 , 0 , 0
                 db 0Fh,0Fh,0Fh,0Fh,0Fh, 0 , 0 , 0 , 0 , 0
                 db 0Fh,0Fh,0Fh,0Fh,0Fh, 4 , 4 , 4 , 0 , 0
    
    logo_inicio db "       __ __    ______           ", CR, LF
                db "      / // /___/ __/ /____ _____ ", CR, LF
                db "     /    /___/\ \/ __/ _ `/ __/ ", CR, LF
                db "    /_/\_\   /___/\__/\_,_/_/    ", CR, LF
                db "          ___       __           __ ", CR, LF
                db "         / _ \___ _/ /________  / / ", CR, LF
                db "        / ___/ _ `/ __/ __/ _ \/ /  ", CR, LF
                db "       /_/   \_,_/\__/_/  \___/_/   $", CR, LF
                
                
;STRINGS
    botao_start db "Start$"
    botao_exit db "Exit$"
    string_fim db "F"
    string_fase db "FASE - $"
.code  

; Escreve na tela um caractere armazenado em DL     
ESC_CHAR proc
 push AX    ; salvar o reg AX
 mov AH, 2
 int 21H
 pop AX     ; restaurar o reg AX
 ret  
endp

LIMPAR_TELA proc
    push ax
    push cx
    push dx
    
    mov di, 0
    mov al, 0
    mov cx, 64000
    rep stosb
    
    pop dx
    pop cx
    pop ax
    ret
    
endp
   
; Escreve na tela um inteiro sem sinal    
; de 16 bits armazenado no registrador AX
ESC_UINT16 proc 
    push AX      ; Salvar registradores utilizados na proc
    push BX
    push CX
    push DX 
       
    mov BX, 10   ; divis?es sucessivas por 10
    xor CX, CX   ; contador de d?gitos
      
LACO_DIV:
    xor DX, DX   ; zerar DX pois o dividendo ? DXAX
    div BX       ; divis?o para separar o d?gito em DX
    
    push DX      ; empilhar o d?gito
    inc CX       ; incrementa o contador de d?gitos
     
    cmp AX, 0    ; AX chegou a 0?
    jnz LACO_DIV ; enquanto AX diferente de 0 salte para LACO_DIV
           
 LACO_ESCDIG:   
    pop DX       ; desempilha o d?gito    
    add DL, '0'  ; converter o d?gito para ASCII
    call ESC_CHAR               
    loop LACO_ESCDIG ; decrementa o contador de d?gitos
    
    pop DX       ; Restaurar registradores utilizados na proc
    pop CX
    pop BX
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

; Funcao para trocar os [] das opcoes
    INDICADOR_OPCAO proc
    push DX
    push CX
    mov CH, DH
    cmp DH, 18
    jz APAGA_CIMA
    
    add DH, 2
    jmp LIMPA_INDICADOR
    
APAGA_CIMA:                   ; apagar as [ ] da linha de cima
    sub dh, 2
    
LIMPA_INDICADOR:
    call POS_CURSOR
    mov cl, dl
    sub dh, 2
    mov dl, 32
    call ESC_CHAR
    mov dl, 26
    add dh, 2
    call POS_CURSOR
    mov dl, 32
    call ESC_CHAR
    
    mov dx, cx
    call POS_CURSOR
    
    mov dl, 91
    call ESC_CHAR
    mov dl, 26
    call POS_CURSOR
    mov dl, 93
    CALL ESC_CHAR
    
    mov dl, 31
    call POS_CURSOR
    
    pop cx
    pop dx
    ret
endp 

; Escreve na tela um inteiro COM sinal    
; de 16 bits armazenado no registrador AX
ESC_INT16 proc 
    push AX         
    cmp AX, 0 ; Se AX < 0, SF = 1
    jns ESCREVE_NUMERO
     
    ; Escrever o sinal de menos
    mov DL, '-'    
    call ESC_CHAR 
     
    neg AX ; Inverte o sinal 
    
ESCREVE_NUMERO:
    call ESC_UINT16

    pop AX
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
    
    mov dx, 10
DESENHA_ELEMENTO_LOOP:
    mov cx, 10
    rep movsb
    dec dx
    add di, 310
    cmp dx, 0
    jnz DESENHA_ELEMENTO_LOOP
    
    pop si
    pop di
    pop cx
    pop dx
    ret
endp

; Ler os direcionais do teclado
; retorna o caractere em AL
LER_KEY proc
    mov AH, 0
    int 16h
    ret
    endp

;Desenha quadrado
; BL cor
; DH linha inicial
; DL coluna inicial
; Largura CX  
DESENHA_QUADRADO_BOTAO proc
    push AX    
    push BX
    push DX
    push CX
    
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
    
    pop CX
    push CX
    
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
    
    pop CX
    push CX
    
    inc CX
    
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
     
    pop CX
    pop DX
    pop BX
    pop AX
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
    
    mov CX, 1
    mov BH, 1
    mov AH, 09H
    int 10H
        
    mov AH, 00h
    int 16H      ;Escreve o char do numero da fase no cursor
    
    call LER_KEY
    
    call LIMPAR_TELA
    
    pop AX
    pop CX
    pop DX
    pop BX
    ret
endp

TELA_INICIAL proc

    mov ax, memoria_video
    
    ;Escreve a logo de inicio
    mov BL, 2 ; cor VERDE
    mov DH, 0 ; linha
    mov DL, 0 ; coluna
    mov BP, offset logo_inicio
    call ESC_STRING
   
    xor dx,dx
    xor bx, bx
    ;FIM
    
    ;Escreve o start de inicio com o botao
    mov BL, 0CH   ; cor VERMELHO
    mov DH, 16    ; linha
    mov DL, 18    ; coluna
    mov BP, offset botao_start
    call ESC_STRING
    
    ;Desenha o botao
    mov CX, 7   ;Largura do botao
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
    
    mov CX, 7             ;Largura do botao
    dec DH                ; linha
    sub DL, 2             ; coluna
    call DESENHA_QUADRADO_BOTAO
    ;FIM
    
    ; SI: Posicao desenho na memoria
    ; DI: Posicao do primeiro pixel do desenho no video 
    mov AX,offset memoria_video 
    mov ES, AX 
    mov AL, 100 ;linha
    mov BX, 320
    mul BX
    add AX, 10 ; coluna
    mov DI, AX
    mov SI, offset desenho_nave
    call DESENHA_ELEMENTO
    
    ; SI: Posicao desenho na memoria
    ; DI: Posicao do primeiro pixel do desenho no video
    mov AL, 49 ;linha
    mov BX, 320
    mul BX
    add AX, 235 ; coluna
    mov DI, AX
    call DESENHA_ELEMENTO
    
    mov DH, 16
Selecao:
    call LER_KEY
    cmp AH, 48H  ;comp se e seta pra cima
    je TROCA_SELECAO
    cmp AH, 50H  ;comp se e seta pra baixo
    je TROCA_SELECAO
    
    cmp AL, 0Dh ;comp se e tecla enter
    je FIM_MENU_INICIAL
    jne Selecao

TROCA_SELECAO:
    cmp dh, 16
    jz TROCA_pra_exit
    jnz TROCA_pra_start

TROCA_pra_start:
    dec dh
    call TROCA_COR_BOTOES
    jmp Selecao
TROCA_pra_exit:
    inc DH
    call TROCA_COR_BOTOES
    jmp Selecao
    
FIM_MENU_INICIAL:
    cmp DH, 16
    jz CHAMA_INICIO
    jnz FIM_TELA_INICIAL
    
CHAMA_INICIO:
    ;call INICIAR_JOGO
    mov BL, 2
    mov AL, 49
    call INICIO_FASE
    
FIM_TELA_INICIAL:
    ;call LIMPAR_TELA
    ;call FIM_PROGRAMA
    ret
endp

TROCA_COR_BOTOES:
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
        mov CX, 7             ;Largura do botao
        dec dh                ; linha
        sub dl, 2             ; coluna
        call DESENHA_QUADRADO_BOTAO
    ;FIM
    
    ;Escreve o exit do inicio
        mov BL, 15
        mov dh, 17                   ; linha
        mov dl, 18                   ; coluna
        add dh, 2                    ; linha
        mov bp, offset botao_exit
        call ESC_STRING
        
        mov CX, 7             ;Largura do botao
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
        mov CX, 7             ;Largura do botao
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
        
        mov CX, 7             ;Largura do botao
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