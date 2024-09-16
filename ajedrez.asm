include irvine32.inc
include Macros.inc

.data
	; Cloud Online Sync With File
	fileHandle handle ?
	fileName byte "data.txt", 0			; Nombre del archivo de entrada
    buffer byte 256 DUP(?)				; Buffer para leer el archivo
	auxBuffer byte 256 DUP(?)			; Buffer para auxiliar el principal
    bytesRead dword ?					; Para almacenar los bytes leídos
	turn byte ?							; Para Sincronizar cual jugador juega primero (0 - 1)
	gameId dword ?						; Id en la base de datos de la partida
	playerId byte ?						; Id del jugador en la base de datos

	; Sync instructions
	signup_i byte "register", 13, 10, 0
	login_i byte "login", 13, 10, 0
	create_i byte "create", 13, 10, 0
	games_i byte "games", 13, 10, 0
	join_i byte "join", 13, 10, 0
	playing_i byte "playing", 13, 10, 0
	length_i byte 0

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
		BYTE "                (-----------)            (-----------)            (-----------)            (-----------)", 10, 13
        BYTE "                |  Crear    |            |  Iniciar  |            |   Nueva   |            |  Cargar   |", 10, 13
        BYTE "                |  Cuenta   |            |  Sesion   |            |  partida  |            |  partida  |", 10, 13
        BYTE "                (-----------)            (-----------)            (-----------)            (-----------)", 10, 13
		BYTE "___  ______  ______  ______  ______  ______  ______  ______  ______  ______  ______  ______  ______  ______  ______  ___", 10, 13
        BYTE " __)(__  __)(__  __)(__  __)(__  __)(__  __)(__  __)(__  __)(__  __)(__  __)(__  __)(__  __)(__  __)(__  __)(__  __)(__ ", 10, 13
        BYTE "(______)(______)(______)(______)(______)(______)(______)(______)(______)(______)(______)(______)(______)(______)(______)", 10, 13, 0

	sis	BYTE " ",10 ,13
		BYTE " ",10 ,13
		BYTE "		     __  ______  ______  ______  ______  ______  ______  ______  ______  ______  __",10 ,13
		BYTE "		    (__)(__  __)(_   __)( _  __)(__   _)( _  __)(__  _ )(_   __)(__   _)(__  _ )(__)",10 ,13
		BYTE "		    (_  ___)(______)(______)(______)(______)(______)(______)(______)(______)(_  ___)",10 ,13
		BYTE "		    ( _  __)                                                                ( _  __)",10 ,13
		BYTE "		    (__   _)       ___      _    _             ___         _                (__   _)",10 ,13
		BYTE "		    (_  ___)      |_ _|_ _ (_)__(_)__ _ _ _   / __| ___ __(_)___ _ _        (_  ___)",10 ,13
		BYTE "		    (__   _)       | || ' \| / _| / _` | '_|  \__ \/ -_|_-< / _ \ ' \       (__   _)",10 ,13
		BYTE "		    ( _  __)      |___|_||_|_\__|_\__,_|_|    |___/\___/__/_\___/_||_|      ( _  __)",10 ,13
		BYTE "		    (__   _)                                                                (__   _)",10 ,13
		BYTE "		    (_  ___)                                                                (_  ___)",10 ,13
		BYTE "		    ( _  __)                            Usuario                             ( _  __)",10 ,13
		BYTE "		    (__   _)                       (----------------)                       (__   _)",10 ,13
		BYTE "                    (_  ___)                       |                |                       (_  ___)",10 ,13
		BYTE "		    (__   _)                       (----------------)                       (__   _)",10 ,13
		BYTE "		    ( _  __)                                                                ( _  __)",10 ,13
		BYTE "		    (__   _)                                                                (__   _)",10 ,13
		BYTE "		    (_  ___)                           Contrasena                           (_  ___)",10 ,13
		BYTE "		    (__   _)                       (----------------)                       (__   _)",10 ,13
		BYTE "		    ( _  __)                       |                |                       ( _  __)",10 ,13
		BYTE "		    (__   _)                       (----------------)                       (_    _)",10 ,13
		BYTE "		    (__   _)                                                                (__   _)",10 ,13
		BYTE "		    (_  ___) ______  ______  ______  ______  ______  ______  ______  ______ (_  ___)",10 ,13
		BYTE "		    (__  _ )(__  _ )(__   _)(_   __)( _  __)(_   __)(__   _)(__   _)(_   __)( _  __)",10 ,13
		BYTE "		    (__)(______)(______)(______)(______)(______)(______)(______)(______)(______)(__)",10 ,13, 0

	sus	BYTE " ",10 ,13
		BYTE " ",10 ,13
		BYTE "		     __  ______  ______  ______  ______  ______  ______  ______  ______  ______  __",10 ,13
		BYTE "		    (__)(__  __)(_   __)( _  __)(__   _)( _  __)(__  _ )(_   __)(__   _)(__  _ )(__)",10 ,13
		BYTE "		    (_  ___)(______)(______)(______)(______)(______)(______)(______)(______)(_  ___)",10 ,13
		BYTE "		    ( _  __)             ___          _    _            _                   ( _  __)",10 ,13
		BYTE "		    (__   _)            | _ \___ __ _(_)__| |_ _ _ __ _| |_ ___             (__   _)",10 ,13
		BYTE "		    (_  ___)            |   / -_) _` | (_-<  _| '_/ _` |  _/ -_)            (_  ___)",10 ,13
		BYTE "		    (__   _)            |_|_\___\__, |_/__/\__|_| \__,_|\__\___|            (__   _)",10 ,13
		BYTE "		    ( _  __)                    |___/                                       ( _  __)",10 ,13
		BYTE "		    (__   _)                                                                (__   _)",10 ,13
		BYTE "		    (_  ___)                                                                (_  ___)",10 ,13
		BYTE "		    ( _  __)                            Usuario                             ( _  __)",10 ,13
		BYTE "		    (__   _)                       (----------------)                       (__   _)",10 ,13
		BYTE "                    (_  ___)                       |                |                       (_  ___)",10 ,13
		BYTE "		    (__   _)                       (----------------)                       (__   _)",10 ,13
		BYTE "		    ( _  __)                                                                ( _  __)",10 ,13
		BYTE "		    (__   _)                                                                (__   _)",10 ,13
		BYTE "		    (_  ___)                           Contrasena                           (_  ___)",10 ,13
		BYTE "		    (__   _)                       (----------------)                       (__   _)",10 ,13
		BYTE "		    ( _  __)                       |                |                       ( _  __)",10 ,13
		BYTE "		    (__   _)                       (----------------)                       (_    _)",10 ,13
		BYTE "		    (__   _)                                                                (__   _)",10 ,13
		BYTE "		    (_  ___) ______  ______  ______  ______  ______  ______  ______  ______ (_  ___)",10 ,13
		BYTE "		    (__  _ )(__  _ )(__   _)(_   __)( _  __)(_   __)(__   _)(__   _)(_   __)( _  __)",10 ,13
		BYTE "		    (__)(______)(______)(______)(______)(______)(______)(______)(______)(______)(__)",10 ,13, 0

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

	; Aux
	saltoLinea byte 13, 10, 0 ; \r\n


