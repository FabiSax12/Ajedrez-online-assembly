include irvine32.inc
include Macros.inc

.data
	; Cloud Online Sync With File
	fileHandle handle ?
	fileName byte "data.txt", 0			; Nombre del archivo de entrada
    buffer byte 256 DUP(?)				; Buffer para leer el archivo
    bytesRead dword ?					; Para almacenar los bytes leídos
	playerId byte ?						; Para Sincronizar cual jugador juega primero (0 - 1)
	gameId dword ?						; Id en la base de datos de la partida

	; IU Components
	letterCoords db		"________________________________________",10,
						"  A    B    C    D    E    F    G    H  ", 10, 13,0

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

	hs	BYTE " ", 10, 13
        BYTE " ", 10, 13
		BYTE "___  ______  ______  ______  ______  ______  ______  ______  ______  ______  ______  ______  ______  ______  ______  ___", 10, 13
        BYTE " __)(__  __)(__  __)(__  __)(__  __)(__  __)(__  __)(__  __)(__  __)(__  __)(__  __)(__  __)(__  __)(__  __)(__  __)(__ ", 10, 13
        BYTE "(______)(______)(______)(______)(______)(______)(______)(______)(______)(______)(______)(______)(______)(______)(______)", 10, 13
        BYTE " ", 10, 13
        BYTE " ", 10, 13
		BYTE " ", 10, 13
        BYTE "                                (\=,",10,13
        BYTE "                              //  .\                                               |'-'-'|", 10, 13
        BYTE "                             (( \_  \        _____ _    _ ______  _____ _____      |_____|", 10, 13
        BYTE "                              ))  `\_)      / ____| |  | |  ____|/ ____/ ____|      |===|", 10 ,13
		BYTE "                             (/     \      | |    | |__| | |__  | (___| (___        |   |", 10, 13 
        BYTE "                              | _.-'|      | |    |  __  |  __|  \___ \\___ \       |   |", 10, 13
        BYTE "                               )___(       | |____| |  | | |____ ____) |___) |      )___(", 10, 13
		BYTE "                              (=====)       \_____|_|  |_|______|_____/_____/      (=====)", 10, 13
        BYTE "                              }====={                                              }====={", 10, 13
        BYTE "                             (_______)                                            (_______)", 10, 13                  
        BYTE " ", 10, 13
		BYTE "                                       (-----------)                (-----------)", 10, 13
        BYTE "                                       |   Nueva   |                |  Cargar   |", 10, 13
        BYTE "                                       |  partida  |                |  partida  |", 10, 13
        BYTE "                                       (-----------)                (-----------)", 10, 13
		BYTE "___  ______  ______  ______  ______  ______  ______  ______  ______  ______  ______  ______  ______  ______  ______  ___", 10, 13
        BYTE " __)(__  __)(__  __)(__  __)(__  __)(__  __)(__  __)(__  __)(__  __)(__  __)(__  __)(__  __)(__  __)(__  __)(__  __)(__ ", 10, 13
        BYTE "(______)(______)(______)(______)(______)(______)(______)(______)(______)(______)(______)(______)(______)(______)(______)", 10, 13, 0

	playerPieces db "prnbqk",0		; Piezas de los jugadores (Peón, Torre, Caballo, Alfil, Reina, Rey)

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
	backup dd 0 ; en caso de necesitar repaldar un registro
	i db 0
	j db 0

	;estructura de la Api de Windows para almacenar las coordenadas del cuirsor en x,y {1}
	;(código extraído de "https://stackoverflow.com/questions/50589401/how-to-get-current-cursor-position-in-masm")
    BufferInfo CONSOLE_SCREEN_BUFFER_INFO <>

	;Error messages
	badPrompt db "Valor incorrecto, intenta de nuevo!",0

	;User inputs
	fromCell byte 2 DUP(0),0
	toCell byte 2 DUP(0),0
	jugador1 byte 30 DUP(?)
	jugador2 byte 30 DUP(?)




