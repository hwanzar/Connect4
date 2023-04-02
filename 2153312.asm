.data
#42 elements form a 6x7 array
aBoard: .word -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 0, -1, -1, -1, -1, -1, -1, 1, -1, -1, -1

piece: .word -1			#-1 for empty, 1 for 'X', 0 for 'O'
latestColumn: .word -1	# stores latest column
latestId: .word -1		# stores the most recent inserted index of the array
turnCnt: .word -1		# Number of turn passed, game ends with a draw when 42 turns have passed
undoCnt: .word 3, 3		# Number of undos
violateCnt: .word 3, 3		# Number of violates each player can makes
removeCnt: .word 1,1
countPiece: .word 0
whichP:	.word 0			# Indicates which player's turn it is to access data array

checkFull: .word 1

blockCnt: .word 1, 1
CheckWinChance: .word 0, 0

typePlayer1: .word 1
typePlayer2: .word 0 

deleteCol: .word -1
deleteRow: .word -1

empty: .asciiz " - "
isO: .asciiz " O "
isX: .asciiz " X "
endline: .asciiz "\n"
printBoard_lb: .asciiz "\n   "
boardTop: .asciiz "\n =======Board=======\n 1  2  3  4  5  6  7\n"
bottomBoard: .asciiz " ===================\n"
curpiece: .word -1

nameOne: .space 20 # name of player 1
nameTwo: .space 20 # name of player 2
ask1: .asciiz "First player's name: "
ask2: .asciiz "Second player's name: "

PrintStartGame: .asciiz "\n============================[Welcome]==============================\nThis is a turn-based 2-player game.\nThe rule is:\n+ Each player put their designated piece into a 6 x 7 Board\n+ The game ends when either one of the player makes 4 consecutive\npieces in any direction, or the board is completely filled.\n+ Each player has 3 times to undo the move, 3 times to make mistakes\n+ Each player also has 1 time to block and remove the opponent moves\n\n              o(*^-^*)o GOOD LUCK HAVE FUN o(*^-^*)o		        \n===================================================================\n\n==========================[Game Started]===========================\n"
PrintPlayerChooseRandom: .asciiz " [[RANDOM PICK]] 1st player's piece will be -->"
PrintInvalidFirstInput: .asciiz "\n[[ALERT]]Invalid input! Please choose again:\nX - Input '1'\nO - Input '0' \n"

PrintMoveOption: .asciiz "===========================[Move Option]===========================\n1. Move\n2. Remove Opponent\n===================================================================\n"
PrintSelectRmCol: .asciiz "\nSelect column you want to remove: "
PrintSelectRmRow: .asciiz "Select row you want to remove: "
invalidColRow: .asciiz "\nIt's not opponent move, please choose again\n"
stats_top: .asciiz "\n===========================[Game Status]===========================\n"
stats_bot: .asciiz "||\n===================================================================\n\n"
stats_body1: .asciiz "|| Turn: "
stats_body2: .asciiz "|| Player's name: "
stats_pieceInfo: .asciiz " | Piece: "
stats_body3: .asciiz "| Violation count: "
stats_body4: .asciiz " | Undo count: "

dropPiece_PrintX: .asciiz "\nPlayer choosing 'X', please choose a column (1-7) to place your piece: "
dropPiece_PrintO: .asciiz "\nPlayer choosing 'O', please choose a column (1-7) to place your piece: "
dropPiece_invalidInput1: .asciiz "\n=================================[ALERT]=================================\nYou chose an invalid column, you have "
dropPiece_invalidInput2: .asciiz " tries left before losing by rule.\n=========================================================================\nPlease try again: "
dropPiece_PrintForceLose: .asciiz "You violated the rule 3 times, hence you lose.\n"
dropPiece_PrintColFull: .asciiz "The chosen column is full! Please try again: "
PrintDropResult1: .asciiz "\nDropped successfully to column #"
PrintDropResult2: .asciiz ", The current board is:\n"