.code
main proc
	
	call Clrscr
	mGotoxy 0,0

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
	je signup
    cmp al, "2"
	je login
	cmp al, "3"
	je newGame
	cmp al, "4"
	je loadGame
	jmp main

	no_sesion:
		call clrscr
		mWrite "Debes iniciar sesion para crear una nueva partida o para unirte a una..."
		mov eax, 2000
		call delay
		jmp main

	newGame:
		call Clrscr

		movzx eax, playerId
		cmp eax, 0
		je no_sesion

		; Al ser el jugador que creo la partida sera el jugador 0
		mov turn, 0
	
		call getMSeconds	; Generar un id
		cmp eax, 10000000	; A veces genera un id de 7 digitos
		jge saveId 
		add eax, 10000000

		saveId:
		mov gameId, eax		; Guardarlo

		; Subirlo a la base de datos
		lea ebx, create_i
		call UploadGameId

		mWrite "El id de la nueva partida es: "
		mov eax, gameId
		call writeInt
		call Crlf
		mWrite "Compartelo con el otro jugador para que pueda unirse"

		call Crlf
		mWrite "Presiona <Enter> para entrar a la partida o <Esc> para volver a la pantalla inicial"
		call readChar
		cmp al, 13
		je wait_for_confirm
		cmp al, 27
		je main

		wait_for_confirm:
			mov eax, 2000
			call delay
			call ReadDataFile
			mov al, buffer
			cmp al, "1"
		jne wait_for_confirm

		call clearBuffer
		lea edx, playing_i
		call setInstruction

		mov eax, gameId
		mov edx, offset buffer[9]
		call parseIntToString

		mov buffer[17], ","

		movzx eax, playerId
		mov edx, offset buffer[18]
		call parseIntToString

		mov buffer[20], 13
		mov buffer[21], 10

		call writeFileHeader

		jmp start_game

	loadGame:
		call Clrscr

		cmp playerId, 0
		je no_sesion

		call clearBuffer
		movzx eax, playerId
		mov edx, offset buffer
		call parseIntToString

		mov ecx, 7
		call shiftRight

		lea edx, games_i
		call setInstruction

		call writeFileHeader

		mWrite "Partidas a las que perteneces con el id: "
		movzx eax, playerId
		call writeInt

		wait_games_in_file:
			mov eax, 1500
			call delay
			call readDataFile
			cmp buffer, "1"
		jne wait_games_in_file

		mov edx, offset buffer[1] ; Saltarse el 1
		call writeString
		call crlf
		mWrite "Id de la partida: "
		call readInt
		mov gameId, eax

		; Cargarlo en el archivo

		call clearBuffer

		lea ebx, join_i
		call UploadGameId

		wait_response:
			mov eax, 1500
			call delay

			call readDataFile
			cmp buffer, "0"
			je get_turn
			cmp buffer, "1"
			je get_turn
		jmp wait_response

		get_turn:
		call readDataFile
		mov al, buffer
		sub al, 30h
		mov turn, al

		mov ecx, 3
		call shiftLeft
		mov ecx, 9
		call shiftRight

		mov edx, offset playing_i
		call setInstruction
		call processOldMoves
		call writeFileHeader

		jmp start_game

	signup:
		call Clrscr

		_req:
		mGotoxy 0, 0
		mov edx, offset sus
		call writestring

		call clearBuffer
		lea edx, signup_i
		call setInstruction

		; Leer usuario
		mGotoxy 52, 14
		mReadString auxBuffer
		mov esi, offset auxBuffer
		mov edi, offset buffer
		call writeToEndOfBuffer

		mov esi, offset saltoLinea
		mov edi, offset buffer
		call writeToEndOfBuffer

		; Leer Contraseña
		mGotoxy 52, 20
		mReadString auxBuffer
		mov esi, offset auxBuffer
		mov edi, offset buffer
		call writeToEndOfBuffer

		; Añadir al archivo
		call writeFileHeader
		jmp wait_for_login

		wait_new_id:
			mov eax, 1500
			call delay

			call readDataFile

			mov ecx, 3
			mov edi, 0
			compare_3_digits:

				cmp buffer[edi], "0"
				jl wait_new_id
				cmp buffer[edi], "9"
				jg wait_new_id
				inc edi
			loop compare_3_digits


		jmp wait_response

	login:
		call Clrscr

		_request:
		mGotoxy 0, 0
		mov edx, offset sis
		call writestring

		call clearBuffer
		lea edx, login_i
		call setInstruction

		; Leer usuario
		mGotoxy 52, 14
		mReadString auxBuffer
		mov esi, offset auxBuffer
		mov edi, offset buffer
		call writeToEndOfBuffer

		mov esi, offset saltoLinea
		mov edi, offset buffer
		call writeToEndOfBuffer

		; Leer Contraseña
		mGotoxy 52, 20
		mReadString auxBuffer
		mov esi, offset auxBuffer
		mov edi, offset buffer
		call writeToEndOfBuffer

		; Añadir al archivo
		call writeFileHeader
		jmp wait_for_login

		invalid_credentials:
		call clrscr
		mGotoxy 40, 27
		mWrite "Credenciales invalidas. Intentelo Nuevamente..."
		jmp _request

		wait_for_login:
			mov eax, 900
			call delay

			call readDataFile
			cmp buffer, "0"
			je invalid_credentials
			jl wait_for_login

			cmp buffer, "9"
			jl _ok
		jmp wait_for_login

		_ok:
		mov esi, offset buffer
		call savePlayerId
		jmp main

	start_game:
		call clrscr
		call printInitialBoard
		call printSidebar
		call getLastMove
		cmp dl, turn
		je waitForOpponent
		jne menu
		mGotoxy 0,25

