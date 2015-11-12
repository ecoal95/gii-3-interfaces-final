---
title: Práctica final de interfaces (WPF)
subtitle: Manual del programador
author:
  - Emilio Cobos Álvarez (70912324) <emiliocobos@usal.es>
lang: es-ES
babel-lang: spanish
polyglossia-lang:
  options: []
  name: spanish
linkcolor: blue
urlcolor: black
biblio-title: Referencias
biblatex: true
bibliography:
  - bibliography.bib
---

# Diagrama de clases

Este es el diagrama de clases de la aplicación [^diagramfootnote]:

[^diagramfootnote]: Nótese que puede estar incompleto, es probable que falten
cosas añadidas en distintas iteraciones, aunque no haya dado tiempo
a corregirlos por cuestión de tiempo. No obstante representa bien la
arquitectura de la aplicación.

![Diagrama de clases](img/class-diagram.dia.png "Diagrama de clases")

# Glosario rápido de algunas clases importantes para entender la práctica

Me centro en las clases específicas de la aplicación, se asumen conocimientos
previos de WPF.

 * `World`: En esta clase se llevan a cabo todos los cálculos físicos.
     Representa el espacio donde se encentran los objetos.
 * `MovingCircle`: Esta clase encapsula una `Shape` de Windows, y le añade una
     determinada masa, una velocidad...
 * `MovingCircleConfig`: Esta clase contiene todos los datos necesarios para
     instanciar un `MovingCircle`.
 * `WorldConfig`: Esta clase contiene lo necesario para instanciar un mundo,
     incluida toda la configuración necesaria para instanciar todos los objetos
     iniciales (`MovingCircleConfig`).
 * `MapManager`: Esta clase se encarga de las partidas guardadas. Se podría
     decir que lo único que tiene que hacer es mantener una lista de
     `WorldConfig`.

# Cómo funciona la simulación

La simulación se realiza enteramente en la clase `World`. Dicha clase es
completamente ajena a cómo se mostrarán los resultados. Idealmente soportaría
muchos más objetos que un `MovingCircle` (polígonos, etc...) pero la dificultad
de calcular la rotación tras el coche de un polígono (habría que llevar también
la velocidad angular de cada objeto), junto con la falta de tiempo ha hecho que
se vea limitado a esferas.

Esta clase hace una simulación basándose en diversas leyes físicas:

## Primera ley de Newton y definición de velocidad:

$$\vec{F} = m \cdot \vec{a}$$
$$\Delta \vec{v} = \vec{a} \cdot \Delta t$$

Estas son las fórmulas básicas utilizadas para el cálculo de la velocidad. En el
método `force` se calcula la suma de todas las fuerzas aplicadas sobre un objeto
(incluída la gravedad), y se divide entre la masa de dicho objeto para calcular
la aceleración, que multiplicada por el tiempo pasado da el incremento de
velocidad.

### Integración de Verlet

Se utiliza el método de Verlet [@web:verlet] para calcular la aceleración, ya
que el método de Euler (el más obvio) introduce un error sistemático en
prácticamente todos los casos [@web:gamedev-gravity].

## Conservación del momento lineal en un choque rígido

$$m_1 \cdot v_{0_1} + m_2 \cdot v_{0_2} = m_1 \cdot v_{f_1} + m_2 \cdot v_{f_2}$$

Es la base para entender las fuerzas sumadas a los objetos cuando chocan. El
cálculo de la dirección es más complejo de lo que parece
(@elong-circle-circle-collision), basado en la conservación del momento angular,
usando la distancia de centro a centro normalizada y la velocidad de cada
círculo para calcular el choque.

El algoritmo está descrito en [@elong-circle-circle-collision-tutorial], aunque está
ligeramente modificado porque las masas de los objetos estaban confundidas en la
ecuación original.

El choque con los bordes es relativamente fácil de simular, porque sólo tenemos
que invertir la dirección de la velocidad (multiplicada por el factor de rebote
del objeto).

# Dificultades pasadas

### Simulación del choque

Al principio se trató de simplificar no forzando la posición de los círculos al
chocar. Esto generaba que si dos círculos chocaban, y en el siguiente intervalo
de simulación estaban todavía chocando, se quedaban indefinidamente pegados (cada
frame se detectaba el choque en un sentido).

