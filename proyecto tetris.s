# Versión incompleta del tetris 
# Sincronizada con tetris.s:r3228
        
	.data	

pantalla:
	.word	0
	.word	0
	.space	1024

marcador:
	.word	0

campo:
	.word	0
	.word	0
	.space	1024

pieza_actual:
	.word	0
	.word	0
	.space	1024

pieza_siguiente:
	.word	0
	.word	0
	.space	1024

pieza_actual_x:
	.word 0

pieza_actual_y:
	.word 0

imagen_auxiliar:
	.word	0
	.word	0
	.space	1024

pieza_jota:
	.word	2
	.word	3
	.ascii		"\0#\0###\0\0"

pieza_ele:
	.word	2
	.word	3
	.ascii		"#\0#\0##\0\0"

pieza_barra:
	.word	1
	.word	4
	.ascii		"####\0\0\0\0"

pieza_zeta:
	.word	3
	.word	2
	.ascii		"##\0\0##\0\0"

pieza_ese:
	.word	3
	.word	2
	.ascii		"\0####\0\0\0"

pieza_cuadro:
	.word	2
	.word	2
	.ascii		"####\0\0\0\0"

pieza_te:
	.word	3
	.word	2
	.ascii		"\0#\0###\0\0"

piezas:
	.word	pieza_jota
	.word	pieza_ele
	.word	pieza_zeta
	.word	pieza_ese
	.word	pieza_barra
	.word	pieza_cuadro
	.word	pieza_te

acabar_partida:
	.byte	0

acabar_partida_campo_lleno:
	.byte	0

imagen_game_over:
	.word	19
	.word	4
	.ascii	"+-----------------+"
	.ascii	"| FIN DE PARTIDA  |"
	.ascii  "| Pulse una Tecla |"
	.ascii  "+-----------------+"
	
	.align	2
procesar_entrada.opciones:
	.byte	'x'
	.space	3
	.word	tecla_salir
	.byte	'j'
	.space	3
	.word	tecla_izquierda
	.byte	'l'
	.space	3
	.word	tecla_derecha
	.byte	'k'
	.space	3
	.word	tecla_abajo
	.byte	'i'
	.space	3
	.word	tecla_rotar
	.byte	't'
	.space	3
	.word	tecla_truco
	
pausa: 
	.word 1000

nivel:
	.word 0

str000:
	.asciiz		"Tetris\n\n 1 - Jugar\n 2 - Salir\n\nElige una opción:\n"
str001:
	.asciiz		"\n¡Adiós!\n"
str002:
	.asciiz		"\nOpción incorrecta. Pulse cualquier tecla para seguir.\n"

str003: 
	.asciiz		"Puntuacion: "
str004:
	.asciiz	        "Nivel: "
	
puntuacion:
	.space 256
	
textonivel:
	.space 256
	
	.text	

imagen_pixel_addr:			# ($a0, $a1, $a2) = (imagen, x, y)
					# pixel_addr = &data + y*ancho + x
    	lw	$t1, 0($a0)		# $a0 = dirección de la imagen 
					# $t1 ← ancho
    	mul	$t1, $t1, $a2		# $a2 * ancho
    	addu	$t1, $t1, $a1		# $a2 * ancho + $a1
    	addiu	$a0, $a0, 8		# $a0 ← dirección del array data
    	addu	$v0, $a0, $t1		# $v0 = $a0 + $a2 * ancho + $a1
    	jr	$ra

imagen_get_pixel:			# ($a0, $a1, $a2) = (img, x, y)
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)		# guardamos $ra porque haremos un jal
	jal	imagen_pixel_addr	# (img, x, y) ya en ($a0, $a1, $a2)
	lbu	$v0, 0($v0)		# lee el pixel a devolver
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

imagen_set_pixel:			# ($a0, $a1, $a2, $a3) = (img, x, y, color)
	add	$sp, $sp, -8
	sw	$s0, 0($sp)
	sw	$ra, 4($sp)
	move	$s0, $a3
	jal	imagen_pixel_addr	# Se obtiene la dirección del pixel a modificar. ($a0, $a1, $a2) = (img, x, y)
	sb	$s0, 0($v0)		# Se modifica el pixel
	lw	$s0, 0($sp)
	lw	$ra, 4($sp)
	add	$sp, $sp, 8
	jr      $ra

imagen_clean:				#($a0, $a1) = (img, fondo)
	add	$sp, $sp, -20
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	sw	$s2, 12($sp)
	sw	$s3, 16($sp)
	move	$s0, $a0
	move	$s1, $a1
	li	$s2, 0			#variable y del primer for
for_0:	lw	$t0, 4($s0)
	bge	$s2, $t0, fin
	li	$s3, 0			#variable x del segundo for
for_1:	lw	$t1, 0($s0)
	bge	$s3, $t1, fin_for_1
	move	$a0, $s0
	move	$a1, $s3
	move	$a2, $s2
	move	$a3, $s1
	jal	imagen_set_pixel	#ponemos el pixel al valor correspondiente. ($a0, $a1, $a2) = (img, x, y, fondo)
	add	$s3, $s3, 1		#actualizamos la x
	j	for_1
fin_for_1: add	$s2, $s2, 1		#actualizamos la y
	j 	for_0
fin:	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	lw	$s2, 12($sp)
	lw	$s3, 16($sp)
	add	$sp, $sp, 20
	jr	$ra
        