undo_Print1: .asciiz "\n===========================[Undo Option]===========================\nWould you like to undo your move? You have "
undo_Print2: .asciiz " tries left.\n===================================================================\nAccept Undo? (y/n)"
block_Print: .asciiz "\n===========================[Block Choice]===========================\nYou have only one time to block opponent turn (click 1 for BLOCK, 2 to continue)\n"

undo_invalidInput: .asciiz "Invalid input! Please try again: "

endGame_printWin: .asciiz "\n===========================[Game Over]============================\nCONGRATULATIONS! The winner is "
endGame_info1: .asciiz "- Number of Pieces: " 
endGame_Terminate: .asciiz "\n===================================================================\n"
endGame_PrintDraw: .asciiz "\n===========================[Game Over]============================\n   TIE GAME!! GGWP\n===================================================================\n"	

endTurn: .asciiz "\n===========================[Turn Ended]============================\n"


.text
main:
	start: # First initialize
        #Intro to game
		li $v0, 4
		la $a0, PrintStartGame
		syscall
		
		# read player 1 name
		li $v0, 4
		la $a0, ask1
		syscall
		li $v0, 8	
		li $a1, 256
		la $a0, nameOne
		syscall
		move $t8, $a0

		#read player 2 name
		li $v0, 4
		la $a0, ask2
		syscall
		li $v0, 8
		li $a1, 256
		la $a0, nameTwo
		syscall
		move $t9, $a0

		
		li $a1, 2  #0 <= a0 < 2
		li $v0, 42  #generates the random number.
		syscall
		sw $a0, piece # store piece as random number 0 or 1
		# this is the first moves of each player:	
		beq $a0, 0, changeIndex
		j cont
		changeIndex:
			li $t0, 0
			li $t1, 152
			li $t2, 124
			sw $t0, aBoard($t1)
			li $t0, 1
			sw $t0, aBoard($t2)
		cont:
		li $v0, 4
		la $a0, PrintPlayerChooseRandom
		syscall
		
		lw $a0, piece
		beq $a0, 0, printCharO
        # else printCharX
		la $a0, isX
		li $v0, 4
		syscall
		lw $a0, piece
		j MidGame
		
		printCharO:
			la $a0, isO
			li $v0, 4
			syscall
			lw $a0, piece
			j MidGame
	
	li $v0, 10
	syscall
	
MidGame:
	# Initialize:
	li $v0, 4
	la $a0, endline
	syscall
	li $s0, 0		# game ends if $s0 = 1;
	li $s2, 1		# count turns, end game when it reaches 42
	sw $s2, turnCnt		# store to data
	jal printBoard
	MidGame_loop:
		#lw $s1, turnCnt
		#beq $s1, 43, endGame	# Ends game if 42 turns have passed
		li $t0, 0
		li $s1, 1
		sw $s1, checkFull
		jal fullBoardCheck
		lw $s1, checkFull
		beq $s1, 1, endGame #end game if Board is full DRAW
	
	jumpBackTurn:
		jal printStats	# Stats: name, turn count, violate, undo counts...
		jal removeOption	# remove or move, one time only

		jal dropPiece		# dropping the X or O 
		jal DropResult	# Prints where did the player put their piece
	
		jal printBoard		# After insert, prints result for the player
	
		jal checkBoard		# Check whether the player wins the game or not
		
		jal undo			# Ask whether the players want to undo their move and acts accordingly
		
		lw $s1, piece
		xor $s1, $s1, 1		# Toggle piece
		sw $s1, piece
		
		lw $s1, whichP		# 
		xor $s1, $s1, 1
		sw $s1, whichP
		
		
		lw $s1, turnCnt
		addi $s1, $s1, 1		# Increase turn count
		sw $s1, turnCnt

		jal block #block opponent. 1 time.
		
		li $v0, 4		# Announce the end of turn
		la $a0, endTurn
		syscall

		j MidGame_loop		# Jumps back to the beginning of a turn
		
