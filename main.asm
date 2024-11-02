;4- Fa?a uma rotina que receba um valor em AX 
;e calcule o seu fatorial. Retorne o valor em AX.
.model small

.stack 100H   ; define uma pilha de 256 bytes (100H)

.data 
    ; Constantes para pular linha
    CR EQU 13
    LF EQU 10
   
    ;Param
    memoria_video equ 0A000h
    
    bit_alto_DelayTela equ 1Eh
    bit_baixo_DelayTela equ 8480h

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

LIMPAR_TELA proc
    push ax
    push cx
    push dx
    
    mov ax, offset memoria_video
    
    mov ES, AX
    
    mov di, 0
    mov al, 0
    mov cx, 64000
    rep stosb
    
    pop dx
    pop cx
    pop ax
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

;Recebe em CX parte alta em microsegundos
;Recebe em DX parte baixa em microsegundos
DELAY proc
    push cx
    push dx
    
    mov ah, 86h
    int 15h
    
    pop dx
    pop cx
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
        
    call ESC_CHAR;Escreve o char do numero da fase no cursor
    
    mov cx, offset bit_alto_DelayTela
    mov dx, offset bit_baixo_DelayTela
    call DELAY
    
    call LIMPAR_TELA ; espera um determinado tempo
    
    pop AX
    pop CX
    pop DX
    pop BX
    ret
endp

ESC_CHAR proc
    push AX

    mov AH, 00h
    int 16H     

    pop AX
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
    call LIMPAR_TELA
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