imagen_init:			#($a0, $a1, $a2, $a3) = (img, ancho, alto, fondo)
	add	$sp, $sp, -4
	sw	$ra, 0($sp)
	sw	$a1, 0($a0)
	sw	$a2, 4($a0)
	move	$a1, $a3
	jal	imagen_clean	#inicializa la imagen a el valor fondo. ($a0, $a1) = (img, fondo)
	lw	$ra, 0($sp)
	add	$sp, $sp, 4
	jr	$ra
	
	

imagen_copy:			#($a0, $a1) = (dst, src)
	add	$sp, $sp, -20
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	sw	$s2, 12($sp)
	sw	$s3, 16($sp)
	lw	$t0, 0($a1)	# dst->ancho = src->ancho;     dst->alto = src->alto;
	lw	$t1, 4($a1)
	sw	$t0, 0($a0)
	sw	$t1, 4($a0)
	move	$s2, $a1
	move	$s3, $a0
	li	$s0, 0		# variable y del primer for
for0_copy: lw	$t1, 4($s2)
	bge	$s0, $t1, fin_copy
	li	$s1, 0		#variable x del segundo for
for1_copy: lw	$t0, 0($s2)
	bge	$s1, $t0, finfor1_copy
	move	$a0, $s2
	move	$a1, $s1
	move	$a2, $s0
	jal	imagen_get_pixel	#obtiene el pixel correspondiente de src. ($a0, $a1, $a2) = (src, x, y)
	move	$a3, $v0
	move	$a1, $s1
	move	$a2, $s0
	move	$a0, $s3
	jal	imagen_set_pixel	#Pone el pixel de dst igual que el obtenido de src- ($a0, $a1, $a2, $a3) = (dst, x, y, p). p es el pixel obtenido de src.
	add	$s1, $s1, 1		#actualizamos la x
	j	for1_copy
finfor1_copy:
	add	$s0, $s0, 1		#actualizamos la y
	j	for0_copy
fin_copy: 
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	lw	$s2, 12($sp)
	lw	$s3, 16($sp)
	add	$sp, $sp, 20
	jr	$ra
	
imagen_print:				# $a0 = img
	addiu	$sp, $sp, -24
	sw	$ra, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	move	$s0, $a0
	lw	$s3, 4($s0)		# img->alto
	lw	$s4, 0($s0)		# img->ancho
        #  for (int y = 0; y < img->alto; ++y)
	li	$s1, 0			# y = 0
B6_2:	bgeu	$s1, $s3, B6_5		# acaba si y ≥ img->alto
	#    for (int x = 0; x < img->ancho; ++x)
	li	$s2, 0			# x = 0
B6_3:	bgeu	$s2, $s4, B6_4		# acaba si x ≥ img->ancho
	move	$a0, $s0		# Pixel p = imagen_get_pixel(img, x, y)
	move	$a1, $s2
	move	$a2, $s1
	jal	imagen_get_pixel
	move	$a0, $v0		# print_character(p)
	jal	print_character
	addiu	$s2, $s2, 1		# ++x
	j	B6_3
	#    } // for x
B6_4:	li	$a0, 10			# print_character('\n')
	jal	print_character
	addiu	$s1, $s1, 1		# ++y
	j	B6_2
	#  } // for y
B6_5:	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$ra, 20($sp)
	addiu	$sp, $sp, 24
	jr	$ra

imagen_dibuja_imagen:			#($a0, $a1, $a2, $a3) = (dst, src, dst_x, dst_y)
	add	$sp, $sp, -36
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	sw	$s2, 12($sp)
	sw	$s3, 16($sp)
	sw	$s4, 20($sp)
	sw	$s5, 24($sp)
	sw	$s6, 28($sp)
	sw	$s7, 32($sp)
	move	$s0, $a0
	move	$s1, $a1
	move	$s2, $a2
	move	$s3, $a3
	li	$s4, 0			#variable y del primer for
	lw	$s5, 4($s1)
for0_dib: bge	$s4, $s5, finfor0_dib
	li	$s6, 0			#variable x del segundo for
	lw	$s7, 0($s1)
for1_dib: bge	$s6, $s7, finfor1_dib
	move	$a0, $s1
	move	$a1, $s6
	move	$a2, $s4
	jal	imagen_get_pixel	#obtiene el pixel correspondiente de src. ($a0, $a1, $a2) = (src, x, y)
	beqz	$v0, sinif_dib		#comprobacion del if
	move	$a0, $s0
	add	$a1, $s2, $s6
	add	$a2, $s3, $s4
	move	$a3, $v0
	jal	imagen_set_pixel	#pone el pixel obtenido de src en dst. ($a0, $a1, $a2, $a3) = (dst, dst_x+x, dst_y+y, p). p es el pixel obtenido de src
sinif_dib: add	$s6, $s6, 1		#actualizar la x
	j	for1_dib
finfor1_dib: add $s4, $s4, 1		#actualizar la y
	j	for0_dib
finfor0_dib: lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	lw	$s2, 12($sp)
	lw	$s3, 16($sp)
	lw	$s4, 20($sp)
	lw	$s5, 24($sp)
	lw	$s6, 28($sp)
	lw	$s7, 32($sp)
	add	$sp, $sp, 36
	jr	$ra

imagen_dibuja_imagen_rotada:		#($a0, $a1, $a2, $a3) = (dst, src, dst_x, dst_y)
	add	$sp, $sp, -36
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	sw	$s2, 12($sp)
	sw	$s3, 16($sp)
	sw	$s4, 20($sp)
	sw	$s5, 24($sp)
	sw	$s6, 28($sp)
	sw	$s7, 32($sp)
	move	$s0, $a0
	move	$s1, $a1
	move	$s2, $a2
	move	$s3, $a3
	li	$s4, 0			#variable y del primer for
	lw	$s5, 4($s1)
