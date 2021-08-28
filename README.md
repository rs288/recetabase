# Sitio web de Recetas de cocina

[https://recetabase.xyz](https://recetabase.xyz)

Este es un sitio web de cocina simple donde los usuarios pueden enviar recetas.
No hay anuncios, rastreadores, cookies.

## Formas de contribuir

- Añadiendo una receta.
- Haga una receta y tome una buena foto si ya no tiene una buena foto.
  existe. Las imágenes enviadas deben ser pequeños archivos `.webp`, idealmente de menos de 100K
  más o menos.
- Corrija errores en recetas o agregue mejoras menores.

## Reglas de presentación

- Archivos de envío de modelos después de [example.md](example.md). Ponlos en `src/`.
- Las recetas deben comenzar con un título, con un solo "#", *en la primera línea*. No
  línea vacía en la parte superior, sin línea final al final. El archivo debe ser `\n`
  terminado en linux-fashion (si estás en linux no necesitas preocuparte,
  debe ser automático).
- Los nombres de los archivos deben ser el nombre del plato con palabras separadas por guiones.
  (`-`). No subrayados y definitivamente no espacios.

### Etiquetas

Puede (y debe) agregar etiquetas al final de su receta. La sintaxis es:
```
;tags: tag1 tag2 tag3
```

La línea de etiqueta debe ser una sola línea, al final del archivo de markdown, precedida
por una línea en blanco.

Agregue entre 1 y 4 etiquetas, **priorice las etiquetas existentes**. Como pauta general,
agregue el país de donde se origina la receta si la receta es representativa
de dicho país, usando la forma adjetiva (ej. *mexicana*, *italiana*, etc). Etiqueta
el ingrediente principal si es algo un poco especial.

Lista de etiquetas categóricas especiales para usar si es relevante:
- `basic`: para recetas básicas que no están destinadas a ser independientes, sino que se suponen
  para incorporar en otra receta.
- `desayuno`
- `postre`
- `rapida`: para recetas que se pueden cocinar en menos de 20 minutos.
- `guarniciones`: guarniciones como puré, patatas fritas, etc.
- `merienda`

### Imágenes

Las imágenes se almacenan en `data/pix`.

Cada receta puede tener una imagen de título en la parte superior y tal vez
varias imágenes instructivas como absolutamente necesarias.

No agregue imágenes de archivo que haya encontrado en Internet.
Tome una buena fotografía usted mismo del plato real creado.
Si ve una imagen mala o deficiente, puede enviar una mejor.

Las imágenes deben estar en formato `.webp` y con un tamaño de archivo lo más pequeño posible.
Si envía una imagen para, por ejemplo, `pollo-parmesano.md`, debe agregarse como `pix/pollo-parmesano.webp`.

Si desea agregar imágenes direccionales adicionales,
deben estar numerados con dos dígitos como: `pix/pollo-parmesano-01.webp`, etc.

## Licencia

Este sitio web y todo su contenido es de dominio público.
Al enviar texto, imágenes o cualquier otra cosa a este repositorio,
renuncia a cualquier pretensión de propiedad,
aunque eres bienvenido y te recomendamos que te des crédito
en la parte inferior de una página enviada (incluidos enlaces personales).