printStats:
	# Prints the current status of the game onto the output.
	li $v0, 4
	la $a0, stats_top
	syscall
	
	li $v0, 4
	la $a0, stats_body2
	syscall
	
	lw $a0, whichP			# Prints current player
	#addi $a0, $a0, 1
	beq $a0, 1, outName2
	la $a0, ($t8)
	syscall
	j endStatus
	outName2:
	la $a0, ($t9)
	syscall
	
	endStatus:
	la $a0, stats_body1
	syscall
	
	lw $a0, turnCnt			# Prints turn count
	li $v0, 1
	syscall
	li $v0, 4
	la $a0, stats_pieceInfo
	syscall
	
	lw $a0, piece			# Prints player's piece
	beq $a0, 1, stats_pieceX
	la $a0, isO
	j stats_gotpiece
	stats_pieceX:
	la $a0, isX
	stats_gotpiece:
	syscall
	
	la $a0, stats_body3
	syscall
	
	lw $t0, whichP
	mul $t0, $t0, 4
	lw $t1, violateCnt($t0)		# Prints violate counts left
	lw $t2, undoCnt($t0)		# Prints undo counts left
	move $a0, $t1
	li $v0, 1
	syscall
	
	li $v0, 4
	la $a0, stats_body4
	syscall
	
	li $v0, 1
	move $a0, $t2
	syscall
	
	la $a0, stats_bot
	li $v0, 4
	syscall
	
	j exit
		
printBoard:
	li $t7, 0		# Iterator (0 : 41)
	la $t6, aBoard		# Address to board
	li $t5, 7		# Var to count to endline (every 7 elements)
	li $v0, 4		# set the syscall beforehand
	la $a0, boardTop
	syscall			# Make board's edge
	loopPB:
		beq $t7, 42, printBoard_exit
		lw $t4, 0($t6)
		
		beq $t4, 1, loopPB_X
		beq $t4, 0, loopPB_O
		
		# Else (prints empty cell)
		la $a0, empty
		syscall
		j loopPB_continue
		
		loopPB_X:			
			la $a0, isX
			syscall
			j loopPB_continue
		
		loopPB_O:		
			la $a0, isO
			syscall
			j loopPB_continue
				
	loopPB_continue:
		addi $t5, $t5, -1
		bne $t5, 0, loopPB_continue_noLB
		
		la $a0, endline
		syscall
		li $t5, 7
		
	loopPB_continue_noLB:
		addi $t7, $t7, 1
		addi $t6, $t6, 4
		j loopPB
	
	printBoard_exit:
		la $a0, bottomBoard
		syscall			# Make board's edge
		j exit			# jr $ra

removeOption:
	lw $s1, whichP #update player turn
	mul $s1, $s1, 4
	lw $t1, removeCnt($s1)

	beq $t1, 0, exit #if no more remove allowed, break this function

	li $v0, 4
	la $a0, PrintMoveOption
	syscall

	li $v0, 12
	syscall
	beq $v0, '1', exit
	beq $v0, '2', selectRemove
	
	#invalid : 3,4....


	selectRemove:
		lw $t1, removeCnt($s1)
		addi $t1, $t1, -1 #now is 0
		sw $t1, removeCnt($s1)

		askColRow:
		li $v0, 4
		la $a0, PrintSelectRmCol
		syscall
		li $v0, 5
		syscall
		sw $v0, deleteCol # t2 is COLUMN
		
		li $v0, 4
		la $a0, PrintSelectRmRow
		syscall
		li $v0, 5
		syscall
		sw $v0, deleteRow #t3 is ROW

		# invalid input?
		removePieceLocation:
			
			# piece need to delete = 28xrow - (8 - col)x4
			
			lw $t2, deleteRow
			mul $t2, $t2, 28 #28xrow
			li $t3, 0
			add $t3, $t3, $t2

			lw $t2, deleteCol
			addi $t7, $t2, -1
			sw $t7, latestColumn
			addi $t2, $t2, -8
			mul $t2, $t2, 4
			add $t3, $t3, $t2 #index = cthuc

			sw $t3, latestId # for checkBoard
			
			lw $s7, aBoard($t3)
			lw $s6, piece
			beq $s7, $s6, askColRow1
			beq $s7, -1, askColRow1

			# column down
			loop_Down:
			addi $t4, $t3, -28
			# t3 = index of remove Piece
		
			lw $t2, aBoard($t4)
			sw $t2, aBoard($t3)
			addi $t3, $t3, -28

			blt $t3, 24, endRemove	
			j loop_Down
		endRemove:
		li $t2, -1
		sw $t2, aBoard($t3)

		jal printBoard
		lw $s1, whichP
		mul $s1, $s1, 4
		li $s5, 1
		sw $s5, blockCnt($s1)
		lw $s1, whichP
		xor $s1, $s1, 1
		mul $s1, $s1, 4
		sw $s5, blockCnt($s1)

		lw $t2 , latestId
		checkWinAllColumn:
			blt $t2, 24, swapTurn
			lw $s1, latestId
			lw $s6, aBoard($s1)
			beq $s6, -1, swapTurn
			jal checkBoard
			lw $t2, latestId
			addi $t2, $t2, -28
			sw $t2, latestId
			j checkWinAllColumn

		swapTurn:
		lw $s1, piece
		xor $s1, $s1, 1		# Toggle piece color (type)
		sw $s1, piece
		
		lw $s1, whichP		# Switch player's index
		xor $s1, $s1, 1
		sw $s1, whichP
		
		
		lw $s1, turnCnt
		addi $s1, $s1, 1		# Increase turn count
		sw $s1, turnCnt

		j jumpBackTurn

		askColRow1:
			li $v0, 4
			la $a0, invalidColRow
			syscall
			j askColRow