exit
main endp









; Procedures

; 
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
	cmp dl, turn
	je waiting

	; Mover ya en la matriz y mostrar el movimiento
	call movePieceInBuffer

	call printInitialBoard
	mov eax, 60
	call clearColumn
	call menu

waitForOpponent endp

movePieceInBuffer proc
	; Args:
	; - ax: Desde (coordenada)
	; - bx: Hacia (coordenada)

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

movePieceInBuffer endp

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

readDataFile proc
	call clearBuffer
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
	ret
readDataFile endp

writeFileHeader proc

	lea edx, fileName
	call CreateOutputFile
	mov fileHandle, eax
	jc fileError

	mov edi, offset buffer
	mov ecx, 0
	_loop:
		mov al, [edi]
		cmp al, 0
		je write
		inc ecx
		inc edi
	jmp _loop

	write:
	mov eax, fileHandle
	lea edx, buffer
	call WriteToFile
	mov eax, fileHandle
	call CloseFile

	ret

	fileError:
	exit
writeFileHeader endp

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
		mov al, turn
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
	add ecx, 9
	call WriteToFile
	mov eax, fileHandle
	call CloseFile

	fileError:
	ret
writeDataFile endp

clearDataFile proc

	mov edx, OFFSET fileName
    call OpenInputFile
	mov fileHandle, eax
    jc fileError                ; Si hay un error, salta a la etiqueta fileError

	mov eax, fileHandle
	lea edx, buffer
	add ecx, 0
	call WriteToFile
	mov eax, fileHandle
	call CloseFile

	ret

	fileError:
	exit

clearDataFile endp

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
		cmp ecx, 24
		jl not_found
		cmp BYTE PTR [esi], 0Ah      ; 0Ah es '\n' en ASCII
		je found_end                 ; Si es '\n', encontramos el inicio de la última línea
		dec esi                      ; Retrocede el puntero
	loop find_end_string

	not_found:
		mov dl, 1
		ret

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
	; Args:
	; - ebx: instruccion
	
	push ebx
	mov edx, ebx
	call StrLength
	mov length_i, al

	lea edx, fileName
	call CreateOutputFile
	mov fileHandle, eax
	jc fileError

	mov eax, gameId
	lea edx, buffer
	call parseIntToString

	pop edx
	call setInstruction

	mov edi, offset buffer
	movzx eax, length_i
	add edi, eax
	add edi, 8

	mov byte ptr [edi], ","
	inc edi
	movzx eax, playerId
	mov edx, edi
	call parseIntToString

	movzx eax, length_i
	mov ecx, 11
	add ecx, eax
	mov eax, fileHandle
	lea edx, buffer
	call WriteToFile
	mov eax, fileHandle
	call CloseFile

	fileError:
	ret

