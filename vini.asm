.model small

.stack 100H   ; define uma pilha de 256 bytes (100H)

.data 
    ; Constantes para pular linha
    CR EQU 13
    LF EQU 10
   
    memoria_video equ 0A000h

    nave  db 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh,   0,   0,   0,   0
          db   0,   0, 0Fh, 0Fh,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
          db   0,   0, 0Fh, 0Fh,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
          db   0,   0, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh,   0,   0,   0,   0,   0,   0
          db   0,   0, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh
          db   0,   0, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh,   0,   0,   0,   0,   0,   0
          db   0,   0, 0Fh, 0Fh,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
          db   0,   0, 0Fh, 0Fh,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
          db 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh,   0,   0,   0,   0
          
    posicao_nave       dw       ?
    tecla_cima                  equ 72
    tecla_baixo                 equ 80
    tecla_espaco                equ 32
    limite_inferior             equ 54752 ; 320 * (200 - 29) + 32 (200 - altura do desenho + altura do terreno)
    limite_superior             equ 6432 ; 320 * 20 + 32
    
.code  

; Funcao para desenhar os objetos
; SI: Posicao desenho na memoria
; DI: Posicao do primeiro pixel do desenho no video
; BX: Altura
; AX: Largura
DESENHA_ELEMENTO proc
    push dx
    push cx
    push di
    push si
    push ax
    push bx
    
    mov dx, BX
DESENHA_ELEMENTO_LOOP:
    mov cx, AX
    rep movsb
    dec dx
    
    mov BX, 320
    sub BX, AX
    add di, BX
    
    cmp dx, 0
    jnz DESENHA_ELEMENTO_LOOP
    
    pop si
    pop di
    pop cx
    pop dx
    pop ax
    pop bx
    ret
endp

; DI: Posi??o do primeiro pixel do desenho na tela
APAGAR_ELEMENTO_NAVE proc
    push dx
    push cx
    push di
    push si
    PUSH AX

    xor cx, cx
    mov al, 0h  
    mov dx, 9
APAGAR_ELEMENTO_NAVE_LOOP:
    
    mov cx, 15 
    rep stosb    
    dec dx
    add di, 305
    cmp dx, 0
    jnz APAGAR_ELEMENTO_NAVE_LOOP

    pop si
    pop di
    pop cx
    pop dx
    POP AX
    ret
endp

; BX = 1 CIMA, BX = 0, BAIXO
; limite_inferior 4752 
; limite_superior 6432
MOVER_NAVE proc 
    PUSH SI
    PUSH DI
    PUSH AX
    PUSH BX
    
    mov DI, [posicao_nave]
    call APAGAR_ELEMENTO_NAVE
    
    MOV AX, [posicao_nave]
    
    CMP BX, 1
    JZ MOVER_CIMA
    JNZ MOVER_BAIXO
    
MOVER_BAIXO:
    ADD AX, 3200 ; Move 10 pixels para baixo (320 pixels por linha * 10 linhas)
    
    CMP AX, limite_inferior  
    JAE DEFINIR_LIMITE_INFERIOR
    JNA CONTINUAR_MOVIMENTO
    
DEFINIR_LIMITE_INFERIOR:
    MOV AX, limite_inferior
    
    JMP CONTINUAR_MOVIMENTO
    
MOVER_CIMA:
    SUB AX, 3200
    
    CMP AX, limite_superior
    JBE DEFINIR_LIMITE_SUPERIOR
    JNB CONTINUAR_MOVIMENTO
    
DEFINIR_LIMITE_SUPERIOR:
    MOV AX, limite_superior
    
    JMP CONTINUAR_MOVIMENTO
    
CONTINUAR_MOVIMENTO:
    MOV DI, AX
    PUSH AX
    MOV SI, offset nave
    MOV BX, 9
    MOV AX, 15
    CALL DESENHA_ELEMENTO
    POP AX
    MOV [posicao_nave], AX ; Salva a nova posi??o
    
    POP SI
    POP DI
    POP AX
    POP BX
    ret
endp

INICIO:   
    mov ax, @data
    mov ds, ax
    mov ax, memoria_video
    mov es, ax
    mov DI, AX
    mov SI, AX
    
    mov AH, 00H
    mov AL, 13H
    int 10H
    
    xor ax, ax
    xor bx, bx

    ; Inicia desenhando a nave na posi??o correta.
    MOV [posicao_nave], 32032
    MOV DI, [posicao_nave]
    MOV SI, offset nave
    mov BX, 9
    mov AX, 15
    CALL DESENHA_ELEMENTO

    JMP LOOP_DESENHO
   
LOOP_DESENHO:
    ; Interrup??o de input do teclado, resultado em AX
    MOV AH, 01H
    INT 16h
    
    JZ LOOP_DESENHO ; Zero flag significa que n?o houve input, ent?o s? roda o loop novamente
    
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
    
    JMP LOOP_DESENHO ; REPETE O LOOP.

APERTOU_BAIXO:
    PUSH BX
    mov BX, 0
    CALL MOVER_NAVE
    POP BX
    JMP LOOP_DESENHO

APERTOU_CIMA:
    PUSH BX
    mov BX, 1
    CALL MOVER_NAVE
    POP BX
    JMP LOOP_DESENHO

end INICIO 