dropPiece:
	# Called to make a move onto the board
	lw $s1, whichP
	mul $s1, $s1, 4
	lw $t1, violateCnt($s1)		# Used to track the number of invalid input
	li $v0, 4
	lw $s1, piece
	
	li $v0, 4
	la $a0, dropPiece
	
	beq $s1, 1, dropPiece_isX
	la $a0, dropPiece_PrintO
	syscall
	j dropPiece_checkInput
	
	dropPiece_isX:
	la $a0, dropPiece_PrintX
	syscall
	j dropPiece_checkInput
	
	dropPiece_checkInput:
		li $v0, 5
		syscall
		move $t7, $v0		# $t7 stores the input
		
		blt $t7, 1, dropPiece_invalidInput
		bgt $t7, 7, dropPiece_invalidInput
		# When input is valid, put the piece to the column
		j dropPiece_validInput
		
		dropPiece_invalidInput:
			addi $t1, $t1, -1
			beq $t1, 0, dropPiece_forceLose
			lw $s1, whichP
			mul $s1, $s1, 4
			sw $t1, violateCnt($s1)
		
			li $v0, 4
			la $a0, dropPiece_invalidInput1
			syscall
			
			li $v0, 1
			move $a0, $t1
			syscall
			
			li $v0, 4
			la $a0, dropPiece_invalidInput2
			syscall

			j dropPiece_checkInput
	dropPiece_validInput:
		addi $t7, $t7, -1	# To match with array index (0 - 6)
		sw $t7, latestColumn	# Store to data
		
		# Checking whether the column is full
		mul $t3, $t7, 4
		lw $t5, aBoard($t3)
		sne $t4, $t5, -1		# -1 == empty cell, we only need to check the top row
		beq $t4, 1, dropPiece_invalidInput
		
		# Else, continue
		# Drop the piece to the correct column
		mul $t3, $t7, 4
		addi $t3, $t3, 140 	# Start from the bottom (35 * 4)
		j dropPiece_insert_findSlot
		j endGame
		
	dropPiece_insert_findSlot:	# Find empty location in column
		lw $t5, aBoard($t3)
		beq $t5, -1, dropPiece_insert_foundSlot
		addi $t3, $t3, -28
		j dropPiece_insert_findSlot
		
	dropPiece_insert_foundSlot:	# Update data at the location
		# $t3 storing the index (*4)
		sw $t3, latestId	# Store to data for later use
		lw $s1, piece
		sw $s1, aBoard($t3)
		j exit
		
	dropPiece_forceLose:
		li $v0, 4
		la $a0, dropPiece_PrintForceLose
		syscall
		
		lw $s1, piece
		xor $s1, $s1, 1		# Toggle piece to the winner player
		sw $s1, piece

		lw $s1, whichP		# Switch player's index
		xor $s1, $s1, 1
		sw $s1, whichP
		j endGame

