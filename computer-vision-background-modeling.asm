.data
    basePath: 		.asciiz "C:/Workspace/Programming/mips-assembly/images/"
    pgmExtension: 	.asciiz ".pgm"
    finalPath: 		.space 	256		# Reserva um espa�o que conter� a string do caminho para o arquivo que ser� lido dentro no "readFile"
    MAX_IDX_OF_IMGS: 	.word 	1
    arr: 		.word	0:307200	# Vetor 2d (640 x 480) que guarda as m�dias de cada pixel, inicializado com 0 em cada campo
    ARR_SIZE: 		.word 	131072          # Use "1228800" para a imagem inteira 	
    file:		.space	1048576		# Space to store the file in memory (1 Megabyte)
    FILE_SIZE: 		.word 	1048576		# Quantidade de bytes m�xima do arquivo
    
    FILE_HEADER: 	.asciiz "P2\n640 480\n255\n"
    newLine: 		.asciiz "\n"
    outputPath:		.asciiz "resultado.pgm" #C:/Workspace/Programming/mips-assembly/images/
    promptDir:		.asciiz "Insira o diret�rio dos arquivos a serem lidos\n - Use '/' ao inv�s de '\' e coloque '\' no final\n - Exemplo: C:/images/\n\nInsira o diret�rio:\n"