for0_dibrot: bge	$s4, $s5, finfor0_dibrot
	li	$s6, 0			#variale x del segundo for
	lw	$s7, 0($s1)
for1_dibrot: bge	$s6, $s7, finfor1_dibrot
	move	$a0, $s1
	move	$a1, $s6
	move	$a2, $s4
	jal	imagen_get_pixel	#obtiene el pixel correspondiente de src. ($a0, $a1, $a2) = (src, x, y)
	beqz	$v0, sinif_dibrot	#comprobacion del if
	move	$a0, $s0
	add	$a1, $s2, $s5
	add	$t0, $s4, 1
	sub	$a1, $a1, $t0
	add	$a2, $s3, $s6
	move	$a3, $v0
	jal	imagen_set_pixel	#pone el pixel obtenido de src en dst de manera que se rote la imagen. ($a0, $a1, $a2, $a3) = (dst, dst_x+src->alto - 1 - y, dst_y + x, p)). p es el pixel obtenido de src
sinif_dibrot: add	$s6, $s6, 1	#actualizar la x
	j	for1_dibrot
finfor1_dibrot: add $s4, $s4, 1		#actualizar la y
	j	for0_dibrot
finfor0_dibrot: lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	lw	$s2, 12($sp)
	lw	$s3, 16($sp)
	lw	$s4, 20($sp)
	lw	$s5, 24($sp)
	lw	$s6, 28($sp)
	lw	$s7, 32($sp)
	add	$sp, $sp, 36
	jr	$ra

pieza_aleatoria:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	li	$a0, 0
	li	$a1, 7
	jal	random_int_range	# $v0 ← random_int_range(0, 7)
	sll	$t1, $v0, 2
	la	$v0, piezas
	addu	$t1, $v0, $t1		# $t1 = piezas + $v0*4
	lw	$v0, 0($t1)		# $v0 ← piezas[$v0]
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

actualizar_pantalla:
	addiu	$sp, $sp, -16
	sw	$ra, 12($sp)
	sw	$s0, 8($sp)
	sw	$s2, 4($sp)
	sw	$s1, 0($sp)
	la	$s2, campo
	la	$a0, pantalla
	li	$a1, ' '
	jal	imagen_clean		# imagen_clean(pantalla, ' ')
        # for (int y = 0; y < campo->alto; ++y) {
	li	$s1, 0			# y = 0
B10_2:	lw	$t1, 4($s2)		# campo->alto
	bge	$s1, $t1, B10_3		# sigue si y < campo->alto
	la	$a0, pantalla
	li	$a1, 0                  # pos_campo_x - 1
	addi	$a2, $s1, 2             # y + pos_campo_y
	li	$a3, '|'
	jal	imagen_set_pixel	# imagen_set_pixel(pantalla, 0, y, '|')
	la	$a0, pantalla
	lw	$t1, 0($s2)		# campo->ancho
	addiu	$a1, $t1, 1		# campo->ancho + 1
	addiu	$a2, $s1, 2             # y + pos_campo_y
	li	$a3, '|'
	jal	imagen_set_pixel	# imagen_set_pixel(pantalla, campo->ancho + 1, y, '|')
        addiu	$s1, $s1, 1		# ++y
        j       B10_2
        # } // for y
	# for (int x = 0; x < campo->ancho + 2; ++x) { 
B10_3:	li	$s1, 0			# x = 0
B10_5:  lw	$t1, 0($s2)		# campo->ancho
        addiu   $t1, $t1, 2             # campo->ancho + 2
        bge	$s1, $t1, B10_10	# sigue si x < campo->ancho + 2
	la	$a0, pantalla
	move	$a1, $s1                # pos_campo_x - 1 + x
        lw	$t1, 4($s2)		# campo->alto
	addiu	$a2, $t1, 2		# campo->alto + pos_campo_y
	li	$a3, '-'
	jal	imagen_set_pixel	# imagen_set_pixel(pantalla, x, campo->alto + 1, '-')
	addiu	$s1, $s1, 1		# ++x
	j       B10_5
        # } // for x
B10_10: li	$s0, 3			#inicializamos la y del bucle, para dibujar la caja de la siguiente pieza, a 3
B10_7:	li	$t0, 7			#la altura de la caja será 6 (7 - 3 = 4, que es igual a la altura sin "las tapas" de la caja)
	bge	$s0, $t0, B10_8
	la	$a0, pantalla
	li	$a1, 20			#el lado izquierdo de la caja estara en la coordenada 20
	move	$a2, $s0
	li	$a3, '|'
	jal	imagen_set_pixel	#imagen_set_pixel (pantalla, 20, y, '|')
	la	$a0, pantalla
	li	$a1, 24			#el lado derecho de la caja estara en la coordenada 24
	move	$a2, $s0
	li	$a3, '|'
	jal	imagen_set_pixel	#imagen_set_pixel (pantalla, 20, y, '|')
	addiu	$s0, $s0, 1		#actualizamos la variable y del bucle.
	j	B10_7
