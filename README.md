# Caso Práctico 2. 

Este directorio contiene un ejercicio enfocado al despliegue de infraestructura sobre el proveedor Cloud Microsoft Azure mediate el uso de herramientas DevOps.

### Planteamiento del ejercicio.

Creación automática de infraestructura en Azure utlizando Terraform como herramienta. Infraestructura creada:
- Un repositorio de imágenes de contenedores sobre infraestructura de Microsoft Azure mediante el servicio Azure Container Registry (ACR).
- Una máquina virtual con sistema operativo Linux.
- Un cluster de Kubernetes como servicio gestionado en Microsoft Azure (AKS).

Instalación y configuración mediante Ansible de forma atomática de los siguientes elementos:
- Un servidor Web apache desplegado en forma de contenedor de podman sobre una máquina virtual Linux en Azure.
- Una aplicación Nginx con almacenamiento persistente sobre un cluster AKS. 
 