.code
main proc
	
	lea edx, hs
	call writestring

	; Se presentan 2 opciones:
	; - Nueva Partida
	;	- Uno debe crear partida, lo cual genera un id unico y crea la partida en la base de datos.
	;	- El otro con ese id se puede unir.
	; 
	; - Cargar Partida
	;	- Ambos se unenen con el id de la partida

    call ReadChar
    cmp al, "1"
	je newGame
    cmp al, "2"
	je continueGame

	newGame:
		call Clrscr

		; Al ser el jugador que creo la partida sera el jugador 0
		mov playerId, 0
	
		call getMSeconds	; Generar un id
		mov gameId, eax		; Guardarlo

		; Subirlo a la base de datos
		call UploadGameId

		mWrite "El id de la nueva partida es: "
		mov eax, gameId
		call writeInt
		call Crlf
		mWrite "Compartelo con el otro jugador para que pueda unirse"
		call Crlf
		mWrite "Esperando al oponente..."

		call setOnline

		jmp wait_for_opponent_online  

	continueGame:
		call Clrscr

		mWrite "Id de la partida: "
		call readInt
		mov gameId, eax

		; Al ser el jugador que se unió, será el jugador 1
		mov playerId, 1
		jmp start_game


		
	registroUsuarios:
		call Clrscr

		mWrite "Ingrese el nickname del jugador 1: "
		mov edx, OFFSET jugador1	; Dirección del buffer
		mov ecx, 30					; Longitud máxima de la cadena
		call ReadString				; Llamada para leer la cadena

		call Clrscr

		mWrite "Ingrese el nickname del jugador 2: "
		mov edx, OFFSET jugador2	; Dirección del buffer
		mov ecx, 30					; Longitud máxima de la cadena
		call ReadString				; Llamada para leer la cadena

		call Clrscr              ; Limpia la pantalla




	wait_for_opponent_online:
		mov eax, 2000
		call delay

		call ReadDataFile
		call verifyOpponentIsOnline
		test eax, 1
		jz wait_for_opponent_online
		jnz start_game


	start_game:
	call clrscr
	call printInitialBoard
	call printSidebar
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
		mwrite "2.Personalizar"
		mGotoxy 60,6 
		mwrite "3.Salir"
		mgotoxy 60,10
		mwrite "Opcion: "

		options_input:
			mgotoxy 68,10
			mWriteSpace 50
			mGotoXY 68,10
			call ReadDec
			mgotoxy 60,11
			;jo  wrongInput
			cmp eax,1
			je  movePiece
			cmp eax,2
			je customTextColor
			cmp eax,3
			je endMenu

			wrongInput:
				mov  edx,OFFSET badPrompt
				call WriteString
				mgotoxy 68,10
				mwritespace 50
				mgotoxy 68,10
				jmp options_input        ;tipo de dato incorrecto

		movePiece:
			call movePieceProcess
			jmp initMenu
		customTextColor:
			call setColor
			mov eax,60
			call clearColumn
			jmp initMenu
	endMenu:
	ret
menu endp

waitForOpponent proc
	mgotoxy 60,8
	mwrite "Esperando movimiento del oponente..."

	waiting:
	mov eax, 1500
	call delay

	call readDataFile
	call getLastMove
	cmp dl, playerId
	je waiting

	; Mover ya en la matriz y mostrar el movimiento
	push bx						; Guardar la jugada
	call calcCellIndex	
	xor edx, edx
	mov dl, selectedCellIndex
	mov bl, chessBoard[edx]		; Guardar pieza
	mov chessBoard[edx], "*"	; Borrar de donde estaba

	pop ax						; Sacar la jugada
	push bx						; Guardar la pieza
	call calcCellIndex
	xor edx, edx
	mov dl, selectedCellIndex
	pop bx
	mov chessBoard[edx], bl

	call printInitialBoard
	mov eax, 60
	call clearColumn
	call menu

waitForOpponent endp

clearColumn proc			;Recibe por parametro la columna a limpiar en eax, el valor Y ira por defecto de 0 a 30
	mov ecx, 0
	clearColumnLoop:
		mGotoxy al,cl
		mwritespace 50
		inc ecx
		cmp ecx, 30
		jl clearColumnLoop
	ret
clearColumn endp

getXY PROC ;Obtiene la posición actual del cursor en la consola {1}
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
	cmp eax, 0
	je fileError

	ret

	fileError:
	exit
readDataFile endp

