.data
	menu: .asciiz "Seleccione la fórmula:\n1. Combinatoria\n2. Permutaciones\n3. Variaciones\nSeleccione una opción:\n"
	pedir_n: .asciiz "n?="
	pedir_m: .asciiz "m?="
	valor_invalido: .asciiz "No válido"
	mensaje_opcion_no_valida: .asciiz "No válido"
	newline: .asciiz "\n"
	resultado: .asciiz "Resultado: "
	cero_flotante: .float 0.0
	uno_flotante: .float 1.0
	primer_decimal: .float 0.1
	segundo_decimal: .float 0.01
	tercer_decimal: .float 0.001
	
.text
	main:
   	 # Muestra el menú en consola
   	 la $a0, menu
   	 jal imprimir_mensaje
    
   	 # Leer la opción del usuario
   	 jal solicitar_entero
    	 move $t0, $v0
    
    	 # Verificar la opción seleccionada
    	 beq $t0, 1, opcion1
    	 beq $t0, 2, opcion2
    	 beq $t0, 3, opcion3
    	 j opcion_no_valida
    	 
#===================================================================================================================================#
	
	# Cálculo de combinatoria
	opcion1:
 	 # Solicita los valores de m y n. Además comprueba si cada uno es mayor o igual a cero y que n >= m
	 la $a0, pedir_n
	 jal imprimir_mensaje # imprime "n?="
	 jal solicitar_entero
	 move $t8, $v0 # ubica n en $t8
	 addi $t0, $t8, 0 # copia de n en $t0
	 jal comprobar_que_es_cero_o_mayor1 # comprueba si n es mayor o igual a cero
	 la $a0, pedir_m
	 jal imprimir_mensaje # imprime "m?="
	 jal solicitar_entero
	 move $t9, $v0 # ubica m en $t9
	 addi $t0, $t9, 0 # copia de m en $t0
	 jal comprobar_que_es_cero_o_mayor1 # comprueba si m es mayor o igual a cero
	 jal comprobar_que_n_mayor_que_m # comprueba si n >= m
	 
	 # Obtener numerador
	 add $t0, $zero, $t8 # pone a n en $t0
	 jal permutacion # calcula n!
	 move $s1, $t7 # ubica el resultado de n! en $s1
	 
	 # limpieza del data segment
	 jal limpieza_memoria # ubica un cero en los n bloques siguiente a 0x100100a0
	 
	 # Obtener denominador1
	 jal resta # calcula n-m
	 jal permutacion # calcula (n-m)!
	 move $s2, $t7 # ubica el resultado de (n-m)! en $s2
	 
	 # limpieza del data segment
	 jal limpieza_memoria # ubica un cero en los n bloques siguiente a 0x100100a0
	 
	 #Obtener denominador2
	 add $t0, $zero, $t9 # pone a m en $t0
	 jal permutacion # calcula m!
	 move $s3, $t7 # ubica el resultado de m! en $s3
	 
	 # limpieza del data segment
	 jal limpieza_memoria # ubica un cero en los n bloques siguiente a 0x100100a0
	 
	 #Obtener denominador
	 move $t0, $s2 # ubica (n-m)! en $t0
	 move $t1, $s3 # ubica m! en $t1
	 jal multiplicacion # multiplica m! * (n-m)!
	 move $s2, $t4 # ubica el resultado de m! * (n-m)! en $s2
	 
	 # Dividir numerador y denominador
	 move $t0, $s1 # ubica n! en $t0
	 move $t1, $s2 # ubica m! * (n-m)! en $t1
	 jal division # divide n! entre m! * (n-m)!
	 la $a0, resultado
	 jal imprimir_mensaje # Imprime mensaje de resultado
	 beq $t0, $t1, sonIguales # comprueba si el numerador es igual al denominador
	 jal comprobar_resto # comprueba si el resto de la división es cero (resultado entero) o distinto de cero (resultado flotante)
	 jal convertir_a_flotante # si el resto es distinto de cero se trabaja con flotantes
	 jal obtener_primer_decimal # se obtiene el primer decimal. Si el resultado es exacto, termina. Caso contrario, continua.
	 jal obtener_segundo_decimal # se obtiene el seegundo decimal. Si el resultado es exacto, termina. Caso contrario, continua. 
	 jal obtener_tercer_decimal # se obtiene el tercer decimal
	 
	 j end
	  
