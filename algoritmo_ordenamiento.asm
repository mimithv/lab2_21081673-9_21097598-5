.data
	pedir_valor: .asciiz "Ingrese los elementos de la lista:\n"
	mensaje: .asciiz "Elemento "
	dos_puntos: .asciiz ": "
	coma: .asciiz ", "
	corchete1: .asciiz "["
	corchete2: .asciiz "]"
	newline: .asciiz "\n"
.text
  	main:
	 la $a0, pedir_valor
	 jal imprimir_mensaje
	
	 jal guardarListaEnMemoria # Almacena los elementos ingresados por el usuario en memoria desde la dirección 0x100100a0
	 la $s3, 0x10010100 # dirección 32 bits delante de 0x100100e0 (donde se guarda la lista ordenada)
	 la $s4, 0x100100e0 # dirección donde se ubica la lista, una vez ha sido ordenada
	
	addi $t8, $zero, 0 # i=0
	whileMain:
	 bgt $t8, 7, imprimirResultado # while (i<=7)
	 jal defineMayor # Compara todos los elementos de la "lista" y carga el mayor en $s0
	 jal reemplazarMayorPorMenosUno # Reemplaza el mayor por cero en la "lista" original y ubica el mayor desde la dirección 0x100100e0
	 
	 addi $t8, $t8, 1 # i++
	 
	 j whileMain
	
	imprimirResultado:
	 # Imprime el corchete inicial para imprimir la lista
	 la $a0, corchete1
	 jal imprimir_mensaje
	 
	addi $t8, $zero, 0 # i=0
	whileMain2:
	 bgt $t8, 7, salidaMain # while (i<=7)
	 jal mostrarResultado # Imprime cada uno de los elementos ya ordenados
	 jal imprimirComa # Imprime comas separadoras para mostrar el resultado en consola
	 
	 addi $t8, $t8, 1 # i++
	 
	 j whileMain2
	 
	salidaMain:
	 # Imprime el corchete de cierre indicando el final de la lista
	 la $a0, corchete2
	 jal imprimir_mensaje
	 
	 j exit # Accede al procedimiento final

#===================================================================================================================================#

	# Procedimiento 1
	guardarListaEnMemoria:
	 addi $t0, $zero, 0 # i=0
	 addi $t1, $zero, 4 # puntero
	 la $s1, 0x100100a0 # direccion de la lista
	 la $s2, 0x100100c0 # dirección de la copia de la lista
	 
	while1:
	 bgt $t0, 7, salida1 # while (i<=7)
	 
	 # Imprimir "Elemento "
	 li $v0, 4
	 la $a0, mensaje
	 syscall
	  
	 addi $s0, $zero, 1 # $s0 = 1
	 add $s0, $s0, $t0 # $s0 = 1 + $t0 para imprimir elemento 1, elemento 2 ... elemento i-esimo
	 
	 # Imprimir número de elemento
	 li $v0, 1
	 move $a0, $s0
	 syscall
	 
	 # Imprimir ": "
	 li $v0, 4
	 la $a0, dos_puntos
	 syscall
	 
	 # Pide elemento al usuario
	 li $v0, 5
	 syscall
	
	 move $t2, $v0 # La entrada se carga en $t2
	 
	 # Descubrimiento: Este código invierte una lista en la dirección de memoria anterior
	 #sub $s1, $s1, $t1
	 #sb $t2, ($s1)
	
	 add $s1, $s1, $t1 # Suma 4 a la dirección de memoria
	 sb $t2, -4($s1) # Resta 4 a la dirección de memoria
	 
	 add $s2, $s2, $t1 # Suma 4 a la dirección de memoria
	 sb $t2, -4($s2) # Resta 4 a la dirección de memoria
	 
	 addi $t0, $t0, 1 # i++
	 
	 j while1
	
	salida1:
	 jr $ra

