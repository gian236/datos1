Primero se usa el script de sql para crear las tablas que son iguales a los csv
Luego para cargar los datos, se copian los csv al contenedor con el siguiente comando
  docker cp <ruta_del_archivo_en_el_host> <nombre_del_contenedor>:<ruta_destino_en_el_contenedor>
  en mi caso fue docker cp "C:\Users\gianp\OneDrive\Escritorio\Semestre 4\Datos I\datos1\pagosdatos.csv" dockerexamples-db3-1:/tmp/pagosdatos
                            "C:\Users\gianp\OneDrive\Escritorio\Semestre 4\Datos I\datos1\prestamosdatos.csv" dockerexamples-db3-1:/tmp/pagosdatos