#----------------------------------------------------------------------------------------------------------------------------------#

	# Comprueba que el valor en $t0 es mayor o igual a cero
	comprobar_que_es_cero_o_mayor1:
	 addi $t1, $zero, -1
	 bgt $t0, $t1, se_puede_calcular1
	 
	 li $v0, 4
	 la $a0, valor_invalido
	 syscall
	 
	 li $v0, 4
   	 la $a0, newline
   	 syscall
	 
	 b opcion1
	 
	se_puede_calcular1:
	 jr $ra
	
	# Comprueba que n es mayor que m
	comprobar_que_n_mayor_que_m:
	 bgt $t8, $t9, continuar1
	 beq $t8, $t9, continuar1
	 
	 li $v0, 4
	 la $a0, valor_invalido
	 syscall
	 
	 li $v0, 4
   	 la $a0, newline
   	 syscall
	 
	 b opcion1
	 
	continuar1:
	 jr $ra
	 
#----------------------------------------------------------------------------------------------------------------------------------#

	multiplicacion:
	# Se busca que el mayor valor se encuentre en $t0
	blt $t0, $t1, primeroMenor
	bgt $t0, $t1, encabezadoMult
	beq $t0, $t1, encabezadoMult
	
	primeroMenor:
	 addi $t2, $t1, 0 # Copia el mayor valor a $t2
	 addi $t1, $t0, 0 # Sobreescribe el valor de $t1
	 addi $t0, $t2, 0 # Ubica el mayor en $t0
	
	encabezadoMult:
	 addi $t2, $zero, 0 # i=0
	 addi $t3, $zero, 0 # limpieza
	 subi $t3, $t1, 1 # $t3 = $t1 - 1
	 addi $t4, $zero, 0 # limpia el registro donde se guardará el resultado
	mult:
	 bgt $t2, $t3, salidaMult # while (i<= valor2 - 1)
	 
	 add $t4, $t4, $t0 # $t4 = $t4 + $t0
	 
	 addi $t2, $t2, 1 # i++
	 
	 j mult
	 
	salidaMult:
	 jr $ra
	  
#===================================================================================================================================#

	# Cálculo de permutación
	opcion2:
	 addi $t0, $zero, 0 #limpia $t0
	 la $a0, pedir_n
	 jal imprimir_mensaje # imprime "n?="
	 jal solicitar_entero
	 move $t0, $v0 # ubica n en $t0
	 jal comprobar_que_es_cero_o_mayor2 # comprueba si n es mayor o igual a cero
	 jal permutacion # calcula n!
	 la $a0, resultado
	 jal imprimir_mensaje # Imprime mensaje de resultado
	 move $a0, $t7
	 jal imprimir_entero # Imprime el valor del resultado
	 
	 j end
	
#----------------------------------------------------------------------------------------------------------------------------------#
	
	comprobar_que_es_cero_o_mayor2:
	 addi $t1, $zero, -1
	 bgt $t0, $t1, se_puede_calcular2
	 
	 li $v0, 4
	 la $a0, valor_invalido
	 syscall
	 
	 li $v0, 4
   	 la $a0, newline
   	 syscall
	 
	 b opcion2
	 
	se_puede_calcular2:
	 jr $ra

#===================================================================================================================================#

	# Cálculo de variación
    	opcion3:
	# Solicita los valores de n y m
	 la $a0, pedir_m
	 jal imprimir_mensaje # imprime "m?="
	 jal solicitar_entero
	 move $t8, $v0 # ubica m en $t8
	 addi $t0, $t8, 0 # copia de m en $t0
	 jal comprobar_que_es_cero_o_mayor3 # comprueba si m es mayor o igual a cero
	 la $a0, pedir_n
	 jal imprimir_mensaje # imprime "n?="
	 jal solicitar_entero
	 move $t9, $v0 # ubica n en $t9
	 addi $t0, $t9, 0 # copia de n en $t0
	 jal comprobar_que_es_cero_o_mayor3 # comprueba si n es mayor o igual a cero
	 jal comprobar_que_m_mayor_que_n # comprueba si m >= n
	 
	 # Obtener numerador
	 add $t0, $zero, $t8 # pone a m en $t0
	 jal permutacion # calcula m!
	 move $s1, $t7 # ubica m! en $s1
	 
	 # limpieza del data segment
	 jal limpieza_memoria # ubica un cero en los n bloques siguiente a 0x100100a0
	 
	 # Obtener denominador
	 jal resta # calcula m-n
	 jal permutacion # calcula (m-n)!
	 move $s2, $t7 # ubica (m-n)! en $s2
	 
	 # Dividir numerador y denominador
	 move $t0, $s1 # ubica m! en $t0
	 move $t1, $s2 # ubica (m-n)! en $t1
	 jal division # Obtiene el resultado final
	 la $a0, resultado
	 jal imprimir_mensaje # Imprime mensaje de resultado
	 beq $t0, $t1, sonIguales # comprueba si el numerador es igual al denominador
	 jal comprobar_resto # comprueba si el resto de la división es cero (resultado entero) o distinto de cero (resultado flotante)
	 jal convertir_a_flotante # si el resto es distinto de cero se trabaja con flotantes
	 jal obtener_primer_decimal # se obtiene el primer decimal. Si el resultado es exacto, termina. Caso contrario, continua.
	 jal obtener_segundo_decimal # se obtiene el seegundo decimal. Si el resultado es exacto, termina. Caso contrario, continua. 
	 jal obtener_tercer_decimal # se obtiene el tercer decimal
	 
	 j end
	