Se ha solucionado moviendo los círculos al punto medio entre los radios de los
círculos. Esta decisión ha resultado ser, desde el punto de vista del autor, la
más útil, haciendo que nos olvidemos al recoger datos de la posición del resto
de objetos.

Por ejemplo, el usuario puede configurar dos bolas en el mismo lugar, y tras el
primer frame, el algoritmo se encarga de separarlas:

```cs
Vector a = centerToCenter * (obj.Radius / centerToCenterLen);
Vector b = centerToCenter * (centerToCenterLen - other.Radius) / centerToCenterLen;
Vector middle = (a - b) / 2;

obj.Position -= middle;
other.Position += middle;
```

Igualmente, cuando un objeto choca contra uno de los bordes, se fuerza la
posición. Esto genera **pequeños errores de redondeo** que hace que el sistema
pierda algo de energía. Dichos errores se pueden mitigar escogiendo un intervalo
de simulación más corto, no obstante con los valores actuales la simulación es
realista.

### Detecciones duplicadas de colisiones

Se puede apreciar que el bucle donde se detecta si un objeto choca con otro no
es un bucle `foreach` cualquiera, sino que sólo se detectan colisiones con los
objetos posteriores, para **prevenir detectar la misma colisión múltiples
veces**.

Obviamente, cuando se detecta una colisión, se suman determinadas fuerzas
a ambos objetos. Como la colisión no se detecta varias veces, tenemos una caché
a nivel de instancia (`PrecalculatedDeltaFCache`), que almacena la fuerza
precalculada de otras colisiones.

```cs
Vector f = PrecalculatedDeltaFCache[myIndex];

// ...

PrecalculatedDeltaFCache[i] += obj.Speed * obj.Mass;
PrecalculatedDeltaFCache[i] -= other.Speed * obj.Mass;
```


### Rendimiento

La aplicación hace una gran cantidad de cálculos, por lo que es normal que el
rendimiento haya sido una dificultad.

Al principio se usó un `DispatcherTimer` en el hilo principal tanto para la
física como para dibujar. Lo cierto es que **rendía sorprendentemente bien**,
pero no aguantaba demasiado bien un número elevado de bolas. Además, dado la
velocidad que pueden alcanzar determinadas partículas, es necesario dibujar
a una cantidad de frames considerable para evitar que las bolas más rápidas
parezcan que "saltan".

para ello se ha usado un `Timer` normal en otro hilo para la física, y un
`DispatcherTimer` con prioridad `Sender` (mayor que el renderizado) para
actualizar las posiciones.

No ha sido necesaria sincronización por razones bien simples, y es que el hilo
principal sólo necesita leer datos, que además varían muy poco de una iteración
a otra (sólo necesita las posiciones de las bolas). No obstante se ha
considerado, y si hubiera sido necesaria, es probable que se hubiera aplicado
una estrategia de *doble buffer* para hacerlo (el hilo de la física escribe a un
buffer las posiciones, y lo reemplaza de forma atómica cuando acaba por otro),
mientras que el hilo principal sólo necesita leer del buffer lleno cuando sea
apropiado.


# Posibles mejoras

Soy consciente de que la práctica es muy mejorable, sobre todo de cara a la
interfaz de configuración. No es difícil encontrar alguna manera de hacerla más
bonita o amigable.

Hay que tener en cuenta las limitaciones temporales que ha habido, y el proceso
que se ha seguido para desarrollarla: Lo primero que hubo fue la pantalla en
blanco con la interacción de las bolas al hacer click y la configuración del
cuadro de diálogo (`DynamicConfigurationWindow`).

El resto de configuración ha sido a posteriori, y se le ha dedicado
relativamente poco tiempo. Aunque el resultado no ha sido malo, es bastante
mejorable, incluso de forma interna.

A continuación se exponen algunas posibles mejoras que no se han realizado por
falta de tiempo.

## Persistencia (opcional?) de las partidas guardadas

No sería demasiado complicado que `MapManager` pudiera exportar en JSON o algún
otro formato portable el estado inicial de los mapas.

## Unifiación de algunas vistas, usando parciales

Las ventana de configuración dinámica tiene mucho en común con la principal
(sliders para el radio, masa, etc...), las `ListView` que pueden estar vacías
son muy similares... Ese tipo de cosas se podrían abstraer para hacer el código
más mantenible.