uploadGameId endp

setInstruction proc
	; Args:
	; - edx: instuccion

	push edx

	call StrLength
	mov ecx, eax
	push eax
	call shiftRight

	pop ecx
	pop esi
	mov edi, offset buffer

	inserting:
		mov al, [esi]                       ; Cargar carácter de la nueva cadena
        mov [edi], al                       ; Insertar en el buffer
        inc esi                             ; Siguiente carácter en la nueva cadena
        inc edi                             ; Siguiente posición en el buffer
	loop inserting

	ret

setInstruction endp

shiftRight proc
	; Args:
	; ecx: cantidad de espacios

	mov esi, offset buffer					; Inicio
	mov edi, offset auxBuffer

	L1:
        mov al, [esi]                       ; Cargar el carácter actual
        cmp al, 0                           ; ¿Es el fin de la cadena?
        je  EndLoad                         ; Si es 0, terminar
        mov [edi], al                       ; Copiar al buffer
        inc esi                             ; Siguiente carácter
        inc edi                             ; Siguiente posición en buffer
        jmp L1                              ; Repetir el ciclo
    EndLoad:
        mov byte ptr [edi], 0               ; Añadir terminador nulo al final
		cmp ebx, 0
		je salir

	Reverse:
		mov edi, offset buffer
		mov esi, offset auxBuffer
		add edi, ecx
		mov ebx, 0
		jmp L1
		
	salir:
    ret
shiftRight endp

shiftLeft PROC
    ; Args:
    ; ecx: cantidad de espacios a desplazar (número de caracteres a eliminar)
    ;
    ; Desplaza el contenido del buffer hacia la izquierda, eliminando los primeros `ecx` caracteres.

    mov esi, offset buffer           ; ESI apunta al inicio del buffer
    add esi, ecx                     ; ESI ahora apunta al primer carácter después del desplazamiento
    mov edi, offset buffer           ; EDI apunta al inicio del buffer (donde vamos a mover los datos)

L1:
    mov al, [esi]                    ; Cargar carácter actual desde la posición desplazada
    cmp al, 0                        ; ¿Es el final de la cadena?
    je EndShift                      ; Si es el final, salir del bucle
    mov [edi], al                    ; Mover el carácter al nuevo lugar (al frente)
    inc esi                          ; Siguiente carácter en la cadena original
    inc edi                          ; Siguiente posición en el buffer
    jmp L1                           ; Repetir el ciclo

EndShift:
    mov byte ptr [edi], 0            ; Colocar terminador nulo en la nueva posición final

    ret
shiftLeft ENDP

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
		call printSidebar
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
;----trabajando en esta parte 14/09/2024
movePieceProcess proc
	cmp turn,0
	jne movement_init
	INVOKE Str_ucase, ADDR playerPieces

	movement_init:
		mov eax,60
		call clearColumn
		mGotoxy 60,10
		cmp turn,0
		jne message_white_pieces_lower_case
		mwrite "Juegas con las fichas de arriba (Mayusculas)"
		jmp continue_movement_input
		message_white_pieces_lower_case:
		mwrite "Juegas con las fichas de abajo (Minusculas)"
		continue_movement_input:
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
	    cmp turn, 0
		jne check_white_turn
		; Turno de negro
		; Asegurarse de que la pieza seleccionada sea mayúscula
		mov ah, fromCell[0]
		mov al, fromCell[1]
		sub al, 30h
		call calcCellIndex
		movzx edx, selectedCellIndex
		mov al, chessBoard[edx]
		cmp al, '*'
		je emptyCell
		; Verificar si la pieza es mayúscula (negra)
		call isUpperCase
		cmp al, 1
		jne invalidMoveOwnership
		jmp proceed_validation

	check_white_turn:
		; Turno de blanco
		; Asegurarse de que la pieza seleccionada sea minúscula
		mov ah, fromCell[0]
		mov al, fromCell[1]
		sub al, 30h
		call calcCellIndex
		movzx edx, selectedCellIndex
		mov al, chessBoard[edx]
		cmp al, '*'
		je emptyCell
		; Verificar si la pieza es minúscula (blanca)
		call isLowerCase
		cmp al, 1
		jne invalidMoveOwnership

	proceed_validation:
    ; Continuar con la validación de fichas
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
		;cmp al, playerPieces[1]; Pregunta si la pieza seleccionada es igual a una torre
		;je callRookValidation
		;cmp al, playerPieces[2]; Pregunta si la pieza seleccionada es igual a un caballo
		;je callKnightValidation
		cmp al, playerPieces[3]; Pregunta si la pieza seleccionada es igual a un alfil
		je callBishopValidation
		; Falta agregar validaciones de otras piezas (torres, caballos, etc.)
		jmp continueMove

		callPawnValidation:
			; Configurar parámetros para validar el movimiento del peón
			call validatePawnMove ; Llamada al procedimiento de validación
			cmp al, 0             ; Validación fallida?
			je invalidMove        ; Si no es válido, regresar a entrada de movimiento
			jmp continueMove
		callRookValidation:
			; Configurar parámetros para validar el movimiento de la torre
			;call validateRookMove ; Llamada al procedimiento de validación
			cmp al, 0             ; Validación fallida?
			je invalidMove        ; Si no es válido, regresar a entrada de movimiento
			jmp continueMove
		callKnightValidation:
		; Configurar parámetros para validar el movimiento del caballo
			;call validateKnightMove ; Llamada al procedimiento de validación
			cmp al, 0             ; Validación fallida?
			je invalidMove        ; Si no es válido, regresar a entrada de movimiento
			jmp continueMove
		callBishopValidation:
			; Configurar parámetros para validar el movimiento del alfil
			call validateBishopMove ; Llamada al procedimiento de validación
			cmp al, 0             ; Validación fallida?
			je invalidMove        ; Si no es válido, regresar a entrada de movimiento
			jmp continueMove
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
			mov ah, fromCell[0]
			mov al, fromCell[1]
			sub al, 30h
			call calcCellIndex
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
		call printSidebar
		call printBoard

		call waitForOpponent

		invalidMoveOwnership:
			mGotoxy 60,6
			mWrite "No puedes mover una pieza del oponente"
			mGotoxy 60,7
			call WaitMsg
			jmp movement_init


	ret