B10_8:	li	$s0, 20			#inicializamos la variable x del bucle, para dibujar la caja de la siguiente pieza, a 20
B10_9: 	li	$t0, 25			# la caja, de ancho, llegará hasta la coordenada 24
	bge	$s0, $t0, B10_6
	la	$a0, pantalla
	move	$a1, $s0
	li	$a2, 2			#la tapa de la caja tendrá coordenada y igual a 2
	li	$a3, '-'
	jal	imagen_set_pixel	#imagen_set_pixel (pantalla, x, 2, '-')
	la	$a0, pantalla
	move	$a1, $s0
	li	$a2, 7			#la base de la caja tendrá coordenada y igual a 7
	li	$a3, '-'
	jal	imagen_set_pixel	#imagen_set_pixel (pantalla, x, 7, '-')
	addiu	$s0, $s0, 1		#actualizamos la variable del bucle
	j	B10_9
B10_6:	la	$a0, pantalla
	move	$a1, $s2
	li	$a2, 1                  # pos_campo_x
	li	$a3, 2                  # pos_campo_y
	jal	imagen_dibuja_imagen	# imagen_dibuja_imagen(pantalla, campo, 1, 2)
	la	$a0, pantalla
	la	$a1, pieza_actual
	lw	$t1, pieza_actual_x
	addiu	$a2, $t1, 1		# pieza_actual_x + pos_campo_x
	lw	$t1, pieza_actual_y
	addiu	$a3, $t1, 2		# pieza_actual_y + pos_campo_y
	jal	imagen_dibuja_imagen	# imagen_dibuja_imagen(pantalla, pieza_actual, pieza_actual_x + pos_campo_x, pieza_actual_y + pos_campo_y)
	la	$a0, pantalla
	la	$a1, pieza_siguiente
	li	$a2, 21
	li	$a3, 3
	jal	imagen_dibuja_imagen	#dibujamos la pieza siguiente en la coordenadas (21,3), dentro de la caja. imagen_dibuja_imagen (pantalla, pieza_siguiente, 21, 3) 
	la	$a0, pantalla
	li	$a1, 0			#coordenada x cadena de texto
	li	$a2, 0			#coordenada y cadena de texto
	la	$a3, str003		#dirección de la cadena a dibujar
	jal	imagen_dibuja_cadena
	la	$t0, marcador
	lw	$a0, 0($t0)
	li	$a1, 10
	la	$a2, puntuacion
	jal	integer_to_string
	la	$a0, pantalla
	li	$a1, 12			
	li	$a2, 0		
	la	$a3, puntuacion		
	jal	imagen_dibuja_cadena
	la	$a0, pantalla
	li	$a1, 15			#coordenada x de la cadena del nivel
	li	$a2, 0			#coordenada y de la cadena del nivel
	la	$a3, str004		#str004 es la cadena a dibujar para el nivel
	jal	imagen_dibuja_cadena
	lw	$a0, nivel		#cargamos el valor de nivel
	li	$a1, 10
	la	$a2, textonivel
	jal	integer_to_string	#convertimos el nivel en cadena en el buffer textonivel
	la	$a0, pantalla
	li	$a1, 21
	li	$a2, 0
	la	$a3, textonivel
	jal	imagen_dibuja_cadena
	jal	clear_screen		# clear_screen()
	la	$a0, pantalla
	jal	imagen_print		# imagen_print(pantalla)
	lw	$s1, 0($sp)
	lw	$s2, 4($sp)
	lw	$s0, 8($sp)
	lw	$ra, 12($sp)
	addiu	$sp, $sp, 16
	jr	$ra

imagen_dibuja_cadena:				# $a0 = dirección imagen; $a1 = x; $a2 = y; $a3 = dirección cadena
	add	$sp, $sp, -24			
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	sw	$s2, 12($sp)
	sw	$s3, 16($sp)
	sw	$s4, 20($sp)
	move	$s0, $a0,
	move	$s1, $a1
	move	$s2, $a2
	move	$s3, $a3
	lw	$s4, 0($a0)			# $s4 = ancho de la imagen 
dib_cad_0: lb	$t0, 0($s3)			# $t0 = byte de la cadena apuntado por $s3
	beqz	$t0, dib_cad_1			# saltamos si $t0 es la marca de fin
	move	$a0, $s0
	move	$a1, $s1
	move	$a2, $s2
	move	$a3, $t0
	jal	imagen_set_pixel		# imagen_set_pixel ($s0, $s1, $s2)
	add	$s1, $s1, 1			# aumentamos en 1 la coordenada x
	add	$s3, $s3, 1			# aumentamos en 1 $s3 para acceder al siguiente caracter de la cadena
	sub	$t1, $s1, $s4
	bgez	$t1, dib_cad_2			# comprobamos si x>= ancho de la imagen. Si es asi, hacemos un salto de linea
dib_cad_3: j	dib_cad_0
dib_cad_2:
	move	$s1, $zero			#realizamos el salto de linea
	add	$s2, $s2, 1
	j	dib_cad_3
dib_cad_1: lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	lw	$s2, 12($sp)
	lw	$s3, 16($sp)
	lw	$s4, 20($sp)
	add	$sp, $sp, 24
	jr	$ra
	
integer_to_string:			#($a0, $a1, $a2) = (n, base, buf)
	move    $t0, $a2	
	bnez	$a0, no_cero_v4
	add	$t1, $zero, '0'
	sb	$t1, 0($t0)
	add	$t0, $t0, 1
	sb	$zero, 0($t0)
	j	B0_10_v4
no_cero_v4:abs	$t1, $a0		
B0_3_v4:blez	$t1, B0_7_v4
	div	$t1, $a1		
	mflo	$t1			
	mfhi	$t2
	li	$t9, 10
	bge	$t2, $t9, mayor_10			
	addiu	$t2, $t2, '0'
	j	B0_4_v4
