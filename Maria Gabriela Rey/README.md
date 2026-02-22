#Propuesta de aplicación.  
Desarrollar una aplicación móvil en Flutter que permita evaluar el desempeño y compromiso de los integrantes de un grupo en actividades colaborativas. La aplicación tendrá dos roles (profesor y estudiante) y se apoyará en Roble para autenticación. Los grupos no se crean dentro de la app: se importan desde Brightspace.

---

**Referentes:**  
1. CATME (evaluación de pares – Purdue University)  
2. BuddyCheck  
3. Evaluación de docente (Universidad del Norte)

---

**Composición y diseño de la solución:**  
La decisión tomada es una sola aplicación diseñada en Flutter con dos roles (profesor y estudiante) habilitados desde la misma app, ya que esto reduce la duplicación de código, permite un flujo único de autenticación, simplifica el mantenimiento y las pruebas, y se alinea mejor con Clean Architecture por módulos.

La autenticación se realizará usando Roble como proveedor de identidad del curso, permitiendo identificar el rol del usuario y controlar el acceso a funcionalidades según corresponda.

Dado que los grupos no se crean en la app, se importan desde Brightspace mediante un archivo descargado por el profesor. La propuesta contempla soportar CSV como formato principal (por simplicidad y robustez) y Excel como alternativa (XLSX), ya sea cargándolo directamente o convirtiéndolo internamente a CSV para estandarizar el procesamiento.

---

**Descripción detallada del flujo funcional:**  

Flujo del profesor  
1. Inicia sesión (autenticación con Roble).  
2. Crea o administra uno o más cursos.  
3. Invita estudiantes al curso con invitación privada o verificable.  
4. Importa los grupos desde Brightspace mediante un archivo CSV (o XLSX).  
5. Crea una evaluación/tarea y la activa, configurando visibilidad de resultados como públicos o privados.  
6. Visualiza los resultados:  
   - Feedback de la actividad  
   - Notas/promedios por grupo  
   - Notas/promedios por cada estudiante del grupo  
7. Envía/publica la evaluación de la actividad al grupo (con criterios para que los estudiantes evalúen a cada uno de sus compañeros).

Flujo del estudiante  
1. Inicia sesión (Roble).  
2. Se une al curso (acepta invitación).  
3. Ve la actividad y la evaluación habilitada.  
4. Evalúa a sus compañeros y puede dar feedback general al profesor sobre cómo fue la actividad y cómo percibió el trabajo del grupo en general.  
5. Envía la evaluación.  
6. Revisa la evaluación/retroalimentación puesta por el profesor (según configuración pública/privada).

---

**Justificación de la propuesta:**  
Decidimos que la mejor opción es realizar una sola aplicación con ambos roles (profesor y estudiante) para reducir la complejidad sin reducir funcionalidad. La evaluación entre pares depende de los mismos objetos de dominio para ambos roles (cursos, grupos, evaluaciones, resultados). Si se construyeran dos aplicaciones, habría que duplicar modelos, validaciones y parte importante de la lógica, incrementando la posibilidad de inconsistencias y elevando el esfuerzo de mantenimiento.

Tuvimos una reunión con la profesora Rocío Ramos, quien nos confirmó que usar una sola aplicación sería lo más práctico y menos complicado. Además, consideró que la idea es muy buena. Nos comentó que ella ya ha usado aplicaciones parecidas para sus actividades, pero que no la han dejado completamente satisfecha y que le resultaban un poco incómodas de usar, lo cual refuerza la necesidad de una solución más simple y centrada en la experiencia del usuario.

Por otro lado, los referentes utilizados ayudaron a guiarnos sobre cómo queremos que sea la aplicación. Por ejemplo, la “Evaluación de docente” ayuda a identificar tipos de preguntas/criterios útiles para medir y evaluar la contribución de los integrantes del grupo.