movePieceProcess endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;VALIDACION DEL ALFIL;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
validateBishopMove proc
    xor eax, eax            ; Limpiar el registro eax

    ; Obtener la diferencia de las filas y las columnas
    mov al, fromCell[1]      ; Fila de la casilla de origen
    sub al, toCell[1]        ; Restar la fila de destino
    call absolute            ; Obtener el valor absoluto de la diferencia de las filas
    mov bl, al               ; Guardar la diferencia de las filas en bl

    mov al, fromCell[0]      ; Columna de la casilla de origen
    sub al, toCell[0]        ; Restar la columna de destino
    call absolute            ; Obtener el valor absoluto de la diferencia de las columnas
    cmp bl, al               ; Comparar la diferencia de filas y columnas
    jne invalidMoveBishop    ; Si no son iguales, no es un movimiento diagonal válido

    ; Si es un movimiento diagonal, verificar si el camino está libre
    call checkBishopPath     ; Verificar que no haya obstrucciones en el camino
    cmp al, 0                ; Si hay obstrucciones
    je invalidMoveBishop     ; Movimiento inválido si hay obstrucciones

    ; Verificar si es una captura válida
    mov ah, toCell[0]
    mov al, toCell[1]
    sub al, 30h
    call calcCellIndex       ; Obtener el índice de la casilla de destino
    movzx edi, selectedCellIndex
    mov al, chessBoard[edi]  ; Obtener el contenido de la casilla de destino

    cmp al, '*'              ; Si la casilla de destino está vacía, es un movimiento válido
    je validMoveBishop
    ; Verificar si es una pieza enemiga para capturar
    cmp turn, 0              ; Si es el turno de las negras
    je checkCaptureWhitePiece
    jmp checkCaptureBlackPiece

checkCaptureWhitePiece:
    cmp al, 'a'              ; Verificar si la pieza es minúscula (blanca)
    jb invalidMoveBishop
    cmp al, 'z'
    ja invalidMoveBishop
    jmp validMoveBishop      ; Si es una pieza blanca, es una captura válida

checkCaptureBlackPiece:
    cmp al, 'A'              ; Verificar si la pieza es mayúscula (negra)
    jb invalidMoveBishop
    cmp al, 'Z'
    ja invalidMoveBishop
    jmp validMoveBishop      ; Si es una pieza negra, es una captura válida

invalidMoveBishop:
    mov al, 0                ; Movimiento inválido
    ret

validMoveBishop:
    mov al, 1                ; Movimiento válido
    ret

validateBishopMove endp

checkBishopPath proc
    ; Inicializar las posiciones de origen y destino
    mov al, fromCell[1]      ; Fila de la casilla de origen
    mov ah, fromCell[0]      ; Columna de la casilla de origen
    mov bl, toCell[1]        ; Fila de la casilla de destino
    mov bh, toCell[0]        ; Columna de la casilla de destino

    ; Determinar la dirección del movimiento (filas y columnas)
    mov dl, bl               ; Diferencia de las filas
    sub dl, al               ; dl = fila destino - fila origen

    mov dh, bh               ; Diferencia de las columnas
    sub dh, ah               ; dh = columna destino - columna origen

    ; Identificar la dirección del movimiento y normalizar los incrementos
    ; DL: Diferencia en las filas, DH: Diferencia en las columnas
    cmp dl, 0
    jl movingUp              ; Si dl < 0, el alfil se mueve hacia arriba
    cmp dh, 0
    jl movingLeft            ; Si dh < 0, el alfil se mueve hacia la izquierda
    jmp moveDiagonalDownRight ; Si ambos dl > 0 y dh > 0, diagonal hacia abajo y a la derecha