mayor_10:addiu	$t2, $t2, 55	
B0_4_v4: sb	$t2, 0($t0)	
	addiu	$t0, $t0, 1		
	j	B0_3_v4
B0_7_v4:li	$t4, 0
	add	$t4, $t4, '-'
	bgt	$a0, $zero, positivo_v4
	sb	$t4, 0($t0)
	add	$t0, $t0, 1
positivo_v4: sb	$zero, 0($t0)
	sub	$t0, $t0, 1
	move	$t3, $a2
B0_8_v4:bge	$t3, $t0, B0_10_v4
	lb	$t4, 0($t3)
	lb	$t5, 0($t0)
	sb	$t4, 0($t0)
	sb	$t5, 0($t3)
	add	$t3, $t3, 1
	sub	$t0, $t0, 1
	j	B0_8_v4
B0_10_v4:	jr	$ra


nueva_pieza_actual:			#no recibe parametros
	add	$sp, $sp, -8
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	la	$a0, pieza_actual
	la	$a1, pieza_siguiente
	jal	imagen_copy		#ponemos en pieza actual la pieza siguiente.
	jal	pieza_aleatoria		#llamamos a pieza_aleatoria que no recibe parametros
	move	$s0, $v0
	move	$a0, $s0
	li	$a1, 8
	li	$a2, 0
	jal	probar_pieza		# vemos si se puede colocar la pieza en el campo. ($a0, $a1, $a2) = (direccion pieza aleatoria, 8, 0)
	beqz	$v0, no_nueva_pieza
	la	$a0, pieza_siguiente	
	move	$a1, $s0
	jal	imagen_copy		#copiamos la pieza aleatoria en la pieza siguiente. ($a0, $a1) = (pieza_siguiente, direccion pieza aleatoria)
	la	$t0, pieza_actual_x
	li	$t1, 8
	sw	$t1, 0($t0)		# se pone pieza_actual_x a 8
	la	$t0, pieza_actual_y
	sw	$zero, 0($t0)		# se pone pieza_actual_y a 0
	j	fin_nueva_pieza
no_nueva_pieza:	la	$t0, acabar_partida
	li	$t1, 1
	sb	$t1, 0($t0)			#ponemos a 1 la variable acabar_partida
	la	$t0, acabar_partida_campo_lleno
	sb	$t1, 0($t0)			#ponemos a 1 la variable acabar_partida_campo_lleno
fin_nueva_pieza:
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	add	$sp, $sp, 8
	jr	$ra

probar_pieza:				# ($a0, $a1, $a2) = (pieza, x, y)
	addiu	$sp, $sp, -32
	sw	$ra, 28($sp)
	sw	$s7, 24($sp)
	sw	$s6, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	move	$s0, $a2		# y
	move	$s1, $a1		# x
	move	$s2, $a0		# pieza
	li	$v0, 0
	bltz	$s1, B12_13		# if (x < 0) return false
	lw	$t1, 0($s2)		# pieza->ancho
	addu	$t1, $s1, $t1		# x + pieza->ancho
	la	$s4, campo
	lw	$v1, 0($s4)		# campo->ancho
	bltu	$v1, $t1, B12_13	# if (x + pieza->ancho > campo->ancho) return false
	bltz	$s0, B12_13		# if (y < 0) return false
	lw	$t1, 4($s2)		# pieza->alto
	addu	$t1, $s0, $t1		# y + pieza->alto
	lw	$v1, 4($s4)		# campo->alto
	bltu	$v1, $t1, B12_13	# if (campo->alto < y + pieza->alto) return false
	# for (int i = 0; i < pieza->ancho; ++i) {
	lw	$t1, 0($s2)		# pieza->ancho
	beqz	$t1, B12_12
	li	$s3, 0			# i = 0
	#   for (int j = 0; j < pieza->alto; ++j) {
	lw	$s7, 4($s2)		# pieza->alto
B12_6:	beqz	$s7, B12_11
	li	$s6, 0			# j = 0
B12_8:	move	$a0, $s2
	move	$a1, $s3
	move	$a2, $s6
	jal	imagen_get_pixel	# imagen_get_pixel(pieza, i, j)
	beqz	$v0, B12_10		# if (imagen_get_pixel(pieza, i, j) == PIXEL_VACIO) sigue
	move	$a0, $s4
	addu	$a1, $s1, $s3		# x + i
	addu	$a2, $s0, $s6		# y + j
	jal	imagen_get_pixel
	move	$t1, $v0		# imagen_get_pixel(campo, x + i, y + j)
	li	$v0, 0
	bnez	$t1, B12_13		# if (imagen_get_pixel(campo, x + i, y + j) != PIXEL_VACIO) return false
B12_10:	addiu	$s6, $s6, 1		# ++j
	bltu	$s6, $s7, B12_8		# sigue si j < pieza->alto
        #   } // for j
B12_11:	lw	$t1, 0($s2)		# pieza->ancho
	addiu	$s3, $s3, 1		# ++i
	bltu	$s3, $t1, B12_6 	# sigue si i < pieza->ancho
        # } // for i
B12_12:	li	$v0, 1			# return true
B12_13:	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$s6, 20($sp)
	lw	$s7, 24($sp)
	lw	$ra, 28($sp)
	addiu	$sp, $sp, 32
	jr	$ra