writeDataFile proc
	call readDataFile
	lea edx, fileName
	call CreateOutputFile
	mov fileHandle, eax
	jc fileError

	lea esi, buffer
	mov ecx, 0
	find_end_string:
		cmp buffer[ecx], 0			; Buscar final del string
		je found_end
		inc ecx
		jmp find_end_string

	found_end:
		mov al, playerId
		add al, 30h

		mov buffer[ecx], al
		mov buffer[ecx+1], ","
		mov dl, fromCell
		mov buffer[ecx+2], dl
		mov dl, fromCell[1]
		mov buffer[ecx+3], dl
		mov buffer[ecx+4], ","
		mov dl, toCell
		mov buffer[ecx+5], dl
		mov dl, toCell[1]
		mov buffer[ecx+6], dl
		mov buffer[ecx+7], 13
		mov buffer[ecx+8], 10

	mov eax, fileHandle
	lea edx, buffer
	add ecx, 8
	call WriteToFile
	mov eax, fileHandle
	call CloseFile

	fileError:
	ret
writeDataFile endp

getLastMove proc
	; Return;
	; - dl: Jugador (0 - 1)
	; - ax: Desde (ah: Columna | al: fila)
	; - bx: Hacia (ah: Columna | al: fila)

	mov esi, OFFSET buffer       ; Cargar la dirección del buffer en esi
    mov edi, OFFSET buffer       ; Cargar la dirección del buffer en edi
    add esi, LENGTHOF buffer - 2 ; Posicionar el puntero antes del último '\n'

    ; Retrocede hasta encontrar el salto de línea '\n' que precede la última línea
    mov ecx, LENGTHOF buffer     ; Usamos ecx como contador
	find_end_string:
		cmp BYTE PTR [esi], 0Ah      ; 0Ah es '\n' en ASCII
		je found_end                 ; Si es '\n', encontramos el inicio de la última línea
		dec esi                      ; Retrocede el puntero
		loop find_end_string

	found_end:
		sub esi, 8					; Mueve el puntero al inicio de la última línea

		; Ahora extraemos los valores separados por comas
		; Primer valor (antes de la primera coma) en DL
		mov dl, [esi]                ; Primer valor numérico (char) en dl
		inc esi                      ; Avanza el puntero

		inc esi						; Saltar la coma
    
		; Segundo valor (cadena antes de la segunda coma) en AX
		mov ah, [esi]                ; Almacena el primer carácter de la segunda cadena en AL
		mov al, [esi+1]              ; Almacena el segundo carácter en AH
		add esi, 2                   ; Avanza 2 posiciones
    
		; Salta la coma
		inc esi                      ; Salta la coma ','

		; Tercer valor (cadena antes del final de línea) en BX
		mov bh, [esi]                ; Almacena el primer carácter de la tercera cadena en BL
		mov bl, [esi+1]              ; Almacena el segundo carácter en BH

		sub bl, 30h
		sub al, 30h
		sub dl, 30h
    
		ret
getLastMove endp

uploadGameId proc

	lea edx, fileName
	call CreateOutputFile
	mov fileHandle, eax
	jc fileError

	mov eax, gameId
	lea edx, buffer
	call parseIntToString

	mov eax, fileHandle
	lea edx, buffer
	add ecx, 8
	call WriteToFile
	mov eax, fileHandle
	call CloseFile

	fileError:
	ret

uploadGameId endp

setOnline proc

	lea edx, fileName
	call CreateOutputFile
	mov fileHandle, eax
	jc fileError

	cmp playerId, 0
	jne player_1
	je player_0

	player_0:
		mov buffer[8], ","
		mov buffer[9], "1"

		cmp buffer[11], "0"
		je upload_changes
		cmp buffer[11], "1"
		je upload_changes

		; Si el del otro jugador no es ni 0 ni 1, etonces lo ponemos a 0
		mov buffer[10], ","
		mov buffer[11], "0"
		mov buffer[12], 13
		mov buffer[13], 10

		jmp upload_changes

	player_1:
		mov buffer[10], ","
		mov buffer[11], "1"
		mov buffer[12], 13
		mov buffer[13], 10

		cmp buffer[9], "0"
		je upload_changes
		cmp buffer[9], "1"
		je upload_changes

		; Si el del otro jugador no es ni 0 ni 1, etonces lo ponemos a 0
		mov buffer[8], ","
		mov buffer[9], "0"

	upload_changes:
	mov eax, fileHandle
	lea edx, buffer
	mov ecx, 12
	call WriteToFile
	mov eax, fileHandle
	call CloseFile

	fileError:
	ret

