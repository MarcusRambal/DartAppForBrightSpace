
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

Adicionalmente, se implementará una **plataforma web de soporte exclusiva para el docente**, en la cual podrá cargar el archivo **Excel o CSV** exportado desde Brightspace para importar los grupos de manera más cómoda.

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

- 🔗 **Enlace al prototipo en Figma:** *(pendiente de agregar)*
- 📸 **Capturas de pantalla del prototipo:** *(pendiente de agregar)*

---

## Observaciones Finales

Esta propuesta busca facilitar la evaluación del trabajo colaborativo, centralizando la gestión en una sola aplicación, mejorando la experiencia de usuario tanto para docentes como para estudiantes, y apoyándose en referentes existentes y en la retroalimentación de profesores con experiencia en trabajos colaborativos.
