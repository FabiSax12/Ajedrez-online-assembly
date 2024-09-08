include irvine32.inc
include Macros.inc

.data
	; Cloud Online Sync
	cloudScript db "node index2.js"

	fileHandle handle ?
	fileName byte "data.txt", 0			; Nombre del archivo de entrada
    buffer byte 256 DUP(?)				; Buffer para leer el archivo
    bytesRead dword ?					; Para almacenar los bytes leídos

	; IU Components
	letterCoords db		"________________________________________",10,"  A    B    C    D    E    F    G    H  ", 10, 13,0
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
	lastX db ?
	lastY db ?
	strInput db 3 dup(0)
	currentPosition db 3 dup(0)
	newPosition db 3 dup (0)
	chessPiece db "*"

    BufferInfo CONSOLE_SCREEN_BUFFER_INFO <> ;estructura de la Api de Windows para almacenar las coordenadas del cuirsor en x,y {1}(código extraído de "https://stackoverflow.com/questions/50589401/how-to-get-current-cursor-position-in-masm")

	;Error messages
	badPrompt db "Valor incorrecto, intenta de nuevo!",0

.code
;MACROS


suma MACRO arg1,arg2 ;suma al argmento 1 el valor del argumento 2
	add arg1,arg2
ENDM

savePosition MACRO arg1 ;Guarda la posición actual en la variable currentPosition
	 mov edi, OFFSET strInput    ; Cargar la dirección de strInput en EDI
    mov al, [edi]               ; Cargar el primer byte de strInput en AL
    mov arg1[0], al             ; Guardar el primer byte en arg1[0]
    mov al, [edi+1]             ; Cargar el segundo byte de strInput en AL
    mov arg1[1], al             ; Guardar el segundo byte en arg1[1]
ENDM


main proc
	call printInitialBoard
	call printSidebar
	call readDataFile
	;mGotoxy 0, 27
	;mov edx, offset buffer
	;call writestring
	call menu
	mGotoxy 0,25

exit
main endp

menu proc
	initMenu:
		mGotoxy 60,3
		mwrite "Que desea hacer?" 
		mGotoxy 60,4 
		mwrite "1.Mover ficha"
		mGotoxy 60,5 
		mwrite "2.Salir"
		mgotoxy 60,6
		mwrite "Opcion: "
		read:
			call ReadDec
			mgotoxy 60,7
			jo  wrongInput
			cmp eax,1
			je  movePiece
			jmp endMenu
			wrongInput:
				mov  edx,OFFSET badPrompt
				call WriteString
				mgotoxy 68,6
				mwritespace 100
				mgotoxy 68,6
				jmp  read        ;tipo de dato incorrecto
			movePiece:			 ;En este apartado se solicita el ingreso de la posición actual de la ficha
				mov eax,60	
				call clearColumn
				mGotoxy 60,3
				mwrite "Posición de la ficha:"
				call getPiecePosition
				savePosition [currentPosition]
				mGotoxy 60,4
				mwrite "Nueva posición:"
				call getPiecePosition
				savePosition [newPosition]
				call movePieceProcess
				jmp initMenu
		endMenu:
			ret
menu endp

movePieceProcess proc
	;mov edx,OFFSET currentPosition
	;call writeString
	;mov edx,OFFSET newPosition
	;call writeString
	mov ah,currentPosition[0]	;se obtiene la columna de la posición actual (A-F)
	mov al,currentPosition[1]   ;se obtiene la fila de la posición actual (1-8)
	sub al,30h					;se convierte el valor de la fila a un valor numérico
	call calcCellIndex			;se calcula el índice de la celda
	movzx edi,selectedCellIndex	;indice de partida almacenado en edi
	
	mov ah,newPosition[0]		;se obtiene la columna de la nueva posición (A-F)
	mov al,newPosition[1]		;se obtiene la fila de la nueva posición (1-8)
	sub al,30h					;se convierte el valor de la fila a un valor numérico
	call calcCellIndex          ;se calcula el índice de la celda
	movzx esi,selectedCellIndex	;indice de destino almacenado en esi

	mov al,chessBoard[edi]		;se obtiene el valor de la celda de partida
	mov chessPiece,al			;se guarda el valor de la celda de partida en la variable chessPiece
	mov chessBoard[edi],"*"		;se limpia la celda de partida

	mov al,chessPiece			
	mov chessBoard[esi],al	;se coloca la ficha en la celda de destino
	mgotoxy 0,0
	call printInitialBoard		;se imprime el tablero
	call printBoard 			;se actualiza el posicionamiento de fichas
	mov eax,60
	call clearColumn			;se limpia la columna 60 para volver a imprimir el menu
	ret
movePieceProcess endp