setOnline endp

verifyOpponentIsOnline proc
	cmp playerId, 0
	je player_1
	jne player_0

	player_0:
	cmp buffer[9], "1"
	je online
	jmp offline

	player_1:
	cmp buffer[11], "1"
	je online
	jmp offline

	online:
	mov eax, 1
	ret

	offline:
	mov eax, 0
	ret
verifyOpponentIsOnline endp

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
			je nextCell
			call writeChar
	
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
mGotoxy 0,0
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

isInRange proc

	; Args:
	; - dl: dato
    ; - al: desde
	; - ah: hasta
    ; Return:
	; - al: resultado booleano (1 o 0)

	cmp dl, al
	jl notValid
	cmp dl, ah
	jg notValid
	mov al, 1
	ret

	notValid:
	mov al, 0
	ret

isInRange endp

validateColumn proc
	; Args:
    ; - dl: caracter
    ; Return:
	; - al: resultado booleano (1 o 0)

	cmp dl, 65
	jl notValid
	cmp dl, 72
	jg notValid
	mov al, 1
	ret

	notValid:
	mov al, 0
	ret
validateColumn endp

validateRow proc
	; Args:
    ; - dl: caracter
    ; Return:
	; - al: resultado booleano (1 o 0)
	cmp dl, 49
	jl notValid
	cmp dl, 56
	jg notValid
	mov al, 1
	ret

	notValid:
	mov al, 0
	ret
validateRow endp


parseIntToString proc
	; Args:
	; - eax: number
	; - edx: buffer
	LOCAL resPtr:DWORD
	LOCAL bufferLocal[11]:BYTE
	LOCAL tempBuffer[11]:BYTE

	mov resPtr, edx
    
    mov ecx, 0                 ; Contador para la longitud de la cadena

convert_loop:
    xor edx, edx               ; Limpia edx antes de la división
	mov ebx, 10
    div ebx		               ; Divide EAX entre 10, el cociente queda en EAX, el resto en EDX (el dígito)
    add dl, 30h                ; Convierte el dígito (EDX) a su equivalente ASCII
    mov tempBuffer[ecx], dl    ; Guarda el dígito en el buffer temporal
    inc ecx                    ; Aumenta la posición en el buffer
    test eax, eax              ; Verifica si EAX es 0
    jnz convert_loop           ; Si no es 0, sigue dividiendo

    push ecx            ; Guarda la longitud de la cadena

    ; Invertir el buffer temporal y almacenarlo en el buffer final
    lea esi, tempBuffer			; Puntero al inicio del buffer temporal
    mov edi, resPtr        ; Puntero al inicio del buffer final
    pop ecx						; Cargar la longitud de la cadena

reverse_loop:
    dec ecx                    ; Decrementa ecx para obtener la posición correcta
    mov al, tempBuffer[ecx]    ; Carga el dígito invertido
    mov [edi], al              ; Mueve el dígito al buffer final
    inc edi                    ; Avanza el puntero en el buffer
    test ecx, ecx              ; Verifica si hemos terminado
    jnz reverse_loop           ; Si no es 0, sigue

    mov BYTE PTR [edi], 0      ; Termina la cadena con un carácter nulo

	ret

parseIntToString endp