movingUp:
    neg dl                   ; Convertir la diferencia de filas en positiva
    cmp dh, 0
    jl moveDiagonalUpLeft     ; Si dh < 0, diagonal hacia arriba y a la izquierda
    jmp moveDiagonalUpRight   ; Si dh > 0, diagonal hacia arriba y a la derecha

movingLeft:
    neg dh                   ; Convertir la diferencia de columnas en positiva
    jmp moveDiagonalDownLeft  ; Diagonal hacia abajo y a la izquierda

; Movimiento diagonal hacia abajo y a la derecha
moveDiagonalDownRight:
    ; Iterar a través de las casillas entre origen y destino
    movzx cx, dl               ; Número de pasos a recorrer (igual en filas y columnas)
checkPathLoopDownRight:
    dec cx
    jz checkPathEnd          ; Si hemos llegado al destino, terminar

    inc al                   ; Avanzar una fila hacia abajo
    inc ah                   ; Avanzar una columna hacia la derecha

    ; Obtener el contenido de la casilla intermedia
    push ax
	sub al,30h
    call calcCellIndex
    movzx edi, selectedCellIndex
    mov bl, chessBoard[edi]  ; Obtener el contenido de la casilla
    pop ax

    cmp bl, '*'              ; Si la casilla no está vacía, hay una obstrucción
    jne obstructionFound

    jmp checkPathLoopDownRight

; Movimiento diagonal hacia abajo y a la izquierda
moveDiagonalDownLeft:
    movzx cx, dl
checkPathLoopDownLeft:
    dec cx
    jz checkPathEnd

    inc al                   ; Avanzar una fila hacia abajo
    dec ah                   ; Avanzar una columna hacia la izquierda

    ; Obtener el contenido de la casilla intermedia
    push ax
	sub al,30h
    call calcCellIndex
    movzx edi, selectedCellIndex
    mov bl, chessBoard[edi]
    pop ax

    cmp bl, '*'              ; Si la casilla no está vacía, hay una obstrucción
    jne obstructionFound

    jmp checkPathLoopDownLeft

; Movimiento diagonal hacia arriba y a la derecha
moveDiagonalUpRight:
    movzx cx, dl
checkPathLoopUpRight:
    dec cx
    jz checkPathEnd

    dec al                   ; Avanzar una fila hacia arriba
    inc ah                   ; Avanzar una columna hacia la derecha

    ; Obtener el contenido de la casilla intermedia
    push ax
	sub al,30h
    call calcCellIndex
    movzx edi, selectedCellIndex
    mov bl, chessBoard[edi]
    pop ax

    cmp bl, '*'              ; Si la casilla no está vacía, hay una obstrucción
    jne obstructionFound

    jmp checkPathLoopUpRight

; Movimiento diagonal hacia arriba y a la izquierda
moveDiagonalUpLeft:
    movzx cx, dl
checkPathLoopUpLeft:
    dec cx
    jz checkPathEnd

    dec al                   ; Avanzar una fila hacia arriba
    dec ah                   ; Avanzar una columna hacia la izquierda

    ; Obtener el contenido de la casilla intermedia
    push ax
	sub al,30h
    call calcCellIndex
    movzx edi, selectedCellIndex
    mov bl, chessBoard[edi]
    pop ax

    cmp bl, '*'              ; Si la casilla no está vacía, hay una obstrucción
    jne obstructionFound

    jmp checkPathLoopUpLeft

obstructionFound:
    mov al, 0                ; Camino bloqueado
    ret

checkPathEnd:
    mov al, 1                ; Camino libre
    ret

checkBishopPath endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;FIN VALIDACION DEL ALFIL;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