.text
    main:
    	# 0. Declarar v�riav�is auxiliares
    	addi 	$t0, $zero, 0 		# $t0 = index = 0
    	lw 	$s7, MAX_IDX_OF_IMGS 	# $s7 = MAX_IDX_OF_IMGS

	addi 	$t7, $zero, 1 		# $t7 = isFirstFile = true
	   	   	
    	whileLoop:
    		bgt $t0, $s7, exitWhileLoop # if (index > MAX_IDX_OF_IMGS), v� para o "exitWhileLoop"
    		
    		# 1. Ler o arquivo
    		readFile:
    			# 1.1. Definir o diret�rio para o arquivo atual
    			loadFinalPath:
    				la $s0, finalPath 	# $s0 = ponteiro para o diret�rio do arquivo atual
    				la $s1, basePath 	# $s1 = ponteiro para string contendo a primeira parte do diret�rio
    				la $s2, pgmExtension	# $s2 = ponteiro para a string contendo a extens�o ".pgm"
    			
    				copyBasePathToFinalPath:  
  					lb	$t1, ($s1)			# Carregar o bit apontado pelo ponteiro de "basePath" em $t1  
   					beqz 	$t1, copyIndexToFinalPath	# Verificar se o bit em $t1 � o final da linha (zero), se sim ir para a pr�xima fun��o
   					sb 	$t1, ($s0)			# Copiar o bit carregado em $t1 no ponteiro de "finalPath"
   					addi 	$s1, $s1, 1			# O ponteiro de "basePath" apontar� para um character a frente
   					addi 	$s0, $s0, 1			# O ponteiro de "finalPath" apontar� para um character a frente
   					j copyBasePathToFinalPath		# Repetir
   			
   				copyIndexToFinalPath:
   					add 	$t1, $t0, 48		# Guardar o character correspondente ao index do arquivo atual em $t1 (0 na tabela ascii = 48)
   					sb	$t1, ($s0)		# Copiar o bit carregado em $t1 no ponteiro de "finalPath"
   					addi 	$s0, $s0, 1 	      	# O ponteiro de "finalPath" apontar� para um character a frente
   					j copyExtensionToFinalPath
   				
   				copyExtensionToFinalPath:  
  					lb 	$t1, ($s2)              # Carregar o bit apontado pelo ponteiro de "pgmExtension" em $t1
   					beqz 	$t1, exitLoadFinalPath	# Verificar se o bit em $t1 � o final da linha (zero), se sim sair
   					sb 	$t1, ($s0)              # Copiar o bit carregado em $t1 no ponteiro de "finalPath"
   					addi 	$s2, $s2, 1         	# O ponteiro de "pgmExtension" apontar� para um character a frente   
   					addi 	$s0, $s0, 1    		# O ponteiro de "finalPath" apontar� para um character a frente           
   					j copyExtensionToFinalPath 	# Repetir
    			
    			exitLoadFinalPath:
    			
    			# 1.2. Carregar ponteiro para o arquivo
    			loadFilePointer:
	    			# 1.2.1. Abrir arquivo
    				li $v0, 13		# C�digo para abrir arquivo (13)
        			la $a0, finalPath     	# Diret�rio do arquivo = "finalPath"
        			li $a1, 0		# Flag para ler o arquivo (0 para ler, 1 para escrever)
        			syscall
        			
        			# 1.2.2. Salvar arquivo em "file"
        			move 	$s0, $v0            	# $s0 = descritor do arquivo  
        			li 	$v0, 14           	# C�digo para ler arquivo = 14
        			move	$a0, $s0         	# $s0 = descritor do arquivo
        			la 	$a1, file		# "file" � um buffer para uma string contendo todo o arquivo
       				la	$a2, FILE_SIZE       	# Tamanho do buffer = "FILE_SIZE"
        			syscall
        			
        			# 1.2.3. Fechar o arquivo
        			li 	$v0, 16		# C�digo para fechar arquivo (16)
        			move 	$a0, $s0	# Descritor do arquivo que ser� fechado
        			syscall
			
			# 1.3. Fazer m�dia entre os dados do arquivos e da mem�ria
			calculateMean:
				# 1.3.1 Carregar ponteiro & pular cabe�alho do arquivo
				la 	$s1, file	# $s1 = ponteiro do arquivo
				addi 	$s1, $s1, 15 	# Pular cabe�alho do arquivo (15 caracteres)
				
				addi 	$t3, $zero, 0	 	# $t3 = matrixIndex = 0
				lw	$t4, ARR_SIZE 		# $t4 = ARR_SIZE
				
				# 1.3.2 Ler a matriz de valores do arquivo e mem�ria fazendo a m�dia
				forValueOfMatrixLoop:
					beq $t3, $t4, exitForValueOfMatrixLoop # if (matrixIndex == ARR_SIZE) saia do loop
					
					# 1.3.2.1 Ler valor do arquivo
					addi $s2, $zero, 0 	# numFile = inteiro a ser lido no arquivo = $s2 = 0
					
					readIntFromFile:
						lb 	$t1, ($s1)			# Carregar em $t1 o bit apontado por "file"
   						blt  	$t1, 48, exitReadIntFromFile	# Verificar se o bit em $t1 � menor que o valor para 0 (0 na tabela ascii = 48), se sim ir sair do loop
   						sub 	$t2, $t1, 48 			# Grave em t2 o valor inteiro correspondente do character em $t1 (0 na tabela ascii = 48)
   						mul 	$s2, $s2, 10 			# numFile * 10 para que o n�mero a ser adicionado esteja na casa certa
   						add 	$s2, $s2, $t2			# Adicione o novo n�mero em numFile
   						addi 	$s1, $s1, 1			# O ponteiro de "file" apontar� para um caracter a frente	
						j readIntFromFile			# Repetir
				
					exitReadIntFromFile:
						addi 	$s1, $s1, 1			# O ponteiro de "file" apontar� para um caracter a frente
					
					# 1.3.2.2 Ler valor da matrix
					lw 	$s3, arr($t3) 	# inteiro da matrix = $s3 = arr[matrixIndex]
					
					# 1.3.2.3 Verificar se � o primeiro arquivo a ser lido, pois n�o � poss�vel fazer a m�dia apenas com um valor
					beq $t7, 0, averageNumbers # if(!isFirstFile) v� para "averageNumbers"
					
					# Caso seja o primeiro arquivo a ser lido, apenas adicione os valores do arquivo na matriz
					j addFinalNumber
					
					# 1.3.2.3 Tirar a m�dia entre os dois valores
					averageNumbers:
						add $s2, $s2, $s3	# numFile = (numFile + arr[matrixIndex])
						div $s2, $s2, 2 	# numFile = numFile/2
					
					# 1.3.2.3 Adicionar o n�mero resultante na matrix
					addFinalNumber:
						sw $s2, arr($t3) # arr[matrixIndex] = numFile
					
					addi 	$t3, $t3, 4 	# matrixIndex++ (int = 4 bytes)
					
					j forValueOfMatrixLoop # Repetir
					
				exitForValueOfMatrixLoop:	
			
    		addi $t0, $t0, 1 	# index++
    		
    		addi $t7, $zero, 0 	# $t7 = isFirstFile = false
    		
    		j whileLoop     	# Repetir

    	exitWhileLoop:
    	
    	# 2. Escrever o novo arquivo
    	loadOutPutFilePointer:
    		# 2.1 Abrir o novo arquivo
    		li $v0, 13           	# C�digo para abrir arquivo (13)
    		la $a0, outputPath     	# Diret�rio do arquivo = "outputPath"
    		li $a1, 1           	# Flag para escrever o arquivo (0 para ler, 1 para escrever)
    		syscall
    		
    		move $s4, $v0        	# $s4 Descritor do arquivo
    		
    		addi $t3, $zero, 0	# $t3 = matrixIndex = 0
    		
    		# 2.2. Escrever o cabe�alho do arquivo
	    	li	$v0, 15			#  C�digo para escrever arquivo (15)
    		move	$a0, $s4		# $a0 = Descritor do arquivo
    		la	$a1, FILE_HEADER	# $a1 = string a ser escrita ("FILE_HEADER")
		la	$a2, 15			# $a2 = Quantidade de bytes a serem escritos
		syscall

    		lw $t2, ARR_SIZE 	# $t4 = ARR_SIZE
    		
		# 2.3. Ler a matriz de valores em memoria e escreve-la no arquivo
		matrixLoop:
				beq $t3, $t2, exitMatrixLoop # if (matrixIndex == ARR_SIZE) saia do loop
		    		
		    		# 2.3.1. Pegar n�mero inteiro da matriz e converter para uma string
		    		# 2.3.1.1. Alocar na mem�ria espa�o para string convertida (4 caracteres)
				li $v0, 9 	# C�digo para alocar na mem�ria (9)
				li $a0, 4   	# $a0 = Quantidade de bytes que precisam ser alocadas
				syscall
				
				move $s6, $v0 	# $s6 = ponteiro para o �nicio do buffer da string
		    		
		    		# 2.3.1.2. Carregar n�mero inteiro da matrix
		    		lw $s5, arr($t3)	# inteiro da matrix = $s5 = arr[matrixIndex]
				
				# 2.3.1.3. Preencher a string da direita para a esquerda
				addi $s6, $s6, 3    	# Faz com que o ponteiro aponte para o �ltimo elemento da string
				addi $t1, $zero, 0	# $t1 = sizeOfString = 0 (quantidades de bytes que foram realmente modificados)
				
				# 2.3.1.4. Salvar um " " (espa�o) no final da string
				li $t5, 32      	# $t5 = " " (espa�o na tabela ascii = 32) 
				sb $t5, 0($s6) 		# salvar caracter " " (espa�o) no final da string
				
				addi $t1, $t1, 1    	# sizeOfString++
				
				beqz $s5, caseZero 	# Caso o n�mero seja 0, tratar especialmente
				
				# 2.3.1.5. Converter inteiro para string
				forEachDigitLoop:
					blez 	$s5, exitForEachDigitLoop 	# Caso $s5 seja zero, a fun��o terminou de converter o n�mero para string
					addi 	$s6, $s6, -1   			# Mover o ponteiro da string para esquerda
	
					li 	$t4, 10
					div  	$s5, $t4	# arr[matrixIndex]/10
  					mflo 	$t5		# $t5 = quociente
  					mfhi 	$t6		# $t6 = resto
  	
  					addi	$t6, $t6, 48	# Converter casa decimal inteira para n�mero na tabela ascii (0 na tabela ascii = 48)
					sb	$t6, 0($s6)	# Salvar n�mero ascii na string
	
					move	$s5, $t5	# $s5 = quociente de arr[matrixIndex]/10
					
					addi 	$t1, $t1, 1	# sizeOfString++
					j forEachDigitLoop

				caseZero:
					addi $s6, $s6, -1   	# Mover o ponteiro da string para esquerda
					li   $t6, 48		# $t6 = 0 na tabela ascii (48)
  					sb   $t6, 0($s6)	# Salvar n�mero ascii na string
  					
  					addi $t1, $t1, 1   	# sizeOfString++
  					j writeNumberToFile	# Repetir
				
				exitForEachDigitLoop:
				
				# 2.3.2. Escrever string convertida no arquivo
				writeNumberToFile:
	    				li 	$v0, 15			# C�digo pra escrever arquivo (15)
    					move 	$a0, $s4		# $a0 = descritor do arquivo 
    					la 	$a1, ($s6)		# $a1 = a string que ser� escrita = ponteiro para a string convertida 
					move 	$a2, $t1		# $a2 = quantidades de bits que ser�o escritos = sizeOfString
			    		syscall
		    		
		    		addi 	$t3, $t3, 4	 # matrixIndex++
		    		
		    		j matrixLoop
		exitMatrixLoop:
		
    		li 	$v0, 16		# C�digo para fechar o arquivo
	    	move 	$a0, $s4	# Descritor do arquivo que ser� fechado
    		syscall
    		
    	# Finalizar programa
	li $v0, 10
 	syscall