movePieceProcess proc
	cmp playerId,0
	jne movement_init
	INVOKE Str_ucase, ADDR playerPieces

	movement_init:
		mov eax,60
		call clearColumn
		mGotoxy 60,3
		mwrite "Posicion de la ficha:"
		mGotoxy 60,4
		mwrite "Nueva posicion:"

	movement_input:

		; Desde cual celda quiere mover ------------------------
		mGotoxy 82, 3
		mReadString fromCell
		INVOKE Str_ucase, ADDR fromCell
		; Validar columna (A - H)
		mov dl, fromCell
		call validateColumn
		cmp al, 0
		jz wrongInputPiece
		; Validar fila (1 - 8)
		mov dl, fromCell[1]
		call validateRow
		cmp al, 0
		jz wrongInputPiece

		; Hacia cual celda quiere mover ------------------------
		mGotoxy 76, 4
		mReadString toCell
		INVOKE Str_ucase, ADDR toCell
		; Validar columna (A - H)
		mov dl, toCell
		call validateColumn
		cmp al, 0
		jz wrongInputPiece
		; Validar fila (1 - 8)
		mov dl, toCell[1]
		call validateRow
		cmp al, 0
		jz wrongInputPiece

		jmp valid_movement

		wrongInputPiece:
			mGotoxy 60,6
			lea edx, badPrompt
			call writeString
			xor edx, edx
			mGotoxy 82, 3
			mWriteSpace 2
			mGotoxy 76, 4
			mWriteSpace 2
			jmp movement_input

		emptyCell:
			mGotoxy 60,6
			mWrite "No hay una pieza en la celda seleccionada"
			mGotoxy 60,7
			call WaitMsg

			jmp movement_init

		invalidMove:
			mGotoxy 60,6
			mWrite "Movimiento invalido"
			mGotoxy 60,7
			call WaitMsg

			jmp movement_init

	valid_movement:
		mov ah, fromCell
		mov al, fromCell[1]
		sub al, 30h
		call calcCellIndex

		mGotoxy 60,6
		mWrite "Moviendo "
		movzx edx, selectedCellIndex
		mov al, chessBoard[edx] ;acá se ha caído varias veces (no he identificado el porqué)
		cmp al,"*"
		je emptyCell
		;---	

		; Verificar si es un peón y validar su movimiento
		cmp al, playerPieces[0]; Pregunta si la pieza seleccionada es igual a un peon
		je callPawnValidation
		; Falta agregar validaciones de otras piezas (torres, caballos, etc.)
		jmp continueMove

		callPawnValidation:
			; Configurar parámetros para validar el movimiento del peón
			call validatePawnMove ; Llamada al procedimiento de validación
			cmp al, 0             ; Validación fallida?
			je invalidMove        ; Si no es válido, regresar a entrada de movimiento
		;---
		continueMove:
			call writeChar

			mWrite " desde "
			lea edx, fromCell
			call writeString

			mWrite " hacia "
			lea edx, toCell
			call writeString

			; Mover ya en la matriz y mostrar el movimiento
			xor edx, edx
			movzx edx, selectedCellIndex
			mov bl, chessBoard[edx]		; Guardar pieza
			mov chessBoard[edx], "*"	; Borrar de donde estaba

			mov ah, toCell
			mov al, toCell[1]
			sub al, 30h
			push bx
			call calcCellIndex
			xor edx, edx
			mov dl, selectedCellIndex
			pop bx
			mov chessBoard[edx], bl

		; Escribir la jugada en el archivo
		call writeDataFile

		call printInitialBoard

		call waitForOpponent

	ret
movePieceProcess endp

validatePawnMove proc
	cmp playerId, 0			;SI el player id es 0, entonces este juega con las piezas negras(en mayúscula)
	;je validateWhitePawn
	xor eax,eax

	validateBlackPawn:
		; Peón negro: fila debe aumentar en 1 o 2 (primer movimiento)
		mov al, fromCell[1]
		sub al, toCell[1]    ; Comparar filas
		call absolute
		cmp al, 1			 ; Si el desplazamiento es 1, validar captura o movimiento normal
		je checkBlackCapture ; Verificar si hay captura
		cmp al, 2			 ; En caso de que se desplace 2 filas...
		je checkFirstMove	 ; Verificar que sea el primer movimiento
		jmp invalidMove		 ; Si no es niguno de los casos anteriores, el movimiento es invalido ;Revisado*(quitar esto)

	checkBlackCapture:
		; Movimiento diagonal para captura
		mov al, fromCell[0]
		sub al, toCell[0]    ; Comparar columnas (debe ser una casilla en diagonal) B->C or A<-B la distancia debe de ser 1
		call absolute
		cmp al, 1
		jne checkForwardMove  ; Si no es diagonal, verificar movimiento normal

		; Verificar si hay una pieza enemiga para capturar
		mov ah, toCell[0]
		mov al, toCell[1]
		sub al,30h
		call calcCellIndex
		movzx edi,selectedCellIndex
		mov al, chessBoard[edi]
		cmp al, '*'        ; La casilla no puede estar vacía para una captura
		je invalidMove
		cmp al, 'a'        ; Verificar que sea una pieza blanca (minúscula)
		jb invalidMove
		cmp al, 'z'
		ja invalidMove 

		; Captura válida
		mov al, 1
		jmp endPawnValidation 

	checkForwardMove:
		; Verificar movimiento hacia adelante (columna igual)
		mov al, fromCell[0]
		cmp al, toCell[0]
		jne invalidMove

		; Verificar que la casilla de destino esté vacía
		mov ah, toCell[0]
		mov al, toCell[1]
		sub al,30h
		call calcCellIndex
		movzx edi,selectedCellIndex
		mov al, chessBoard[edi]
		cmp al, '*'
		jne invalidMove

		; Movimiento válido hacia adelante
		mov al, 1
		jmp endPawnValidation													;Revisado*(quitar esto)----------------------------------

	checkFirstMove:
		; Primer movimiento: debe estar en fila 2
		mov al, fromCell[1]
		cmp al, '2'
		jne invalidMove

		; Verificar que las dos casillas estén vacías
		mov ah, toCell[0]
		mov al, toCell[1]
		sub al,30h
		call calcCellIndex
		movzx edi,selectedCellIndex
		mov al, chessBoard[edi]
		cmp al, '*'
		jne invalidMove

		; Verificar movimiento hacia adelante (columna igual)
		mov al, fromCell[0]
		cmp al, toCell[0]
		jne invalidMove

		; Casilla intermedia también debe estar vacía
		mov ah, fromCell[0]
		mov al, fromCell[1]
		sub al,30h
		call calcCellIndex
		movzx edi,selectedCellIndex
		add edi, 8h
		mov al, chessBoard[edi]
		cmp al, '*'
		jne invalidMove

		; Movimiento válido de dos casillas
		mov al, 1
		jmp endPawnValidation

	invalidMove:
		; Movimiento inválido
		mov al, 0

	endPawnValidation:
		ret
