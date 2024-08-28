include irvine32.inc
include Macros.inc

.data
	; IU Components
	letterCoords db		"     A    B    C    D    E    F    G    H  ", 10, 13,0
	boardRowBlack db    "* * *     * * *     * * *     * * *     ", 10, 13,
						"* * *     * * *     * * *     * * *     ", 10, 13,
						"* * *     * * *     * * *     * * *     ", 10, 13, 0

	boardRowWhite db    "     * * *     * * *     * * *     * * *", 10, 13,
						"     * * *     * * *     * * *     * * *", 10, 13,
						"     * * *     * * *     * * *     * * *", 10, 13, 0
	blackCell db "* * *", 10, 13,
				 "* * *", 10, 13,
				 "* * *", 10, 13, 0
	whiteCell db "     ", 10, 13,
				 "     ", 10, 13,
				 "     ", 10, 13, 0

	; Chess board position data
	chessBoard	byte  "R", "N", "B", "Q", "K", "B", "N", "R"  ; Fila 1 - Negras (A1 a H1)
				byte  "P", "P", "P", "P", "P", "P", "P", "P"  ; Fila 2 - Peones negros (A2 a H2)
				byte  "*", "*", "*", "*", "*", "*", "*", "*"  ; Fila 3 - Vacío (A3 a H3)
				byte  "*", "*", "*", "*", "*", "*", "*", "*"  ; Fila 4 - Vacío (A4 a H4)
				byte  "*", "*", "*", "*", "*", "*", "*", "*"  ; Fila 5 - Vacío (A5 a H5)
				byte  "*", "*", "*", "*", "*", "*", "*", "*"  ; Fila 6 - Vacío (A6 a H6)
				byte  "p", "p", "p", "p", "p", "p", "p", "p"  ; Fila 7 - Peones blancos (A7 a H7)
				byte  "r", "n", "b", "q", "k", "b", "n", "r", 0   ; Fila 8 - Blancas (A8 a H8)

	; Position Vars
	selectedCellX byte ?
	selectedCellY byte ?
	selectedCellIndex byte ?

.code
main proc
	;;lea edx, letterCoords
	;;call writestring

	mov ecx, 1
	printBoardRowsLoop:
		mov eax, ecx
		;;call writeint
		
		mov bl, 2
		div bl
		cmp ah, 0
		je isWhiteCell
		jne isBlackCell

		isWhiteCell: 
			lea edx, boardRowWhite
			jmp printCell
		isBlackCell: 
			lea edx, boardRowBlack
			jmp printCell

		printCell:
			call writestring
			inc ecx
			cmp ecx, 9
			jl 	printBoardRowsLoop

		mov dl, "T"
		mov ah, "A"
		mov al, 1
		call printCharacter
		mov dl, "C"
		mov ah, "B"
		mov al, 1
		call printCharacter
		mov dl, "A"
		mov ah, "C"
		mov al, 1
		call printCharacter
		mov dl, "K"
		mov ah, "D"
		mov al, 1
		call printCharacter
		mov dl, "Q"
		mov ah, "E"
		mov al, 1
		call printCharacter
		mov dl, "A"
		mov ah, "F"
		mov al, 1
		call printCharacter
		mov dl, "C"
		mov ah, "G"
		mov al, 1
		call printCharacter
		mov dl, "T"
		mov ah, "H"
		mov al, 1
		call printCharacter

mGotoxy 0, 25
exit
main endp

printCharacter proc
	; Args:
	; - dl: Caracter de la ficha ("p", "P", "r", "R", etc.)
	; - ah: Letra de la columna ("A" a "H")
	; - al: Número de la fila (1 a 8)
	
	; Obtiene la celda por coordenadas
	push edx
	call calcCellIndex
	call calcCellCenterCoords

	pop eax
	xor edx, edx
	mov dl, selectedCellIndex
	mov [chessBoard + edx], al  ; Almacena el carácter en la posición correcta del tablero
	
	; Llama a writestring para imprimir el carácter
	mGotoxy selectedCellX, selectedCellY
	mov al, [chessBoard + edx]
	call writechar

	ret

printCharacter endp

calcCellIndex proc
	; Args:
	; - ah: Column (A - H)
	; - al: Row (1 - 8)

	; Return:
	; - selectedCellIndex: cell index

	sub ah, 65       ; Pasa de ASCII ("A": 65 - "H": 72) a número (0 - 7)
	sub al, 1

	; Calculate the index of the cell
	; index = row * 8 + column
	mov dh, ah
	mov bl, 8
	mul bl            ; ax = row * 8
	add al, dh        ; al = col + row * 8

	mov selectedCellIndex, al

	ret
calcCellIndex endp

calcCellCenterCoords proc
	; Args:
    ; - selectedCellIndex: índice de la celda (0 a 63 para un tablero de 8x8)
    ; Return:
    ; - selectedCellX: coordenada x de la posición central de la celda
    ; - selectedCellY: coordenada y de la posición central de la celda
    local fila: byte
	local columna: byte

    ; Calcular la fila y la columna en el tablero
    mov ebx, 8         ; Número de columnas en el tablero
	mov eax, 0
    mov al, selectedCellIndex       ; Copiar índice a ecx
    div bl            ; ah = columna, al = fila

    mov columna, ah   ; Guardar la columna
    mov fila, al      ; Guardar la fila

    ; Calcular la coordenada x
	mov eax, 0
    mov al, columna   ; Mover la columna a eax
	mov bl, 5
    mul bl        ; Multiplicar la columna por 5 (ancho de la celda)
    add al, 2         ; Ajustar a la posición central sumando 2 (mitad de 5)
    mov selectedCellX, al       ; Guardar la coordenada x en edx

    ; Calcular la coordenada y
    mov al, fila      ; Mover la fila a eax
	mov bl, 3
    mul bl        ; Multiplicar la fila por 5 (altura de la celda)
    add al, 1         ; Ajustar a la posición central sumando 2 (mitad de 5)
    mov selectedCellY, al       ; Guardar la coordenada y en ecx

    ret
calcCellCenterCoords endp

end main