DropResult:		# Print the inserted location
	li $v0, 4
	la $a0, PrintDropResult1
	syscall

	lw $t7, latestColumn
	addi $a0, $t7, 1
	li $v0, 1
	syscall
	
	li $v0, 4
	la $a0, PrintDropResult2
	syscall
	jr $ra
	
checkBoard:
	# $s1: current piece type (X/O)
	# $s2: current Id
	# $s3: current column (0 - 6)
	lw $s1, piece
	lw $s2, latestId
	lw $s3, latestColumn
	
	# Idea: count the total consecutive matching pieces on left & right to check
	li $t0, 0			# $t0: count in a direction

	mul $s3, $s3, 4
	sub $t2, $s2, $s3		# $t2: a[i][0] - to terminate loops
	addi $t3, $t2, 24		# $t3: a[i][6] - to terminate loops
	
	checkBoard_Horizon:
		li $t0, 0		# $t0: total cnt for every check
		addi $t4, $s2, -4	# a[i][j - 1] to a[i][j - 3]
		li $t1, 0		# temporary count
		checkBoard_HorizonL:
			beq $t0, 3, endGame		# straight to terminator, no need to check anymore
			blt $t4, $t2, checkBoard_HorizonL_exit
			lw $t5, aBoard($t4)
			bne $t5, $s1, checkBoard_HorizonL_exit
			
			addi $t0, $t0, 1
			addi $t4, $t4, -4
			j checkBoard_HorizonL
		checkBoard_HorizonL_exit:
			# when the no. consecutive pieces is not enough, we need to proceed next step
			addi $t4, $s2, 4			# Init. value for rightward check
		checkBoard_HorizonR:
			beq $t0, 3, endGame		# straight to terminator, no need to check anymore
			bgt $t4, $t3, checkBoard_HorizonR_exit
			lw $t5, aBoard($t4)
			bne $t5, $s1, checkBoard_HorizonR_exit
			
			addi $t0, $t0, 1
			addi $t4, $t4, 4
			j checkBoard_HorizonR
		checkBoard_HorizonR_exit:
            seq $s5, $t0, 2
    		beq $s5, 1, setCheckWinChanceH
			beq $s5, 0, checkBoard_Vertical
			setCheckWinChanceH:
			lw $a0, whichP
			mul $a0, $a0, 4
			sw $s5, CheckWinChance($a0) #CheckWinChance = 1, there 3 consecutive piece
			bgt $t0, 2, endGame
			j checkBoard_Vertical
			
	# With the vertical direction, we only need to check for 3 consecutive pieces below the inserted piece
	checkBoard_Vertical:
		li $t0, 0
		addi $t4, $s2, 28		# Go down 1 row: a[i - 1][j] to a[i - 3][j]
		checkBoard_Vertical_loop:
			beq $t0, 3, endGame
			bgt $t4, 164, checkBoard_Vertical_exit	# Out of bound
			lw $t5, aBoard($t4)
			bne $t5, $s1, checkBoard_Vertical_exit
			
			addi $t0, $t0, 1
			addi $t4, $t4, 28
			j checkBoard_Vertical_loop
		checkBoard_Vertical_exit:
            seq $s5, $t0, 2
    		beq $s5, 1, setCheckWinChanceV
			beq $s5, 0, checkBoard_MainDiag
			setCheckWinChanceV:
			lw $a0, whichP
			mul $a0, $a0, 4
			sw $s5, CheckWinChance($a0) #CheckWinChance = 1, there 3 consecutive piece

			bgt $t0, 2, endGame
			j checkBoard_MainDiag
		
	
	# Diagonal: main and sub diagonal
	lw $s3, latestColumn
	li $t1, 6
	sub $t3, $t1, $s3		# Number of times we can move to the right
	sub $t2, $t1, $t3		# Number of times we can move to the left

	checkBoard_MainDiag:
		li $t0, 0		# $t0: total cnt for every check
		li $t1, 0		# Iterator
		addi $t4, $s2, -32	# a[i - 1][j - 1] to a[i - 3][j - 3]
		checkBoard_MainDiagL:
			beq $t1, $t2, checkBoard_MainDiagL_exit
			beq $t0, 3, endGame		
			blt $t4, 0, checkBoard_MainDiagL_exit
			lw $t5, aBoard($t4)
			bne $t5, $s1, checkBoard_MainDiagL_exit
			
			addi $t0, $t0, 1
			addi $t1, $t1, 1
			addi $t4, $t4, -32
			j checkBoard_MainDiagL
		checkBoard_MainDiagL_exit:
			# when the no. consecutive pieces is not enough, we need to proceed next step
			addi $t4, $s2, 32		# Init. value for rightward check
			li $t1, 0
		checkBoard_MainDiagR:
			beq $t1, $t3, checkBoard_MainDiagR_exit
			beq $t0, 3, endGame
			bgt $t4, 164, checkBoard_MainDiagR_exit
			lw $t5, aBoard($t4)
			bne $t5, $s1, checkBoard_MainDiagR_exit
			
			addi $t0, $t0, 1
			addi $t1, $t1, 1
			addi $t4, $t4, 32
			j checkBoard_MainDiagR
		checkBoard_MainDiagR_exit:
            seq $s5, $t0, 2
    		beq $s5, 1, setCheckWinChanceMD
			beq $s5, 0, checkBoard_SubDiag
			setCheckWinChanceMD:
			lw $a0, whichP
			mul $a0, $a0, 4
			sw $s5, CheckWinChance($a0) #CheckWinChance = 1, there 3 consecutive piece
			bgt $t0, 2, endGame
			j checkBoard_SubDiag
			# Else, continue to check for other direction

	# We use the same boundary as checking Main Diagonal
	checkBoard_SubDiag:
		li $t0, 0		# $t0: total cnt for every check
		li $t1, 0		# Iterator
		addi $t4, $s2, 24	# a[i + 1][j - 1] to a[i + 3][j - 3]
		checkBoard_SubDiagL:
			beq $t1, $t2, checkBoard_SubDiagL_exit
			beq $t0, 3, endGame
			bgt $t4, 164, checkBoard_SubDiagL_exit
			lw $t5, aBoard($t4)
			bne $t5, $s1, checkBoard_SubDiagL_exit
			
			addi $t0, $t0, 1
			addi $t1, $t1, 1
			addi $t4, $t4, 24
			j checkBoard_SubDiagL
		checkBoard_SubDiagL_exit:
			addi $t4, $s2, -24 #for right check 
			li $t1, 0
		checkBoard_SubDiagR:
			beq $t1, $t3, checkBoard_SubDiagR_exit
			beq $t0, 3, endGame
			blt $t4, 0, checkBoard_SubDiagR_exit
			lw $t5, aBoard($t4)
			bne $t5, $s1, checkBoard_SubDiagR_exit
			
			addi $t0, $t0, 1
			addi $t1, $t1, 1
			addi $t4, $t4, -24
			j checkBoard_SubDiagR
		checkBoard_SubDiagR_exit:
            seq $s5, $t0, 2 # 1 if this is a consecutive 3
    		beq $s5, 1, setCheckWinChanceSD
			beq $s5, 0, exit
			setCheckWinChanceSD:
			lw $a0, whichP
			mul $a0, $a0, 4
			sw $s5, CheckWinChance($a0) #CheckWinChance = 1, there 3 consecutive piece
			bgt $t0, 2, endGame
			j exit
			# Else, the player hasn't won yet.
		