validatePawnMove endp

absolute proc
	; Args:
	;	Recibe el valor al que se le desea calcular el valor absoluto en AL

	test al, al           ; Si el bit más significativo (MSB) está en 1, es negativo
	jns absolute_end      ; Si no es negativo, no hay nada que hacer

	; Si es negativo, hacemos el complemento a dos para invertir el signo
	neg al                ; AL = -AL (inversión del signo)

	absolute_end:
		ret
absolute endp

setColor proc
	mov eax, 60
	call clearColumn

	; Primera columna en la columna 60
	mGotoxy 60,3
	mwrite "Seleccione el color del texto:"
	mGotoxy 60,4
	mwrite "1) Rojo"
	mGotoxy 60,5
	mwrite "2) Verde"
	mGotoxy 60,6
	mwrite "3) Azul"
	mGotoxy 60,7
	mwrite "4) Amarillo"
	
	; Segunda columna en la columna 70
	mGotoxy 80,4
	mwrite "5) Blanco"
	mGotoxy 80,5
	mwrite "6) Magenta"
	mGotoxy 80,6
	mwrite "7) Cian"
	mGotoxy 80,7
	mwrite "8) Celeste"

	; Leer entrada del usuario
	mGotoxy 60,10
	mwrite "Opcion: "
	call ReadDec  ; Leer número ingresado por el usuario (en eax)

	; Comparar el input y cambiar el color del texto según la elección
	cmp eax, 1
	je setColorRed
	cmp eax, 2
	je setColorGreen
	cmp eax, 3
	je setColorBlue
	cmp eax, 4
	je setColorYellow
	cmp eax, 5
	je setColorWhite
	cmp eax, 6
	je setColorMagenta
	cmp eax, 7
	je setColorCyan
	cmp eax, 8
	je setColorLightBlue
	jmp done

	; Subrutinas para establecer colores
	setColorRed:
		mov eax, red
		call SetTextColor
		jmp done

	setColorGreen:
		mov eax, green
		call SetTextColor
		jmp done

	setColorBlue:
		mov eax, blue
		call SetTextColor
		jmp done

	setColorYellow:
		mov eax, yellow
		call SetTextColor
		jmp done

	setColorWhite:
		mov eax, white
		call SetTextColor
		jmp done

	setColorMagenta:
		mov eax, magenta
		call SetTextColor
		jmp done

	setColorBlack:
		mov eax, black+(white*16)
		call SetTextColor
		jmp done

	setColorCyan:
		mov eax, cyan
		call SetTextColor
		jmp done

	setColorLightBlue:
		mov eax, lightBlue
		call SetTextColor
		jmp done

done:
	call printInitialBoard
	call printSidebar
	call printBoard
	ret
setColor endp
end main
