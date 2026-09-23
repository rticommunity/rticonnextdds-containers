# CI y Jenkins

La configuración de CI se mantiene separada del código fuente de las imágenes.

El [Jenkinsfile](../../Jenkinsfile) es el punto de entrada para los jobs Jenkins
multibranch. Delega en [resources/automation/ci/ci-run.sh](ci/ci-run.sh), que también
pueden ejecutar los desarrolladores con las mismas variables de entorno que los
parámetros de Jenkins.

El flujo de CI contiene únicamente validación:

- Comprobaciones del repositorio desde [resources/automation/ci/ci-check.sh](ci/ci-check.sh).
- Comprobaciones estáticas de Dockerfile con `docker buildx bake --check all`.
- Construcción de una imagen SDK con todas las dependencias de compilación.
- Construcción de las imágenes Runtime para los perfiles `all`, `c`, `cpp`, `java`, `csharp` y `python`.
- Compilación de aplicaciones HelloWorld generadas desde los recursos IDL dentro de la imagen SDK compartida.
- Tests de pub/sub con pytest y `pexpect`, usando contenedores separados para publisher y subscriber.
- Informe opcional del tamaño de las imágenes Runtime mediante `MAX_RUNTIME_IMAGE_SIZE_MB`.
- Ejecución opcional de los ejemplos Runtime cuando hay una licencia RTI disponible en el agente Jenkins.

El pipeline no publica imágenes.

`RUN_UI_TOOLS` también construye la imagen independiente amd64 de UI Tools y
comprueba RDP. Con `RUN_RUNTIME_EXAMPLES=true`, el test adicional abre Admin
Console dentro de una sesión XRDP. Una ejecución completa contiene 12 resultados
pub/sub y un resultado de UI Tools. No se necesita un escritorio interactivo ni
un cliente RDP en el agente. El test UI necesita acceso al puerto loopback
publicado por Docker y a los bind mounts. La descarga inicial de la imagen de
escritorio es grande; se debe conservar la cache de Docker.

## Primera ejecución en Jenkins

1. Crear un Pipeline from SCM o un Pipeline multibranch usando el Jenkinsfile raíz.
2. Seleccionar un agente Linux amd64 con etiqueta `docker`, Bash, Python 3.9+,
   venv/pip, Docker y Buildx con soporte para Bake `--check`.
3. Instalar los plugins Pipeline y JUnit. El agente debe acceder al daemon Docker
   y compartir sus rutas de bind mount; con un daemon remoto, las rutas deben coincidir.
4. Configurar una credencial Jenkins de tipo Secret file con ID
   `rti_license.dat`. El Jenkinsfile la copia temporalmente para que el usuario
   del contenedor pueda leerla y la elimina al terminar. Nunca hacer commit de
   la licencia ni incluirla en las imagenes. El job requiere esta credencial
   incluso si se desactiva la ejecucion de ejemplos.
5. Mantener activados `RUN_LANGUAGE_MATRIX` y `RUN_RUNTIME_EXAMPLES` y ejecutar.
   Se esperan 12 resultados pub/sub: seis con el Runtime completo y seis con
   las variantes individuales, incluyendo dos ejemplos C++.

El runner usa Bake para todas las construcciones y genera automáticamente tags
CI únicos. Los reports incluyen metadatos de build, identidades de imágenes,
logs por test y XML JUnit. Jenkins recoge los artifacts antes de limpiar el
workspace. El job tiene un timeout de 60 minutos. Un fallo de build o test hace
fallar el job, aunque se siguen intentando los perfiles Runtime restantes.

Para una primera ejecución sin licencia, desactivar `RUN_RUNTIME_EXAMPLES`.
La compilación se ejecutará, pero no será una validación completa de comunicación.