intentar_movimiento:			#($a0, $a1) = (x, y)
    	addiu 	$sp, $sp, -12
 	sw    	$ra, 0($sp)
 	sw	$s0, 4($sp)
 	sw	$s1, 8($sp)
 	move	$s0, $a0
 	move	$s1, $a1
    	la    	$a0, pieza_actual
    	move	$a1, $s0
    	move	$a2, $s1
  	jal   	probar_pieza		# sec comprueba que se puede poner la pieza en las coordenadas (x,y). ($a0, $a1, $a2) = (pieza_actual, x, y)
    	beqz    $v0, sinif_int_mov	#comprobacion del if,con el resultado de la llamada a probar_pieza
	la   	$t0, pieza_actual_x
    	la    	$t1, pieza_actual_y
    	sw    	$s0, 0($t0)		#pone pieza_actual_x a x
    	sw    	$s1, 0($t1)		#pone pieza_actual_y a y
    	li    	$v0, 1			#devuelve true.
    	j	fin_int_mov
sinif_int_mov:  
	li	$v0, 0			#devuelve false
fin_int_mov:	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	add	$sp, $sp, 12
	jr    	$ra


comprobar_linea_llena:			#($a0) = (y)
	add	$sp, $sp, -12
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	move	$s0, $a0		#$s0 es la y
	li	$s1, 0			#variable x del for
for_llena: la	$t0, campo
	lw	$t1, 0($t0)		#cargamos campo->ancho para la comprobación
	bge	$s1, $t1, fin_for_llena
	move	$a0, $t0
	move	$a1, $s1
	move	$a2, $s0
	jal	imagen_get_pixel	#comprobamos si el pixel de las coordenadas correspondientes es PIXEL_VACIO. ($a0, $a1, $a2) = (campo, x, y)
	bnez	$v0, no_if_llena
	li	$v0, 0			#si es vacio, se devuelve false y se acaba la funcion
	j	fin_llena
no_if_llena: add	$s1, $s1, 1	# actualizamos la x del for
	j	for_llena
fin_for_llena:	
	li	$v0, 1			# si se sale del for, se duelve true.
fin_llena:	
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	add	$sp, $sp, 12
	jr	$ra
	

eliminar_linea:				# ($a0) = y
	add	$sp, $sp, -12
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	move	$s0, $a0		# $s0 es la variable y del primer bucle for. La inicializamos a y.
for_elim0: 
	blez	$s0, fin_for_elim0
	li	$s1, 0			# $s1 es la variable x del segundo for. La inicializamos a 0.
for_elim1: 
	la	$t0, campo
	lw	$t1, 0($t0)
	bge	$s1, $t1, fin_for_elim1	#hacemos la comparacion de x con el ancho del campo.
	move	$a0, $t0
	move	$a1, $s1
	add	$a2, $s0, -1
	jal	imagen_get_pixel	#obtenemos el pixel de la fila superior. ($a0, $a1, $a2) = (campo, x, y-1)
	la	$a0, campo
	move	$a1, $s1
	move	$a2, $s0
	move	$a3, $v0
	jal	imagen_set_pixel	# ponemos el pixel correspondiente igual que el de la fila superior
	add	$s1, $s1, 1		# actualizamos la x
	j	for_elim1
fin_for_elim1: 
	add	$s0, $s0, -1	#actualizamos la y
	j	for_elim0
fin_for_elim0:  
	li	$s1, 0		# usamos $s1 como variable x de otro for
for_elim2:	
	la 	$t0, campo
	lw	$t1, 0($t0)
	bge	$s1, $t1, fin_elim	#comprobamos que x es menor que el ancho
	la	$a0, campo
	move	$a1, $s1
	move	$a2, $zero
	move	$a3, $zero
	jal	imagen_set_pixel	#ponemos a 0 los pixeles de la primera fila
	add	$s1, $s1, 1		#actualizamos la x
	j	for_elim2
fin_elim:
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	add	$sp, $sp, 12
	jr	$ra
	
	
bajar_pieza_actual:			# no recibe parametros
   	addiu   $sp, $sp, -12
    	sw	$ra, 0($sp)
    	sw	$s0, 4($sp)
    	sw	$s1, 8($sp)
    	lw      $s0, pieza_actual_x
    	lw    	$s1, pieza_actual_y
    	addiu   $t0, $s1, 1
    	move    $a0, $s0
    	move    $a1, $t0
    	jal    	intentar_movimiento	# intenta el movimiento de bajar la pieza. #($a0, $a1) = (pieza_actual_x, pieza_actual_y + 1)
if2:    bnez    $v0, sinoif		#si intentar_movimiento devuelve 0, se hace el if. Si no, saltamos y acabamos el procedimiento
    	la    	$a0, campo
    	la    	$a1, pieza_actual
    	move  	$a2, $s0
    	move   	$a3, $s1
    	jal    	imagen_dibuja_imagen	#dibuja la pieza_actual "anclada" al campo. ($a0, $a1, $a2, $a3) = (campo, pieza_actual, pieza_actual_x, pieza_actual_y)
for_baja: 
	la	$t0, pieza_actual
	lw	$t1, 4($t0)
	lw	$t3, pieza_actual_y
	add	$t2, $t3, $t1
	bge	$s1, $t2, fin_for_baja	#la  variable y del for es el $s1 que ya estaba inicializado a pieza_actual_y
	move	$a0, $s1
	jal	comprobar_linea_llena	#comprobamos si la linea nº $s1 se ha completado
	beqz	$v0, no_if_baja		# si está llena, añadimos 10 puntos
	la	$t0, marcador		
	lw	$t1, 0($t0)
	add	$t1, $t1, 10
	sw	$t1, 0($t0)
	move	$a0, $s1
	jal	eliminar_linea