getPiecePosition proc
	pusha						;se guarda el estado actual de los registros para evitar problemas con las llamadas a las funciones

	getPiecePositionInit:
		call cleanRegisters			;se limpian los registros
		call getXY

		mov edx, offset strInput	;se guarda la dirección de la cadena de entrada
		mov ecx, 3					;Cantidad de caracteres a leer (incluyendo el caracter nulo)
		call ReadString				;se lee la cadena de entrada
		;call writeDec
		INVOKE Str_ucase,ADDR strInput ;Pasa a mayuscula las letras (no afecta los numeros) Ejemplo: e4 -> E4
		;mov edx, offset strInput
		;call writeString

		cmp eax, 2					;se verifica el largo de la cadena
		jne wrongPosition			;En caso de no ser de 2 caracteres se muestra un mensaje de error

		cmp strInput[0],"A"
		jl wrongPosition
		cmp strInput[0],"H"
		jg wrongPosition
		cmp strInput[1],"1"
		jl wrongPosition
		cmp strInput[1],"8"
		jg wrongPosition
		jmp endGetPiecePosition		;La posición ingresada es valida

	wrongPosition:
		mov ah, lastY
		suma ah, 1
		mgotoxy 60,ah
		mov edx, offset badPrompt
		call WriteString
		suma ah, 1
		mgotoxy 60,ah
		call waitMsg
		mgotoxy lastX,lastY
		mwriteSpace 25
		mov al, 60
		mov ah, lastY
		suma ah,1
		mov edi,8
		call clearColumnSpecificY
		mgotoxy lastX,lastY

		jmp getPiecePositionInit


	endGetPiecePosition:
		popa						;se restaura el estado de los registros
		ret
getPiecePosition endp

clearColumn proc			;Recibe por parametro la columna a limpiar en eax, el valor Y ira por defecto de 0 a 30
	mov ecx, 0
	clearColumnLoop:
		mGotoxy al,cl
		mwritespace 30
		inc ecx
		cmp ecx, 30
		jl clearColumnLoop
	ret
clearColumn endp

clearColumnSpecificY proc			;Recibe por parametro la columna a limpiar en al, el valor Y en ah y hasta donde en edi
	movzx ecx, ah
	clearColumnLoopSpecificY:
		mGotoxy al,cl
		mwritespace 40
		inc ecx
		cmp ecx, edi
		jl clearColumnLoopSpecificY
	ret
clearColumnSpecificY endp

getXY PROC ;Obtiene la posición actual del cursor en la consola {1} y los almacena en las variables lastX y lastY
    invoke GetStdHandle, STD_OUTPUT_HANDLE						 ; Invoca la función GetStdHandle para obtener el manejador de la consola de salida estándar (STD_OUTPUT_HANDLE)
    invoke GetConsoleScreenBufferInfo, eax, ADDR BufferInfo      ; Invoca la función GetConsoleScreenBufferInfo para obtener información sobre el búfer de pantalla de la consola.
    movzx eax, BufferInfo.dwCursorPosition.X					 ; Obtiene la coordenada X (columna) de la posición del cursor desde la estructura BufferInfo.
	mov lastX, al
    ;call WriteInt
    movzx eax, BufferInfo.dwCursorPosition.Y					 ; Obtiene la coordenada Y (fila) de la posición del cursor desde la estructura BufferInfo.	
	mov lastY, al
	ret
getXY ENDP

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

readDataFile proc
	; Abrir el archivo de entrada
    mov edx, OFFSET fileName
    call OpenInputFile
	mov fileHandle, eax
    jc fileError                ; Si hay un error, salta a la etiqueta fileError

    ; Leer el contenido del archivo
    mov edx, OFFSET buffer      ; Almacenar datos leídos en el buffer
    mov ecx, SIZEOF buffer      ; Máximo tamaño a leer
    call ReadFromFile
    jc fileError                ; Si hay un error, salta a la etiqueta fileError
    mov bytesRead, eax          ; Guardar el número de bytes leídos

    ; Cerrar el archivo de entrada
	mov eax, fileHandle
    call CloseFile

	fileError:

	ret
readDataFile endp

printSidebar proc
	pusha
	xor edx,edx
	xor ecx,ecx
	xor ebx,ebx
	mov cl,0
	mov edx,0
	mov ch,2
	loopSidebar:
		xor eax,eax
		mgotoxy 41,cl
		mwrite "|"
		mov al,ch
		mov bl,3
		div bl
		cmp ah,0
		jne nextSidebar
		movzx eax,al
		call writeDec

		nextSidebar:
			inc cl
			inc ch
			cmp cl,24
		jl loopSidebar
		popa
	ret
printSidebar endp

printBoard proc
	call cleanRegisters
	mov bl,1
		resetX:
			mov bh,2
		boardLoop:		
			mgotoxy bh,bl 
			mov al,chessBoard[edi]
			cmp al, "*"
			je cellValidation
			call writeChar
			jmp nextCell

			cellValidation:
				
	
			nextCell:
				inc edi
				add bh,5
				cmp edi,64
				je printBoardEnd
				cmp bh,42
				je resetY
			jmp boardLoop

			resetY:
				add bl,3
				jmp resetX
	printBoardEnd:
	ret
printBoard endp


printInitialBoard proc ;Imprime el tablero de ajedrez en la consola
mov ecx, 1
	printBoardRowsLoop:
		mov eax, ecx
		;;call writeint
		
		mov bl, 2
		div bl
		cmp ah, 0
		je isBlackCell
		jne isWhiteCell

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

		lea edx, letterCoords
		call writestring
		call printBoard
		ret
printInitialBoard endp

cleanRegisters proc
	xor eax,eax
	xor ebx,ebx
	xor ecx,ecx
	xor edx,edx
	xor esi,esi
	xor edi,edi
	ret
cleanRegisters endp

end main