## Hacer más configurable los intervalos de los temporizadores

La práctica sólo se ha probado en un portátil con un procesador Intel Core i7.
Aunque rinde bien incluso compilada sin optimizaciones (modo `Debug`), es
posible que en otro hardware más antiguo no rinda igual, así que esta opción
sería interesante.

## Hacer algo de limpieza del código

Se ha intentado mantener lo más organizado posible, y se ha tratado de separar
entre configuración y bindings, lo que ha llevado a algo de repetición a la que
se le podría dar un repaso. También se descubrió que en C-Sharp existe la
keyword `as` para hacer castings durante el proceso de desarrollo, por lo que es
probable que queden algunos casts con la sintaxis de C.

## Mejoras de visibilidad del código

Hay partes importantes que tienen visibilidad pública por conveniencia. Un
ejemplo muy claro es el array de objetos (`Objects`) de la clase `World`, o el
campo `circle` de `MovingCircle`. Aunque se usan externamente sólo para pintar,
no estás protegido contra las modificaciones de alguien. Esto se podría corregir
usando otra serie de abstracciones, a costa de tiempo de desarrollo.

## Generalización a polígonos

Sería la leche, pero lleva mucho tiempo si se quiere hacer de cero (calcular el
punto de choque y la velocidad angular resultante son sólo algunas de las
dificultades que veo a priori).

## Mejoras en la redacción del manual

Si has llegado hasta aquí ya sabes a qué me refiero.

# Modo de desarrollo (opinión incluída)

## IDE

Trabajar con *Visual Studio* ha sido bastante más placentero de lo que
recordaba, en parte gracias al desarrollador de
[VsVim](https://visualstudiogallery.msdn.microsoft.com/59ca71b3-a4a3-46ca-8fe1-0e90e3f79329).

Trabajar fuera del entorno habitual[^environ] ha sido relativamente complicado
de todas formas, y sigo siendo partidario de no usar un IDE. No obstante, dado
el tipo de lenguaje con el que se ha trabajado (ahora voy a ello), y al poco
tiempo que se ha estado expuesto a la API, se hace imposible no hacerlo.

En mi opinión el IDE, a pesar de proporcionar determinadas *ventajas*
(compilación integrada, navegación por archivos, etc...), sigue siendo
distractivo en su mayoría. Reduce la cantidad de código que puedo ver en un
mismo instante, y por lo tanto mi capacidad de razonamiento respecto al mismo.

El hecho de que intente abstraerte del sistema de ficheros provoca que todos los
ficheros acaben estando en el mismo directorio.

Tampoco me gusta que te trate de forzar a un estilo de código (especialmente el
posicionamiento de lo corchetes (`{}`)), ni no tener disponible el tener varios
archivos abiertos en pantalla paralelamente[^disclaimer].

En otras palabras: De no ser por la capacidad de autocompletado que proporciona,
el IDE sería mucho más contraproducente que un editor de texto normal.

[^environ]: GNU/Linux, una shell y Vim
[^disclaimer]: Nótese que no dudo de que habrá alguna manera para configurar eso
o algo parecido, aunque dudo que sea la misma experiencia de no tener que quitar
los dedos del teclado que se consigue con un editor. Sobre el formato del
código, me parece que en todo caso debería ser *opt-in*.

## Lenguaje

No hay duda de que C# es un lenguaje potente, y con características modernas. No
obstante su diseño prácticamente heredado de Java hace que me recuerde un montón
a este, incluído el hecho de que me parece un lenguaje muy industrial y que
ofrece poco a la creatividad, al igual que otros lenguajes completamente
orientados a objetos.

Tampoco soy fan de que sea propietario de Microsoft, aunque el hecho de que hace
poco hayan hecho el runtime abierto [@web:coreclr-oss] me quita razón para
quejarme.

## API

La API de WPF está relativamente bien diseñada, hay formas para hacer de todo.
No obstante no me parece el diseño más intuitivo, especialmente el hecho de que
puedas especificar atributos con etiquetas, y los nombres de dichos atributos,
etc.

## CVS

Visual Studio tiene control de versiones integrado, no obstante no me he
molestado en utilizarlo, y he ido portando parches manualmente a otro
repositorio, por comodidad.