no_if_baja: 
	add	$s1, $s1, 1
	j	for_baja
fin_for_baja:
    	jal    	nueva_pieza_actual	#crea una nueva pieza
    	la	$t0, marcador		#actualizamos el marcador, sumando 1 al valor que tenía.
    	lw	$t1, 0($t0)
    	add	$t1, $t1, 1
    	sw	$t1, 0($t0)
    	lw	$t0, marcador
    	div	$t0, $t0, 20
    	sw	$t0, nivel		#actualizamos el nivel
sinoif: lw    	$ra, 0($sp)
	lw	$s0, 4($sp)
    	lw	$s1, 8($sp)
    	add    	$sp, $sp, 12
    	jr	$ra


intentar_rotar_pieza_actual:	#no recibe parametros 
	add	$sp, $sp, -4
	sw	$ra, 0($sp)
	la 	$a0, imagen_auxiliar
	la	$t0, pieza_actual
	lw	$a2, 0($t0)
	lw	$a1, 4($t0)
	move	$a3, $zero
	jal	imagen_init		#inicializa a 0 imagen_auxiliar. #($a0, $a1, $a2, $a3) = (imagen_auxiliar, pieza_actual->alto, pieza_actual->ancho, 0)
	la	$a0, imagen_auxiliar
	la	$a1, pieza_actual
	move	$a2, $zero
	move	$a3, $zero
	jal	imagen_dibuja_imagen_rotada	#dibuja la pieza_actual en imagen_auxiliar rotandola. ($a0, $a1, $a2, $a3) = (imagen_auxiliar, pieza_actual, 0, 0)
	la	$a0, imagen_auxiliar
	lw	$a1, pieza_actual_x
	lw	$a2, pieza_actual_y
	jal	probar_pieza			#prueba a poner la pieza rotada en las coordenadas de pieza_actual. #($a0, $a1, $a2) = (imagen_auxiliar, pieza_actual_x, pieza_actual_y)		
	beqz	$v0, sinif_int_rot		#si puede colocarla, la copia y si no puede, termina la funcion
	la	$a0, pieza_actual
	la	$a1, imagen_auxiliar
	jal	imagen_copy			#copia la pieza rotada (imagen_auxiliar) en pieza_actual. ($a0, $a1) = (pieza_actual, imagen_auxiliar)
sinif_int_rot:	lw	$ra, 0($sp)
	add	$sp, $sp, 4
	jr	$ra
	

tecla_salir:
	li	$v0, 1
	sb	$v0, acabar_partida	# acabar_partida = true
	jr	$ra

tecla_izquierda:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	lw	$a1, pieza_actual_y
	lw	$t1, pieza_actual_x
	addiu	$a0, $t1, -1
	jal	intentar_movimiento	# intentar_movimiento(pieza_actual_x - 1, pieza_actual_y)
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

tecla_derecha:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	lw	$a1, pieza_actual_y
	lw	$t1, pieza_actual_x
	addiu	$a0, $t1, 1
	jal	intentar_movimiento	# intentar_movimiento(pieza_actual_x + 1, pieza_actual_y)
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

tecla_abajo:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	jal	bajar_pieza_actual	# bajar_pieza_actual()
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

tecla_rotar:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	jal	intentar_rotar_pieza_actual	# intentar_rotar_pieza_actual()
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

tecla_truco:
	addiu	$sp, $sp, -20
	sw	$ra, 16($sp)
	sw	$s4, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
       	li	$s4, 18
	#  for (int y = 13; y < 18; ++y) {         
	li	$s0, 13
	#  for (int x = 0; x < campo->ancho - 1; ++x) {
B21_1:	li	$s1, 0
B21_2:	lw	$t1, campo
	addiu	$t1, $t1, -1
	bge	$s1, $t1, B21_3
	la	$a0, campo
	move	$a1, $s1
	move	$a2, $s0
	li	$a3, '#'
	jal	imagen_set_pixel	# imagen_set_pixel(campo, x, y, '#'); 
	addiu	$s1, $s1, 1	# 245   for (int x = 0; x < campo->ancho - 1; ++x) { 
	j	B21_2
B21_3:	addiu	$s0, $s0, 1
	bne	$s0, $s4, B21_1
	la	$a0, campo
	li	$a1, 10
	li	$a2, 16
	li	$a3, 0
	jal	imagen_set_pixel	# imagen_set_pixel(campo, 10, 16, PIXEL_VACIO); 
	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s4, 12($sp)
	lw	$ra, 16($sp)
	addiu	$sp, $sp, 20
	jr	$ra

procesar_entrada:
	addiu	$sp, $sp, -20
	sw	$ra, 16($sp)
	sw	$s4, 12($sp)
	sw	$s3, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	jal	keyio_poll_key
	move	$s0, $v0		# int c = keyio_poll_key()
        # for (int i = 0; i < sizeof(opciones) / sizeof(opciones[0]); ++i) { 
	li	$s1, 0			# i = 0, $s1 = i * sizeof(opciones[0]) // = i * 8
	la	$s3, procesar_entrada.opciones	
	li	$s4, 48			# sizeof(opciones) // == 5 * sizeof(opciones[0]) == 5 * 8