#----------------------------------------------------------------------------------------------------------------------------------#

	# Comprueba que el valor en $t0 es mayor o igual a 0
	comprobar_que_es_cero_o_mayor3:
	 addi $t1, $zero, -1
	 bgt $t0, $t1, se_puede_calcular3
	 
	 li $v0, 4
	 la $a0, valor_invalido
	 syscall
	 
	 li $v0, 4
   	 la $a0, newline
   	 syscall
	 
	 b opcion3
	 
	se_puede_calcular3:
	 jr $ra
	
	# Comprueba que m es mayor que n
	comprobar_que_m_mayor_que_n:
	 bgt $t8, $t9, continuar3
	 beq $t8, $t9, continuar3
	 
	 li $v0, 4
	 la $a0, valor_invalido
	 syscall
	 
	 li $v0, 4
   	 la $a0, newline
   	 syscall
	 
	 b opcion3
	 
	continuar3:
	 jr $ra

#===================================================================================================================================#
	
	opcion_no_valida:
    	 # Mostrar mensaje de opción inválida
    	 li $v0, 4
    	 la $a0, mensaje_opcion_no_valida
    	 syscall
    	 
    	 li $v0, 4
   	 la $a0, newline
   	 syscall
    	 
    	 b main
    	 
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
	 
	# Procedimiento "imprimir_entero"
	# Descripción: imprime un entero en consola con $v0 = 1
	# ENTRADA: requiere que el valor a imprimir se encuentre en $a0
	# SALIDA: el entero se muestra en pantalla
	imprimir_entero:
	 # Imprime el valor del resultado
	 li $v0, 1
	 syscall
	 
	 jr $ra
	 
	# Procedimiento "solicitar_entero"
	# Descripción: solicita un entero por consola con $v0 = 5
	# ENTRADA: vacío
	# SALIDA: el entero ingresado queda en $v0
	solicitar_entero:
	 # Solicita el valor de n
	 li $v0, 5
	 syscall
	 
	 jr $ra
	 
	# Procedimiento permutación
	# Descripción: Calcula el factorial del número contenido en $t0 y su resultado queda en $t7
	# ENTRADA: $t0
	# SALIDA: $t7
	permutacion:
	 add $t3, $zero, $t0 # registro donde se guarda el valor actual del ciclo. Toma valores (6, 5, 4, 3, 2, 1, 0) para n=6
	 
	 # En memoria se cargan los valores (n, n-1, n-2 ... 0) desde la posición 0x100100a0
	 addi $t1, $zero, 0 # i=0
	 addi $t2, $zero, 4 # puntero
	 la $s0, 0x100100a0 # dirección requerida
	 
	while1:
	 bgt $t1, $t0, encabezadoWhile2 # while (i <= n)
	 
	 sb $t3, 0($s0) # guarda valores en data segment
	 subi $t3, $t3, 1 # disminuye el valor de n
	 
	 add $s0, $s0, $t2 # suma 4 a la dirección en $s0
	 addi $t1, $t1, 1 # i++
	 
	 j while1
	  
	encabezadoWhile2:
	 addi $t1, $zero, 0 # i=0
	 addi $t2, $zero, 4 # puntero
	 addi $t3, $zero, 0 # limpia $t3
	 la $s0, 0x100100a0 # dirección requerida
	 lb $t3, 0($s0)
	 beq $t3, 0, casoBase # caso base
	 beq $t3, 1, casoBase1 # necesario, debido a que el while2 terminaría diciendo que 1! = 0
	 
	while2:
	 lb $t4, 4($s0)
	 
	 beq $t4, 0, salidaWhile2 # Avanza hasta que encuentra un cero
	 
	# Encabezado while3
	 addi $t5, $zero, 0 # j=0
	 subi $t6, $t4, 1 # $t6 = $t4 - 1
	 addi $t7, $zero, 0 # limpia el registro donde se guardará el resultado
	 
	while3:
	 bgt $t5, $t6, llamadoWhile2 # while (j<= valor2 - 1)
	 
	 add $t7, $t7, $t3 # $t7 = $t7 + $t3
	 
	 addi $t5, $t5, 1 # j++
	 
	 j while3
	 
	llamadoWhile2:
	 move $t3, $t7 # en $t3 se guardan los resultados parciales
	 add $s0, $s0, $t2 # suma 4 a la dirección en $s0
	 addi $t1, $t1, 1 # i++
	 
	 j while2
	
	salidaWhile2:
	 jr $ra
	 
	casoBase:
	 addi $t7, $t3, 1
	 
	 jr $ra
	 
	casoBase1:
	 addi $t7, $t3, 0
	 
	 jr $ra
	
	# Procedimiento resta
	# Descripción: resta el contenido de los registros $t8 y $t9 y deja el resultado en $t0
	# ENTRADAS: $t8 y $t9
	# SALIDA: $t0
	resta:
	 sub $t0, $t8, $t9
	 
	 jr $ra
	 
	# Procedimiento división: efecto en cadena --> avanza sólo si es necesario
	# 1. división (si el resultado es entero, termina)
	# 2. convertir a flotante
	# 3. obtener primer decimal (si el resultado tiene 1 decimal, termina)
	# 4. obtener segundo decimal (si el resultado tiene 2 decimales, termina)
	# 5. obtener tercer decimal (llega aquí si el resultado tiene 3 o más decimales)
	# ENTRADAS: $t0 y $t1
	# SALIDA: 
	# si el resultado es entero --> $t3 --> $v0
	# si el resultado es flotante -->  $f16 --> $f12
	# y el resultado se muestra en consola
	division:
	 add $t2, $zero, $t1 # copia valor2
	 addi $t3, $zero, 0 # Aquí se guarda el resultado
	 
	loop:
	 bgt $t2, $t0, salida # while (valor2 <= valor1)
	 
	 add $t2, $t2, $t1 # $t2 = $t2 + $t1
	 
	 addi $t3, $t3, 1 # result = result + 1
	 
	 j loop
	 
	salida:
	 jr $ra
	 
	sonIguales:
	 li $v0, 1
	 move $a0, $t3
	 syscall
	  
	 j end
	 
	comprobar_resto:
	 addi $t4, $zero, 0 # i=0
	 addi $t5, $zero, 0 # limpieza
	 subi $t5, $t1, 1 # $t5 = $t1 - 1
	 addi $t6, $zero, 0 # limpia el registro donde se guardará el resultado
	while:
	 bgt $t4, $t5, salida_while # while (i<= valor2 - 1)
	 
	 add $t6, $t6, $t3 # $t6 = $t6 + $t3
	 
	 addi $t4, $t4, 1 # i++
	 
	 j while
	 
	salida_while:
	 beq $t0, $t6, imprimir_valor
	 
	 jr $ra
	 
	imprimir_valor:
	 li $v0, 1
	 move $a0, $t3
	 syscall
	 
	 j end
	 
	convertir_a_flotante:
	 mtc1 $t0, $f0 # valor1
	 mtc1 $t1, $f2 # valor2
	 mtc1 $t3, $f4 # resultado
	 
	 # Convierte de entero a flotante
	 cvt.s.w $f0, $f0
	 cvt.s.w $f2, $f2
	 cvt.s.w $f4, $f4
	 
	 jr $ra
	 
	obtener_primer_decimal:
	 lwc1 $f30, cero_flotante # constante 0.0
	 lwc1 $f18, uno_flotante # constante 1.0
	 lwc1 $f6, primer_decimal # constante 0.1
	 add.s $f8, $f30, $f30 # aqui se guarda el resultado parcial
	 add.s $f10, $f30, $f30 # toma los valores 0.1 , 0.2 , 0.3 , etc
	 
	 loop2:
	  c.eq.s 1, $f0, $f8
	  bc1t 1, decimal_unico
	  c.lt.s $f0, $f8
	  bc1t salida_loop2
	  
	  add.s $f8, $f30, $f30
	  add.s $f16, $f30, $f30
	  add.s $f10, $f10, $f6
	  add.s $f16, $f4, $f10
	  
	  add.s $f14, $f30, $f30 # i=0
	 loop3:
	  c.eq.s 2, $f14, $f2
	  bc1t 2, salida_loop3
	  add.s $f8, $f8, $f16
	  add.s $f14, $f14, $f18
	  
	  j loop3
	 salida_loop3:
	  j loop2
	 
	 decimal_unico:
	  li $v0, 2
	  add.s $f12, $f16, $f30
	  syscall
	  
	  j end
	  
	 salida_loop2:
	  jr $ra
	  
	 obtener_segundo_decimal:
	  sub.s $f4, $f16, $f6 # se guarda el resultado actual - 0.1
	  lwc1 $f6, segundo_decimal # constante 0.01
	  add.s $f8, $f30, $f30 # se reinicia el resultado parcial
	  add.s $f10, $f30, $f30 # toma los valores 0.01 , 0.02 , 0.03 , etc
	  add.s $f14, $f30, $f30 # se reinicia el iterador
	  add.s $f16, $f30, $f30 # aqui se obtiene el resultado
	  
	 loop4:
	  c.eq.s 1, $f0, $f8
	  bc1t 1, decimal_doble
	  c.lt.s 3, $f0, $f8
	  bc1t 3, salida_loop4
	  
	  add.s $f8, $f30, $f30
	  add.s $f16, $f30, $f30
	  add.s $f10, $f10, $f6
	  add.s $f16, $f4, $f10
	  
	  add.s $f14, $f30, $f30 # i=0
	 loop5:
	  c.eq.s 4, $f14, $f2
	  bc1t 4, salida_loop5
	  add.s $f8, $f8, $f16
	  add.s $f14, $f14, $f18
	  
	  j loop5
	 salida_loop5:
	  j loop4
	  
	 decimal_doble:
	  li $v0, 2
	  add.s $f12, $f16, $f30
	  syscall
	  
	  j end
	  
	 salida_loop4:
	  jr $ra
	  
	 obtener_tercer_decimal:
	  sub.s $f4, $f16, $f6 # se guarda el resultado actual - 0.01
	  lwc1 $f6, tercer_decimal # constante 0.001
	  add.s $f8, $f30, $f30 # se reinicia el resultado parcial
	  add.s $f10, $f30, $f30 # toma los valores 0.01 , 0.02 , 0.03 , etc
	  add.s $f14, $f30, $f30 # se reinicia el iterador
	  add.s $f16, $f30, $f30 # aqui se obtiene el resultado
	 loop6:
	  c.lt.s 5, $f0, $f8
	  bc1t 5, obtener_resultado
	  
	  add.s $f8, $f30, $f30
	  add.s $f16, $f30, $f30
	  add.s $f10, $f10, $f6
	  add.s $f16, $f4, $f10
	  
	  add.s $f14, $f30, $f30 # i=0
	 loop7:
	  c.eq.s 6, $f14, $f2
	  bc1t 6, salida_loop7
	  add.s $f8, $f8, $f16
	  add.s $f14, $f14, $f18
	  
	  j loop7
	 salida_loop7:
	  j loop6
	  
	 obtener_resultado:
	  li $v0, 2
	  add.s $f12, $f16, $f30
	  syscall
	  
	  jr $ra
	
	# Procedimiento "limpieza_memoria"
	# Descripción: Limpia los espacios de memoria utilizados para calcular algún factorial.
	# Cada uno de los espacios desde la dirección 0x100100a0 pasa a tener un 0
	# ENTRADA: $t0 --> cantidad de espacios de memoria utilizados
	# SALIDA: vacío
	limpieza_memoria:
	 addi $t1, $zero, 0 # i=0
	 addi $t2, $zero, 4 # constante 4
	 addi $t3, $zero, 0 # constante 0
	 la $s0, 0x100100a0 # dirección requerida
	 
	limpiador:
	 bgt $t1, $t0, salidaLimpiador # while ($t0 > iterador)
	 
	 sb $t3, 0($s0) # ubicar un 0 en la posicion actual de memoria
	 
	 add $s0, $s0, $t2 # avanza la direccion de memoria
	 addi $t1, $t1, 1 # i++
	 
	 j limpiador
	 
	salidaLimpiador:
	 jr $ra
	 
#===================================================================================================================================#
 
	end:
    	 # Fin programa
    	 li $v0, 10
    	 syscall