undo:
	lw $s1, whichP
	mul $s1, $s1, 4
	lw $s0, undoCnt($s1)
	beq $s0, 0, exit		# Skip if the player has no undo try left
	
	# Print request for undo together with number of tries left
	li $v0, 4
	la $a0, undo_Print1
	syscall
	
	li $v0, 1
	move $a0, $s0
	syscall
	
	li $v0, 4
	la $a0, undo_Print2
	syscall
	
undo_repeatInput:		# Get user input
	li $v0, 12
	syscall
	move $s0, $v0		# $s0 stores the input
	
	li $v0, 4
	la $a0, endline
	syscall
	
	beq $s0, 'n', exit	# If the player refuse, skip
	beq $s0, 'N', exit
	
	beq $s0, 'y', undo_accept	# If the player accept, continue undoing
	beq $s0, 'Y', undo_accept
	
	#Else, the input is invalid
	li $v0, 4
	la $a0, undo_invalidInput
	syscall
	
	j undo_repeatInput
	
undo_accept:
	# If the player accept to undo
	# Reduce the undo tries
	lw $s1, whichP
	mul $s1, $s1, 4
	lw $s0, undoCnt($s1)
	addi $s0, $s0, -1
	sw $s0, undoCnt($s1)
	# Delete the move (set the cell to empty)
	lw $s0, latestId
	li $t0, -1
	sw $t0, aBoard($s0)
	jal printBoard
	# Jump back to the move-making process
	j jumpBackTurn
				