#===================================================================================================================================#

	# Procedimiento 2
	defineMayor:
	 la $s2, 0x100100c0 # volver a la dirección inicial
	 
	 # Define el primer elemento como mayor
	 lb $t2, 0($s2)
	 move $s0, $t2
	
	# Reinicia los elementos necesarios para aplicar un nuevo while
	 addi $t0, $zero, 0 # i=0
	 addi $t1, $zero, 4 # puntero
	
	while2:
	 bgt $t0, 6, salida2 # while (i<=6)
	 
	 # Compara el mayor que se va guardando en $s0 con los siguientes valores en memoria
	 lb $t2, 4($s2)
	 
	 bgt $s0, $t2, primeroMayor
	 blt $s0, $t2, primeroMenor
	 beq $s0, $t2, iguales
	 
	 j while2
	 
	# Avanza sin modificar el elemento mayor $s0
	primeroMayor:
	 add $s2, $s2, $t1 # avanza la direccion de memoria
	 addi $t0, $t0, 1 # i++
	 b while2
	 
	# Actualiza el elemento mayor $s0 con el valor de $t2
	primeroMenor:
	 move $s0, $t2 # sobreescribe el valor menor $s0
	 add $s2, $s2, $t1 # avanza la direccion de memoria
	 addi $t0, $t0, 1 # i++
	 b while2
	 
	# Avanza sin modificar el elemento mayor $s0
	iguales:
	 add $s2, $s2, $t1 # avanza la direccion de memoria
	 addi $t0, $t0, 1 # i++
	 b while2
	 
	salida2:
	 jr $ra
	
#===================================================================================================================================#

	# Procedimiento 3
	reemplazarMayorPorMenosUno:
	 la $s2, 0x100100c0 # volver a la dirección inicial
	 addi $t0, $zero, 0 # i=0
	 addi $t1, $zero, 4 # puntero
	 addi $t2, $zero, 0 # constante 0
	 
	while3:
	 bgt $t0, 7, salida3 # while (i<=7)
	 
	 lb $t3, 0($s2)
	 beq $t3, $s0, reemplazo
	 
	 add $s2, $s2, $t1 # avanza la direccion de memoria
	 addi $t0, $t0, 1 # i++
	 
	 j while3
	 
	reemplazo:
	 sb $t2, 0($s2) # Reemplaza por cero el valor mayor de la lista
	 sb $s0, -4($s3) # Ubica el mayor valor desde la dirección 0x100100e0
	 sub $s3, $s3, $t1
	
	salida3:
	 jr $ra
	 
	mostrarResultado:
	 addi $t0, $zero, 0 # i=0
	 addi $t1, $zero, 4 # puntero
	 
	while4:
	 bgt $t0, 7, salida4 # while (i<=7)
	 
	 lb $t2, 0($s4) # Obtiene los elementos desde la memoria (data segment)
	 
	 # Imprime los elementos de la lista resultado
	 li $v0, 1
	 move $a0, $t2
	 syscall
	 
	 add $s4, $s4, $t1 # avanza la direccion de memoria
	 addi $t0, $t0, 1 # i++
	 
	salida4:
	 jr $ra
	
	imprimirComa:
	 bgt $t8, 6, salidaComa
	 # Imprime la comas separadoras
	 li $v0, 4
	 la $a0, coma
	 syscall
	 
	salidaComa:
	 jr $ra
	 
#===================================================================================================================================#

	# Seccion de procedimientos utilizados repetidas veces
	
	# Procedimiento "imprimir_mensaje"
	# Descripción: imprime un mensaje por consola con $v0 = 4
	# ENTRADA: requiere que el mensaje a imprimir se encuentre en $v0
	# SALIDA: el mensaje se muestra en pantalla
	imprimir_mensaje:
	 li $v0, 4
	 syscall
	 
	 jr $ra
	
#===================================================================================================================================# 
	
	# Procedimiento final
	exit:
	 # Termina el programa
	 li $v0, 10
	 syscall
	
	
