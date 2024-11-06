.model small

.stack 100H   ; define uma pilha de 256 bytes (100H)

.data 
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

; DI: Posicao do primeiro pixel do desenho na tela
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

MOVE_NAVE_CIMA proc
    push ax
    push bx
    push cx
    push si
    push di
    
    mov bx, posicao_nave
    
    cmp bx, limite_superior
    jbe FIM_MOVE_NAVE_CIMA
    
    mov ax, memoria_video
    mov ds, ax
    
    mov dx, 15       ; Número de linhas para mover
    mov si, bx       
    mov di, bx       
    sub di, 1600     ; Move 5 linha para cima
    push di          ; Empilha poder salvar a nova posição da nave
    
MOVE_NAVE_CIMA_LOOP:
    mov cx, 15       ; Largura
    rep movsb        
    dec dx           
    add di, 305      ; Pula para a linha anterior
    add si, 305     
    cmp dx, 0        
    jnz MOVE_NAVE_CIMA_LOOP
    
    pop di           ; Desempilha a nova posição da nave
    mov bx, di       ; Atualiza BX com a nova posição da nave
    
    mov ax, @data
    mov ds, ax
    
    mov posicao_nave, bx

FIM_MOVE_NAVE_CIMA:
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
    
    mov bx, posicao_nave  ; Carrega a posição atual da nave
    
    cmp bx, limite_inferior  ; Verifica se a nave atingiu o limite inferior
    jae FIM_MOVE_NAVE_BAIXO  ; Se já atingiu o limite inferior, não move a nave

    mov ax, memoria_video
    mov ds, ax
    
    mov dx, 15         ; Número de linhas para mover
    mov si, bx         
    mov di, bx         
    add di, 1600       ; Move 5 linha para baixo
    push di            ; Empilha para salvar a nova posição da nave
    
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
    CALL MOVE_NAVE_BAIXO
    JMP LOOP_DESENHO

APERTOU_CIMA:
    CALL MOVE_NAVE_CIMA
    JMP LOOP_DESENHO

end INICIO 