endGame:
	#lw $s1, turnCnt
	li $t0, 0
	lw $s7, aBoard($t0)
	jal fullBoardCheck
	lw $s1, checkFull # 1 is full, 0 is still empty
	beq $s1, 1, endGame_Draw
	# no tie game, so print Win
	li $v0, 4
	la $a0, endGame_printWin
	syscall

	li $v0, 4
	lw $a0, whichP
	#addi $a0, $a0, 1
	beq $a0, 1, player2win
	beq $a0, 0, player1win

	resultPlayer:
	lw $s6, piece #know what piece to print info
	li $t0, 0
	jal countPieceinBoard
	li $v0, 4
	la $a0, endGame_info1
	syscall
	lw $a0, countPiece
	li $v0, 1
	syscall

	j terminate
endGame_Draw:
	la $a0, endGame_PrintDraw
	syscall
	jal printBoard
	j terminate
player1win:
	la $a0, ($t8) 
	syscall
	j resultPlayer
player2win:
	la $a0, ($t9)
	syscall
	j resultPlayer
terminate:
	li $v0, 4
	la $a0, endGame_Terminate
	syscall
	li $v0, 10
	syscall
	
# out branch 
exit:
	jr $ra

# *** Count Piece to Print out the Win ***
countPieceinBoard:
	bgt $t0, 164, exit
	lw $s7, aBoard($t0)
	beq $s7, $s6, plusCountPiece
	addi $t0, $t0, 4
	j countPieceinBoard
	plusCountPiece: #increase countPiece
		lw $s4, countPiece
		addi $s4, $s4, 1
		addi $t0, $t0, 4
		sw $s4, countPiece
		j countPieceinBoard
		
# *** check the board is FULL ***
fullBoardCheck:
	bgt $t0, 24, exit
	lw $s7, aBoard($t0)
	beq $s7, -1, stillNotFull
	addi $t0, $t0, 4
	j fullBoardCheck	
	stillNotFull:
		lw $t1, checkFull
		add $t1, $zero, $zero #assign t1 =0, checkFull = false
		sw $t1, checkFull
		addi $t0, $t0, 4
		j fullBoardCheck


    
block:
    lw $s1, whichP
	xor $s1, $s1, 1
	mul $s1, $s1, 4 #consider this as index

	lw $s5, blockCnt($s1)
	beq $s5, 0, exit #1 time block only
	
	lw $s1, whichP
	mul $s1, $s1, 4
    lw $s5, CheckWinChance($s1) # check the winchance of oppenent
    beq $s5, 1, exit #opponent has chance to win, cannot block
    li $v0, 4
    la $a0, block_Print
    syscall

    li $v0, 12
    syscall
	beq $v0, '1', acceptBlock
	j exit
	acceptBlock:
	lw $s1, whichP # turn back to player index, and change it to zero
	xor $s1, $s1, 1
	mul $s1, $s1, 4
	lw $s5, blockCnt($s1)
	add $s5, $zero, $zero
	sw $s5, blockCnt($s1)

    lw $s1, piece
	xor $s1, $s1, 1		# Toggle piece color (type)
	sw $s1, piece
		
	lw $s1, whichP		# Switch player's index
	xor $s1, $s1, 1
	sw $s1, whichP
		
    j exit
