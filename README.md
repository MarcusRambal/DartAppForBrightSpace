# DartAppForBrightSpace

# Propuesta de Aplicación – Evaluación de Trabajo Colaborativo

## Referentes Analizados

A continuación se presentan algunos referentes relacionados con la problemática de la evaluación de trabajos colaborativos:

- **FeedbackFruits**
- **Evaluación docente de la universidad**
- **Google Forms**

Estos referentes sirvieron como base para analizar funcionalidades, experiencia de usuario y gestión de evaluaciones.

---

## Composición y Diseño de la Solución

La solución estará compuesta por una **única aplicación móvil desarrollada en Flutter**, la cual será utilizada tanto por docentes como por estudiantes, diferenciando las funcionalidades mediante un **sistema de roles**.

### Funcionalidades de la interfaz del docente

La interfaz del docente contará con las siguientes funcionalidades:

- Crear cursos.
- Subir archivos `.csv` obtenidos desde BrightSpace.
- Crear y/o actualizar los grupos de la respectiva materia a partir de los archivos cargados.
- Crear las evaluaciones.
- Visualizar los resultados.
- Priorizar y resaltar los casos excepcionales en los resultados.

Ambas interfaces se conectarán a un **backend centralizado**, encargado de la gestión de datos, el control de permisos y el procesamiento de resultados.  
La autenticación se realizará mediante **Roble**, permitiendo identificar el rol del usuario y habilitar las funcionalidades correspondientes.

---

## Descripción del Flujo Funcional

### 1. Creación de los grupos
La creación de los grupos se realiza fuera de la aplicación, en Brightspace. Una vez todos los estudiantes se han inscrito en un grupo, el docente obtiene el archivo en formato Excel o CSV.

### 2. Subida del archivo Excel o CSV
El docente sube el archivo obtenido desde Brightspace a la plataforma (ya sea desde la aplicación o desde la web). Una vez realizado este proceso, los estudiantes que ya han iniciado sesión pueden visualizar su grupo dentro de la aplicación.

### 3. Creación de evaluaciones
El docente puede crear una o varias evaluaciones, permitiendo configurar si los resultados serán visibles de forma **pública** o **privada** para los compañeros del grupo.

### 4. Desarrollo del trabajo y evaluaciones intermedias
Durante el tiempo de realización del trabajo, si el docente lo requiere, los estudiantes podrán calificar a sus compañeros de manera opcional mediante evaluaciones intermedias de carácter semanal.  
En caso contrario, se realizará únicamente una evaluación al finalizar el trabajo.  
Estas evaluaciones siguen los mismos parámetros de la evaluación final.

### 5. Evaluación final
Al finalizar el trabajo colaborativo, se realiza una evaluación final. Tanto en esta etapa como en las evaluaciones intermedias, los estudiantes solo podrán realizar la evaluación **una única vez**.

### 6. Visualización de resultados
Luego de promediar los resultados según las indicaciones definidas, los resultados se mostrarán a los estudiantes dependiendo de si la evaluación fue configurada como pública o privada.

---

## Justificación de la Propuesta

Además de cumplir los requerimientos como el uso de Roble en el apartado de autenticación y base de datos, la decisión de usar una sola aplicación para ambos roles permite la reutilización de componentes, evita la duplicidad de código y reduce la complejidad en la gestión.

Por otro lado, la propuesta de utilizar una plataforma web para subir el archivo que contiene la información de los grupos se justifica por la comodidad del usuario, en este caso los docentes, ya que realizar este tipo de acciones desde una aplicación móvil suele ser más tosco y complejo en comparación con una página web.

Estas decisiones fueron reforzadas a partir de una reunión con la profesora **Rocío Ramos**, quien estuvo de acuerdo con la importancia de una plataforma de este tipo y consideró que una sola aplicación es suficiente para mantener todo centralizado y en orden. Además, destacó la importancia de la comodidad dentro de la aplicación, mencionando su experiencia con **FeedbackFruits**, herramienta que utilizó con el mismo propósito, pero que no cumplía todas sus expectativas y resultaba incómoda y enredada en algunos escenarios.

Por otro lado, los referentes no se tomaron a la ligera. **Google Forms** y la evaluación docente brindan una idea clara de cómo los estudiantes pueden visualizar preguntas y estadísticas, así como de qué manera el docente puede gestionar las preguntas y las respuestas obtenidas.  
Finalmente, **FeedbackFruits**, propuesto por la profesora Rocío Ramos, sirvió como referente para analizar qué ideas y conceptos podían ser adoptados, y cuáles debían descartarse o mejorarse en la propuesta.

---

## Prototipo y Material Visual

- 🔗 **Enlace al prototipo en Figma:**
  
  https://www.figma.com/design/wvI3QGm1XcHzfHarir4qow/Sin-t%C3%ADtulo?node-id=33-719&p=f
  
  https://www.figma.com/design/wvI3QGm1XcHzfHarir4qow/Sin-t%C3%ADtulo?node-id=0-1&t=8WbotOlhMCXbrt7C-1
  
- 📸 **Capturas de pantalla del prototipo:**
  <img width="1349" height="471" alt="image" src="https://github.com/user-attachments/assets/891c1ad3-82c7-45c6-a344-0baecaa39050" />
  <img width="891" height="468" alt="image" src="https://github.com/user-attachments/assets/9474ccda-967b-4d33-9b69-1b9bc56044d7" />
  <img width="1360" height="473" alt="image" src="https://github.com/user-attachments/assets/e15fc733-d64e-4755-bd2c-6cb3696a3181" />
  <img width="664" height="467" alt="image" src="https://github.com/user-attachments/assets/a10d7cef-004f-4886-aac1-ca3c96a0cf0e" />
  <img width="1241" height="421" alt="image" src="https://github.com/user-attachments/assets/c2e28b09-b405-489a-99af-fa8498b9ca7a" />
  <img width="1229" height="425" alt="image" src="https://github.com/user-attachments/assets/c7fad07e-1379-49c8-a582-6c88679ce256" />
  <img width="1225" height="416" alt="image" src="https://github.com/user-attachments/assets/dc9d1cac-9384-45d6-950c-a084bc6471bb" />
  <img width="616" height="424" alt="image" src="https://github.com/user-attachments/assets/b7b8a927-55db-48fb-b8b7-2dacc15cc212" />
