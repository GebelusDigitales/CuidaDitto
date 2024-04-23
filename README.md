This is the Eclipse Ditto POC for the final project of Belen Carozo's and Belen Suarez's Computer Engineering degree.

As the name states, they will have to be very careful with the implementation.

# Project Name

CuidaDitto | Implementación de Ditto para Dosificación de Precisión

## Description

Eclipse Ditto es un framework que facilita la implementación de digital twins. Como parte de nuestro proyecto de grado decidimos usar esta herramienta para el manejo de la parte de wearables y dispositivos IoT.

## Prerequisites

- Docker: [Guía de instalación](https://docs.docker.com/get-docker/)

Decidimos usar Docker, ya que Eclipse cuenta con varios pasos de instalación y versiones específicas de Maven y Java. Para evitar problemas al correr en diferentes máquinas

## Getting Started

1. Clonar el repositorio:

```
git clone git@github.com:GebelusDigitales/CuidaDitto.git
```

2. Moverse al repositorio:

```
cd eclipse-ditto
```

3. Buildear los containers de Docker:

```
docker compose build
```

4. Arrancar los containers:

```
docker compose up
```

5. Correr Ditto

```
docker compose run eclipse-ditto
```

6. Correr una terminal de bash en Ditto

```
docker compose run eclipse-ditto bash
```

Si la build falla, vale la pena borrar las imágenes, volúmenes y containers de Docker:

```
docker system prune -a
```

Esto va a borrar todos los recursos que están "flotando" (no asociados a un container corriendo), además de que con la tag -a se le agregan todos los containers que no están corriendo y las imágenes que no se están usando.
