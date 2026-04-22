# DartAppForBrightSpace

# Propuesta de Aplicación – Evaluación de Trabajo Colaborativo

---

## Descripción de la aplicación / Proposito

DartAppForBrightSpace es una aplicación móvil desarrollada en Flutter cuyo propósito es facilitar la evaluación del trabajo colaborativo entre estudiantes dentro de cursos académicos.

La aplicación permite a docentes y estudiantes interactuar en una misma plataforma mediante un sistema de roles, centralizando la gestión de cursos, grupos y evaluaciones. Su objetivo principal es optimizar el proceso de evaluación entre pares, mejorar la transparencia en los resultados y facilitar la identificación de desempeños individuales dentro de actividades grupales.

## Alcance

La aplicación está enfocada en entornos educativos que utilizan Brightspace, integrando la gestión de grupos mediante archivos externos y centralizando la evaluación dentro de una sola plataforma móvil. No contempla la creación de grupos dentro del sistema, sino que se apoya en herramientas externas para este proceso.


### Justificación de la Arquitectura

**Clean Architecture:**
La aplicación se estructurará en tres capas principales: Datos, Dominio y Presentación. Esta separación permitirá mantener el código desacoplado, facilitando su mantenimiento, escalabilidad y pruebas futuras.

**GetX:**
Se utilizará este paquete para la gestión del estado de la aplicación, la navegación entre pantallas y la inyección de dependencias, permitiendo una implementación más organizada y eficiente.

**Centralización:**
Al utilizar una única aplicación para ambos roles, se simplifica la administración del sistema, la autenticación mediante Roble y el control de acceso a funcionalidades específicas según el tipo de usuario.

### Funcionalidades de la interfaz del docente

La interfaz del docente contará con las siguientes funcionalidades:

* Crear cursos.
* Subir archivos .csv obtenidos desde BrightSpace.
* Crear y/o actualizar los grupos de la respectiva materia a partir de los archivos cargados.
* Crear las evaluaciones.
* Visualizar los resultados.
* Priorizar y resaltar los casos excepcionales en los resultados.

### Funcionalidades de la interfaz del estudiante

La interfaz del estudiante contará con las siguientes funcionalidades:

* Ver cursos.
* Ver grupos.
* Realizar la evaluación de cada integrante del grupo cuando le corresponde.
* Ver el promedio obtenido en las evaluaciones.
* Visualizar los resultados propios si la evaluación lo permite.

Ambas interfaces se conectarán a un backend centralizado, encargado de la gestión de datos, el control de permisos y el procesamiento de resultados. La autenticación se realizará mediante Roble, permitiendo identificar el rol del usuario y habilitar las funcionalidades correspondientes.


---

## Descripción del Flujo Funcional

### 0. Registro y Roles
El usuario inicia sesión en la aplicación; el sistema identifica automáticamente si su rol es Profesor o Estudiante y habilita las funcionalidades correspondientes.

### 1. Creación de los grupos
La creación de los grupos se realiza fuera de la aplicación, en Brightspace. Una vez todos los estudiantes se han inscrito en un grupo, el docente obtiene el archivo en formato Excel o CSV.

### 2. Subida del archivo Excel o CSV
El docente sube el archivo obtenido desde Brightspace a la plataforma(ya todos los docentes estan inscritos en la base de datos de la plataforma), este archivo se sube a un curso que haya sido previamente creado dentro de la aplicación,. Una vez realizado este proceso, los estudiantes que ya han iniciado sesión pueden visualizar su grupo dentro de la aplicación.

### 3. Creación de evaluaciones
El docente puede crear una o varias evaluaciones, permitiendo configurar si los resultados serán visibles de forma **pública** o **privada** para los compañeros del grupo.

### 4. Desarrollo del trabajo y evaluaciones intermedias
Durante el tiempo de realización del trabajo, si el docente lo requiere, los estudiantes podrán calificar a sus compañeros de manera opcional mediante evaluaciones intermedias.  
En caso contrario, se realizará únicamente una evaluación al finalizar el trabajo.  
Estas evaluaciones siguen los mismos parámetros de la evaluación final.

### 5. Evaluación final
Al finalizar el trabajo colaborativo, se realiza una evaluación final. Tanto en esta etapa como en las evaluaciones intermedias, los estudiantes solo podrán realizar la evaluación **una única vez**.

### 6. Visualización de resultados
Luego de promediar los resultados según las indicaciones definidas, los resultados se mostrarán a los estudiantes dependiendo de si la evaluación fue configurada como pública o privada.