validatePawnMove proc
	cmp turn, 0			;SI el player id es 0, entonces este juega con las piezas negras(en mayúscula)
	je validate_black_pawn
	jmp validate_white_pawn
	ret

	validate_black_pawn:
		xor eax,eax
		; Peón negro: fila debe aumentar en 1 o 2 (primer movimiento)
		mov al, fromCell[1]
		sub al, toCell[1]    ; Comparar filas
		call absolute
		cmp al, 1			 ; Si el desplazamiento es 1, validar captura o movimiento normal
		je checkBlackCapture ; Verificar si hay captura
		cmp al, 2			 ; En caso de que se desplace 2 filas...
		je checkBlackFirstMove	 ; Verificar que sea el primer movimiento
		jmp invalidMovePawn	 ; Si no es niguno de los casos anteriores, el movimiento es invalido ;Revisado*(quitar esto)

	checkBlackCapture:
		; Movimiento diagonal para captura
		mov al, fromCell[0]
		sub al, toCell[0]    ; Comparar columnas (debe ser una casilla en diagonal) B->C or A<-B la distancia debe de ser 1
		call absolute
		cmp al, 1
		jne checkBlackForwardMove  ; Si no es diagonal, verificar movimiento normal

		; Verificar si hay una pieza enemiga para capturar
		mov ah, toCell[0]
		mov al, toCell[1]
		sub al,30h
		call calcCellIndex
		movzx edi,selectedCellIndex
		mov al, chessBoard[edi]
		cmp al, '*'        ; La casilla no puede estar vacía para una captura
		je invalidMovePawn
		cmp al, 'a'        ; Verificar que sea una pieza blanca (minúscula)
		jb invalidMovePawn
		cmp al, 'z'
		ja invalidMovePawn 

		; Captura válida
		mov al, 1
		jmp endPawnValidation 

	checkBlackForwardMove:
		; Verificar movimiento hacia adelante (columna igual)
		mov al, fromCell[0]
		cmp al, toCell[0]
		jne invalidMovePawn

		; Verificar que la casilla de destino esté vacía
		mov ah, toCell[0]
		mov al, toCell[1]
		sub al,30h
		call calcCellIndex
		movzx edi,selectedCellIndex
		mov al, chessBoard[edi]
		cmp al, '*'
		jne invalidMovePawn

		; Movimiento válido hacia adelante
		mov al, 1
		jmp endPawnValidation													;Revisado*(quitar esto)----------------------------------

	checkBlackFirstMove:
		; Primer movimiento: debe estar en fila 2
		mov al, fromCell[1]
		cmp al, '2'
		jne invalidMovePawn

		; Verificar que las dos casillas estén vacías
		mov ah, toCell[0]
		mov al, toCell[1]
		sub al,30h
		call calcCellIndex
		movzx edi,selectedCellIndex
		mov al, chessBoard[edi]
		cmp al, '*'
		jne invalidMovePawn

		; Verificar movimiento hacia adelante (columna igual)
		mov al, fromCell[0]
		cmp al, toCell[0]
		jne invalidMovePawn

		; Casilla intermedia también debe estar vacía
		mov ah, fromCell[0]
		mov al, fromCell[1]
		sub al,30h
		call calcCellIndex
		movzx edi,selectedCellIndex
		add edi, 8h
		mov al, chessBoard[edi]
		cmp al, '*'
		jne invalidMovePawn

		; Movimiento válido de dos casillas
		mov al, 1
		jmp endPawnValidation

	validate_white_pawn:
    xor eax, eax

    ; Peón blanco: fila debe disminuir en 1 o 2 (primer movimiento)
    mov al, toCell[1]
    sub al, fromCell[1]    ; Comparar filas (destino - origen)
    call absolute
    cmp al, 1			 ; Si el desplazamiento es 1, validar captura o movimiento normal
    je check_white_capture ; Verificar si hay captura
    cmp al, 2			 ; En caso de que se desplace 2 filas...
    je check_white_first_move	 ; Verificar que sea el primer movimiento
    jmp invalidMovePawn		 ; Movimiento inválido

check_white_capture:
    ; Movimiento diagonal para captura
    mov al, fromCell[0]
    sub al, toCell[0]    ; Comparar columnas (debe ser una casilla en diagonal)
    call absolute
    cmp al, 1
    jne check_white_forward_move  ; Si no es diagonal, verificar movimiento normal

    ; Verificar si hay una pieza enemiga para capturar
    mov ah, toCell[0]
    mov al, toCell[1]
    sub al,30h
    call calcCellIndex
    movzx edi,selectedCellIndex
    mov al, chessBoard[edi]
    cmp al, '*'        ; La casilla no puede estar vacía para una captura
    je invalidMovePawn
    cmp al, 'A'        ; Verificar que sea una pieza negra (mayúscula)
    jb invalidMovePawn
    cmp al, 'Z'
    ja invalidMovePawn 

    ; Captura válida
    mov al, 1
    jmp endPawnValidation

check_white_forward_move:
    ; Verificar movimiento hacia adelante (columna igual)
    mov al, fromCell[0]
    cmp al, toCell[0]
    jne invalidMovePawn

    ; Verificar que la casilla de destino esté vacía
    mov ah, toCell[0]
    mov al, toCell[1]
    sub al,30h
    call calcCellIndex
    movzx edi,selectedCellIndex
    mov al, chessBoard[edi]
    cmp al, '*'
    jne invalidMovePawn

    ; Movimiento válido hacia adelante
    mov al, 1
    jmp endPawnValidation

	check_white_first_move:
		; Primer movimiento: debe estar en fila 7 (A7 a H7 para peones blancos)
		mov al, fromCell[1]
		cmp al, '7'			; Peones blancos están en fila 7
		jne invalidMovePawn

		; Verificar que las dos casillas estén vacías
		mov ah, toCell[0]
		mov al, toCell[1]
		sub al,30h
		call calcCellIndex
		movzx edi,selectedCellIndex
		mov al, chessBoard[edi]
		cmp al, '*'
		jne invalidMovePawn

		; Verificar movimiento hacia adelante (columna igual)
		mov al, fromCell[0]
		cmp al, toCell[0]
		jne invalidMovePawn

		; Casilla intermedia también debe estar vacía
		mov ah, fromCell[0]
		mov al, fromCell[1]
		sub al,30h
		call calcCellIndex
		movzx edi,selectedCellIndex
		sub edi, 8h			; Una fila atrás para peones blancos
		mov al, chessBoard[edi]
		cmp al, '*'
		jne invalidMovePawn

		; Movimiento válido de dos casillas
		mov al, 1
		jmp endPawnValidation

	invalidMovePawn:
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