B22_1:	addu	$t1, $s3, $s1		# procesar_entrada.opciones + i*8
	lb	$t2, 0($t1)		# opciones[i].tecla
	bne	$t2, $s0, B22_3		# if (opciones[i].tecla != c) siguiente iteración
	lw	$t2, 4($t1)		# opciones[i].accion
	jalr	$t2			# opciones[i].accion()
	jal	actualizar_pantalla	# actualizar_pantalla()
B22_3:	addiu	$s1, $s1, 8		# ++i, $s1 += 8
	bne	$s1, $s4, B22_1		# sigue si i*8 < sizeof(opciones)
        # } // for i
	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s3, 8($sp)
	lw	$s4, 12($sp)
	lw	$ra, 16($sp)
	addiu	$sp, $sp, 20
	jr	$ra

jugar_partida:
	addiu	$sp, $sp, -12	
	sw	$ra, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	la	$t0, marcador		#iniciallizamos a 0 el marcador
	sw	$zero, 0($t0)
	la	$a0, pantalla
	li	$a1, 25
	li	$a2, 22
	li	$a3, 32
	jal	imagen_init		# imagen_init(pantalla, 20, 22, ' ')
	la	$a0, campo
	li	$a1, 14
	li	$a2, 18
	li	$a3, 0
	jal	imagen_init		# imagen_init(campo, 14, 18, PIXEL_VACIO)
	jal	pieza_aleatoria
	la	$a0, pieza_siguiente
	move	$a1, $v0
	jal	imagen_copy
	jal	nueva_pieza_actual	# nueva_pieza_actual()
	sb	$zero, acabar_partida	# acabar_partida = false
	jal	get_time		# get_time()
	move	$s0, $v0		# Hora antes = get_time()
	jal	actualizar_pantalla	# actualizar_pantalla()
	j	B23_2
        # while (!acabar_partida) { 
B23_2:	lbu	$t1, acabar_partida
	bnez	$t1, B23_6		# if (acabar_partida != 0) sale del bucle
	jal	procesar_entrada	# procesar_entrada()
	jal	get_time		# get_time()
	move	$s1, $v0		# Hora ahora = get_time()
	subu	$t1, $s1, $s0		# int transcurrido = ahora - antes
	lw	$t0, pausa
	ble	$t1, $t0, B23_2		# if (transcurrido < pausa) siguiente iteración
B23_1:	jal	bajar_pieza_actual	# bajar_pieza_actual()
	jal	actualizar_pantalla	# actualizar_pantalla()
	move	$s0, $s1		# antes = ahora
	lw	$t0, nivel
	li	$t1, 50
	mul	$t0, $t0, $t1
	li	$t1, 1000
	sub	$t0, $t1, $t0
	sw	$t0, pausa
        j	B23_2			# siguiente iteración
       	# } 
B23_6:  la	$t0, acabar_partida_campo_lleno
       	lb	$t1, 0($t0)
       	beqz	$t1, B23_5			# if (acabar_partida_campo_lleno == 0) se acaba la funcion
       	la	$a0, pantalla
       	la	$a1, imagen_game_over
       	li	$a2, 1
       	li	$a3, 8
       	jal	imagen_dibuja_imagen		#dibuja en pantalla el texto de game over. ($a0, $a1, $a2, $a3) = (pantalla, imagen_game_over, 1, 8)
       	jal	clear_screen			#clear screen no recibe parametros
       	la	$a0, pantalla
       	jal	imagen_print			#imprime la imagen. ($a0) = (pantalla)
       	jal	read_character			#espera a que se pulse una tecla. No recibe parametros.
B23_5:	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$ra, 8($sp)
	addiu	$sp, $sp, 12
	jr	$ra

	.globl	main
main:					# ($a0, $a1) = (argc, argv) 
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
B24_2:	jal	clear_screen		# clear_screen()
	la	$a0, str000
	jal	print_string		# print_string("Tetris\n\n 1 - Jugar\n 2 - Salir\n\nElige una opción:\n")
	jal	read_character		# char opc = read_character()
	beq	$v0, '2', B24_1		# if (opc == '2') salir
	bne	$v0, '1', B24_5		# if (opc != '1') mostrar error
	jal	jugar_partida		# jugar_partida()
	j	B24_2
B24_1:	la	$a0, str001
	jal	print_string		# print_string("\n¡Adiós!\n")
	li	$a0, 0
	jal	mips_exit		# mips_exit(0)
	j	B24_2
B24_5:	la	$a0, str002
	jal	print_string		# print_string("\nOpción incorrecta. Pulse cualquier tecla para seguir.\n")
	jal	read_character		# read_character()
	j	B24_2
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra


#
# Funciones de la librería del sistema
#

print_character:
	li	$v0, 11
	syscall	
	jr	$ra

print_string:
	li	$v0, 4
	syscall	
	jr	$ra

get_time:
	li	$v0, 30
	syscall	
	move	$v0, $a0
	move	$v1, $a1
	jr	$ra

read_character:
	li	$v0, 12
	syscall	
	jr	$ra

clear_screen:
	li	$v0, 39
	syscall	
	jr	$ra

mips_exit:
	li	$v0, 17
	syscall	
	jr	$ra

random_int_range:
	li	$v0, 42
	syscall	
	move	$v0, $a0
	jr	$ra

keyio_poll_key:
	li	$v0, 0
	lb	$t0, 0xffff0000
	andi	$t0, $t0, 1
	beqz	$t0, keyio_poll_key_return
	lb	$v0, 0xffff0004
keyio_poll_key_return:
	jr	$ra
