# 1. LECTURA DE FICHEROS

# Establecemos el working directory

ruta_directorio_trabajo = "C:\\Users\\LENOVO\\Dropbox\\Máster-D BigData\\Ciencia de Datos-UNIDAD_2_Introducción a R y RStudio\\ejercicios_practicos\\ejercicio_3\\nuestra solución"

setwd (ruta_directorio_trabajo)



# Leemos el consumo de electricidad del cliente
consumo=read.delim("consumo_horario_cliente.csv", sep=";")



# 2. FECHAS

# Casteamos la columna a datetime

consumo$datetime  = as.POSIXct(consumo$datetime)


# 3. CALCULO DE VARIABLES DERIVADAS


# Añadimos la columna coste_eur que representa el coste en euros por horas

consumo = transform(consumo, coste_eur = consumo_kwh * precio_kwh)


# Añadimos la columna fecha de tipo Date 

consumo = transform(consumo, fecha = as.Date (datetime))


# Añadimos la columna hora

consumo = transform (consumo, hora = format.POSIXct(datetime, format= "%H"))


# Añadimos la columna mes

consumo = transform (consumo, mes = format.POSIXct(datetime, format= "%m"))


# Añadimos la columna dia de la semana

consumo = transform (consumo, dia_semana = weekdays(datetime))


# 4. FILTRADO

# Miramos las 5 primeras filas

consumo [1:5, ]

# Miramos las 3 primeras filas y las dos primeras columnas

consumo [1:3, 1:2]

# Miramos las ultimas 5 filas del dataframe
# Para esto vemos cuantas tiene en total el dataframe

numero_filas_consumo = nrow(consumo)

consumo[(numero_filas_consumo -4) : numero_filas_consumo, ]

# Filtamos los consumos del 31 de diciembre de 2016

subset(consumo, fecha== "2016-12-31")

# Filtramos fecha-hora del mayor consumo.

subset(consumo, consumo_kwh == max(consumo_kwh))

# ¿Coincide con el mayor coste? No, no coincide el mayor consumo con el mayor precio del kwh

subset (consumo, precio_kwh == max(precio_kwh))

# Filtramos el menos consumo

subset (consumo, consumo_kwh == min(consumo_kwh))

# Consumos por debajo de 20 kwh (0.02 kwh)

subset (consumo, consumo_kwh < 0.02)

# Calculamos el valor medio del consumo y del coste los martes y los viernes
# Filtramos los valores de martes y viernes

martes_o_viernes = subset (consumo, dia_semana == "martes" | dia_semana == "viernes" )

aggregate(martes_o_viernes$consumo_kwh, list(martes_o_viernes$dia_semana), mean)

aggregate(martes_o_viernes$precio_kwh, list(martes_o_viernes$dia_semana), mean)


# 5. REETIQUETADO DE VARIABLES

# Convertimos la variable dia_semana a un factor y especificamos los niveles de forma explicita, 
# usando el orden de la semana y no el orden alfabetico

levels =c("lunes", "martes", "miércoles", "jueves", "viernes", "sábado", "domingo")

# Creamos una columna wd con los dias de la semana estandarizados

consumo = transform (consumo, wd = factor(dia_semana, levels))

# Cambiamos los nombres a los niveles, cambiándolos a la letra inicial: L,M,X,J,V,S,D

levels (consumo$wd) = c ("L", "M", "X", "J", "V", "S", "D")



# 6. AGREGACION

# Consumo y coste total por mes. ¿Es el mes de mayor consumo el de mayor coste?

aggregate (consumo$consumo_kwh, list(consumo$mes), sum)
aggregate (consumo$precio_kwh, list (consumo$mes), sum)


# 7. UNION DE DATA FRAMES

# Leemos el archivo precio_md.csv que tiene los precios del mercado mayorista.

mercado_mayorista = read.delim ("precio_md.csv", sep=";")

# Calculamos las diferencias entre el precio minorista, el que paga el consumidor, 
# respecto al precio del mercado mayorista y calcula las diferencias medias mensuales


# Primero pasamos de Mw a Kw. Para eso dividimos entre mil.

mercado_mayorista = transform (mercado_mayorista, preciomd_eurKw = preciomd_eurMw / 1000)


# Pasamos la columna datetime a tiempo

mercado_mayorista$datetime  = as.POSIXct(mercado_mayorista$datetime)

# Juntamos los dos dataframes para ver la diferencia de precios entre mayorista y minorista

union = merge (mercado_mayorista, consumo, by= "datetime")

# Creamos una columna que muestre la diferencia de precio entre las columnas
# preciomd_eurKw - precio_kwh Calculamos la diferencia de precios

union=transform (union, diferencia_precios= precio_kwh - preciomd_eurKw)
 
# Calculamos las diferencias medias mensuales

aggregate(union$diferencia_precios, list (union$mes), mean)