; Función para verificar si un carácter es mayúscula
; Retorna AL = 1 si es mayúscula, AL = 0 si no lo es
isUpperCase proc
    cmp al, 'A'
    jb not_upper
    cmp al, 'Z'
    ja not_upper
    mov al, 1
    ret
	not_upper:
		mov al, 0
		ret
isUpperCase endp

; Función para verificar si un carácter es minúscula
; Retorna AL = 1 si es minúscula, AL = 0 si no lo es
isLowerCase proc
    cmp al, 'a'
    jb not_lower
    cmp al, 'z'
    ja not_lower
    mov al, 1
    ret
	not_lower:
		mov al, 0
    ret
isLowerCase endp

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

processOldMoves proc

	mov edi, offset buffer
	add edi, 24

	_loop:
		cmp byte ptr [edi], 0
		je finish
		mov ah, [edi]
		mov al, [edi+1]
		mov bh, [edi+3]
		mov bl, [edi+4]
		sub al, 30h
		sub bl, 30h
		call movePieceInBuffer
		add edi, 9
		cmp byte ptr [edi], 0
	jne _loop

	finish:
	ret
processOldMoves endp

clearBuffer proc

	mov esi, offset buffer

	mov ecx, lengthof buffer
	_loop:
		mov byte ptr [esi], 0
		inc esi
	loop _loop

	ret

clearBuffer endp

writeToEndOfBuffer proc
	; Args:
	; esi: Apunta a la cadena que se va a añadir (newString)
	; edi: Apunta al buffer donde se añadirá la cadena (buffer)
    
	; Encuentra el final del buffer (donde está el terminador nulo)
	FindEnd:
		mov al, [edi]                    ; Cargar carácter actual del buffer
		cmp al, 0                        ; ¿Es el terminador nulo?
		je StartAppend                   ; Si es 0, hemos llegado al final, saltar para agregar la nueva cadena
		inc edi                          ; Continuar avanzando en el buffer
		jmp FindEnd                      ; Repetir hasta encontrar el final

	StartAppend:
		; mov esi, offset newString        ; ESI apunta a la cadena que vamos a añadir

	AppendLoop:
		mov al, [esi]                    ; Cargar carácter de la nueva cadena
		cmp al, 0                        ; ¿Es el final de la nueva cadena?
		je FinishAppend                  ; Si es 0, terminar el proceso
		mov [edi], al                    ; Copiar el carácter al final del buffer
		inc esi                          ; Avanzar al siguiente carácter en la nueva cadena
		inc edi                          ; Avanzar al siguiente espacio en el buffer
		jmp AppendLoop                   ; Repetir el ciclo

	FinishAppend:
		mov byte ptr [edi], 0            ; Colocar terminador nulo al final del buffer

	ret
writeToEndOfBuffer endp

savePlayerId proc
	; Args:
    ; esi: Apunta al buffer que contiene los dígitos (en formato de caracteres ASCII)
    ; Return:
    ; playerId: El número convertido a entero

    mov eax, 0                        ; Limpiar EAX (para acumular el resultado)
    mov ecx, 0                        ; Limpiar ECX (contador de dígitos)
    mov edi, offset playerId           ; EDI apunta a playerId

	ConvertLoop:
		mov al, [esi]                     ; Cargar el carácter actual del buffer
		cmp al, 0                         ; ¿Es el terminador nulo (fin de cadena)?
		je EndConvert                     ; Si es el fin de la cadena, salir del bucle
		cmp al, '0'                       ; Verificar si es un carácter numérico ('0' a '9')
		jl EndConvert                     ; Si es menor que '0', terminar (carácter no numérico)
		cmp al, '9'                       ; Comparar si es mayor que '9'
		jg EndConvert                     ; Si es mayor que '9', terminar (carácter no numérico)

		; Convertir carácter a valor numérico
		sub al, '0'                       ; Restar el valor ASCII de '0' para obtener el valor numérico
		movzx edx, al                     ; Mover el dígito a EDX (evitando signo)

		; Actualizar el valor de playerId
		movzx eax, playerId                 ; Cargar el valor actual de playerId
		imul eax, 10                      ; Multiplicar el valor actual por 10 (para desplazar los dígitos)
		add eax, edx                      ; Sumar el nuevo dígito

		mov playerId, al                 ; Almacenar el resultado en playerId

		inc esi                           ; Avanzar al siguiente carácter en el buffer
		jmp ConvertLoop                   ; Repetir el ciclo para el siguiente carácter

	EndConvert:
		ret
savePlayerId endp

end main
