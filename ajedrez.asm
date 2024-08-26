include irvine32.inc

.data
	; IU Components
	letterCoords db		"     A    B    C    D    E    F    G    H  ", 10, 13,0
	boardRowBlack db    " * * *     * * *     * * *     * * *     ", 10, 13,
						"   * * *     * * *     * * *     * * *     ", 10, 13,
						"   * * *     * * *     * * *     * * *     ", 10, 13, 0

	boardRowWhite db    "      * * *     * * *     * * *     * * *", 10, 13,
						"        * * *     * * *     * * *     * * *", 10, 13,
						"        * * *     * * *     * * *     * * *", 10, 13, 0
	blackCell db "* * *", 10, 13,
				 "* * *", 10, 13,
				 "* * *", 10, 13, 0
	whiteCell db "     ", 10, 13,
				 "     ", 10, 13,
				 "     ", 10, 13, 0
.code
main proc
	
	; Macros de talbero
	printCharacter macro character
		; Args:
		; - character: "p" | "c" | "a" | "t" | "k" | "q"
		; Nota: Fichas del blanco en minuscula, fichas del negro en MAYUSCULA
		mov edl, character
	endm




	lea edx, letterCoords
	call writestring

	mov eax, 1
	call writeint
	lea edx, boardRowBlack
	call writestring

	mov eax, 2
	call writeint
	lea edx, boardRowWhite
	call writestring

	mov eax, 3
	call writeint
	lea edx, boardRowBlack
	call writestring

	mov eax, 4
	call writeint
	lea edx, boardRowWhite
	call writestring

	mov eax, 5
	call writeint
	lea edx, boardRowBlack
	call writestring

	mov eax, 6
	call writeint
	lea edx, boardRowWhite
	call writestring

	mov eax, 7
	call writeint
	lea edx, boardRowBlack
	call writestring

	mov eax, 8
	call writeint
	lea edx, boardRowWhite
	call writestring


		
main endp

end main