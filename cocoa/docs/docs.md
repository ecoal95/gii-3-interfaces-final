---
title: Práctica final de interfaces (Cocoa)
subtitle: Manual
author:
  - Emilio Cobos Álvarez (70912324) <emiliocobos@usal.es>
lang: es-ES
toc-depth: 4
babel-lang: spanish
polyglossia-lang:
  options: []
  name: spanish
biblio-title: Referencias
biblatex: true
bibliography:
  - bibliography.bib
---

# Manual del Programador

## Introducción

La práctica ha sido desarrollada en XCode 7.2, en un *Hackintosh*, y con el
lenguaje de programación *Swift*.

La arquitectura de la aplicación es prácticamente idéntica a cómo sería con
*Objective C*.

Ha habido una relativa falta de tiempo lo que ha impedido determinadas
refactorizaciones que posiblemente mejorarían el código, no obstante el
resultado bastante bueno.

## Diagrama de clases

Este es el diagrama de clases de la aplicación [^diagramfootnote]:

[^diagramfootnote]: Nótese que puede estar incompleto, es probable que falten
cosas añadidas en distintas iteraciones. Las partes no conectadas están
acopladas bien via `NSWindow!` o bien via `NSNotification`.

![Diagrama de clases](img/class-diagram.dia.png "Diagrama de clases")

## Glosario rápido de algunas clases importantes para entender la práctica

Me centro en las clases específicas de la aplicación, se asumen conocimientos
previos de Cocoa.

 * `World`: En esta clase se llevan a cabo todos los cálculos físicos.
     Representa el espacio donde se encentran los objetos.
 * `MovingCircle`: Esta clase representa una esfera, y contiene tanto una masa,
     una velocidad, etc., como un `NSBezierPath`, encargado de dibujar la
     figura.
 * `WorldConfig`: Esta clase contiene lo necesario para instanciar un mundo,
     incluida toda la configuración necesaria para instanciar todos los objetos
     iniciales (`MovingCircle`).
 * `WorldManager`: Esta clase se encarga de las partidas guardadas. Se podría
     decir que lo único que tiene que hacer es mantener una lista de
     `WorldConfig`. Actúa también como `NSTableViewDataSource`, lo que hace que
     pueda ser utilizado para mostrar las partidas guardadas de forma mucho más
     fácil[^though].

[^though]: Aunque en cierto modo viola el principio de responsabilidad única.
Ésta sería una de de las refactorizaciones comentadas anteriormente.

## Cómo funciona la simulación

La simulación se realiza enteramente en la clase `World`. Dicha clase es
completamente ajena a cómo se mostrarán los resultados. Idealmente soportaría
muchos más objetos que un `MovingCircle` (polígonos, etc...) pero la dificultad
de calcular la rotación tras el coche de un polígono (habría que llevar también
la velocidad angular de cada objeto), junto con la falta de tiempo ha hecho que
se vea limitado a esferas.

Esta clase hace una simulación basándose en diversas leyes físicas:

### Primera ley de Newton y definición de velocidad:

$$\vec{F} = m \cdot \vec{a}$$
$$\Delta \vec{v} = \vec{a} \cdot \Delta t$$

Estas son las fórmulas básicas utilizadas para el cálculo de la velocidad. En el
método `force` se calcula la suma de todas las fuerzas aplicadas sobre un objeto
(incluída la gravedad), y se divide entre la masa de dicho objeto para calcular
la aceleración, que multiplicada por el tiempo pasado da el incremento de
velocidad.

#### Integración de Verlet

Se utiliza el método de Verlet [@web:verlet] para calcular la aceleración, ya
que el método de Euler (el más obvio) introduce errores de forma sitemática
[@web:gamedev-gravity].

### Conservación del momento lineal en un choque rígido

$$m_1 \cdot v_{0_1} + m_2 \cdot v_{0_2} = m_1 \cdot v_{f_1} + m_2 \cdot v_{f_2}$$

Es la base para entender las fuerzas sumadas a los objetos cuando chocan. El
cálculo de la dirección es más complejo de lo que parece
[@elong-circle-circle-collision]. Se basa en la conservación del momento
lineal, usando la distancia de centro a centro normalizada y la velocidad de
cada círculo para calcular el choque.

El algoritmo está descrito con detalle en
[@elong-circle-circle-collision-tutorial], aunque está ligeramente modificado
porque las masas de los objetos estaban confundidas en la ecuación original.

El choque con las bordes es relativamente fácil de simular, porque sólo tenemos
que invertir la dirección de la velocidad (multiplicada por el factor de rebote
del objeto). Esto es equivalente a decir que se choca con un objeto de masa
infinita y velocidad cero.

## Dificultades pasadas

Las dificultades pasadas comunes a la primera implementación se describen en el
correspondiente manual.

### Rendimiento

La aplicación hace una gran cantidad de cálculos, por lo que es normal que el
rendimiento haya sido una dificultad.

Lo cierto es que el loop de eventos de Cocoa se ha comportado sorprendentemente
bien con respecto a la práctica, por lo que las optimizaciones necesarias han
sido pocas.

Una de esas pocas optimizaciones que me parece relevante recalcar es la **no
regeneración del bezier path cada iteración**. En vez de eso, se transforman los
puntos ya existentes con respecto al path original:

```swift
// MovingCircle.swift
func path() -> NSBezierPath {
    let transform = NSAffineTransform();
    transform.translateXBy(self.position.x - self.previousPosition.x, yBy: self.position.y - self.previousPosition.y);
    self._path.transformUsingAffineTransform(transform);
    self.previousPosition = self.position;
    return self._path;
}
```

## Posibles mejoras

Soy consciente de que la práctica es muy mejorable, sobre todo de cara a la
interfaz de configuración. No es difícil encontrar alguna manera de hacerla más
bonita o amigable.

A continuación se exponen algunas posibles mejoras que no se han realizado por
falta de tiempo:

### Persistencia (opcional?) de las partidas guardadas

No sería demasiado complicado que `WorldManager` pudiera exportar en JSON
o algún otro formato portable el estado inicial de los mapas.

### Hacer más configurable los intervalos de los temporizadores

La práctica sólo se ha probado en un portátil con un procesador Intel Core i7.
Aunque rinde bien incluso compilada sin optimizaciones (modo `Debug`), es
posible que en otro hardware más antiguo no rinda igual, así que esta opción
sería interesante.

En el estado actual, el intervalo del timer es 1 / 60 segundos, para conseguir
aproximadamente 60 frames por segundo.

### Hacer algo de limpieza del código

Aunque en general estoy más contento con la limpieza del código que en la
práctica de WPF (swift ha ayudado a ello), hay bastantes cosas que se pueden
mejorar, como lo comentado anteriormente acerca de `WorldManager`, por ejemplo.

### Separación de las ventanas

No sería muy complicado, pero actualmente todas las ventanas están en un mismo
archivo `.xib` por comodidad.

### Generalización a polígonos

Sería genial, pero lleva mucho tiempo si se quiere hacer de cero (calcular el
punto de choque y la velocidad angular resultante son sólo algunas de las
dificultades que veo a priori).

### Mejoras en la redacción del manual

Si has llegado hasta aquí ya sabes a qué me refiero.

## Modo de desarrollo (opinión incluída)

### IDE

Trabajar con *XCode* no me ha gustado particularmente, a pesar de la existencia
de [XVim](https://github.com/XVimProject/XVim).

Especialmente el interface builder es un dolor de usar sin un ratón (sólo con un
trackpad), y podría ser más productivo si se usa un sistema basado en texto.

Puedo decir lo mismo del *build system* que usa XCode, tratar de renombrar el
directorio donde se ubicaba el código también fue especialmente doloroso.

Trabajar fuera del entorno habitual[^environ] ha sido relativamente complicado
de todas formas (especialmente dada la falta de internet inalámbrico en el
ordenador), y sigo siendo partidario de no usar un IDE.

[^environ]: GNU/Linux, una shell y Vim

### Lenguaje

Swift como lenguaje merece mucho la pena, me he divertido realmente
escribiéndolo, y es mucho más *sencillo* y legible que Objective C (en mi
opinión claro).

Es un lenguaje orientado a objetos, pero cuyo diseño (mutabilidad controlada,
inferencia de tipos, etc...) lo hace mucho más placentero de trabajar que con,
por ejemplo, Java o C#.

He tenido algunos problemas con determinadas partes de la API de Cocoa,
concretamente con un observer de notificaciones que provocaba un *release*, pero
no estoy completamente seguro de si sería por el bridge entre Swift y Cocoa o la
propia API de Cocoa.

### API

La API de Cocoa no es excesivamente compleja, pero si se notan claras
diferencias entre esta y WPF.

La parte que más me ha gustado es que te da acceso a los niveles más bajos del
pipeline gráfico (puedes controlar si un vista tiene una capa, etc...).

### CVS

XCode tiene control de versiones integrado, no obstante no me he molestado en
utilizarlo, y he portado el código a otro repositorio, por comodidad.

El no acceso a internet sin cable por parte de mi *hackintosh* ha sido decisivo
en ese aspecto.

# Manual del usuario

## Funcionamiento mínimo

Lo primero que puedes hacer para hacer una prueba mínima de la aplicación es
hacer click en el botón de `Start Simulation`, lo que lanzará una simulación con
los valores por defecto.

A partir de ahora tienes... **¡Exacto! Una preciosa ventana en blanco**. No
obstante: puedes **hacer click** sin problemas para ver el funcionamiento...
Y dejar caer la primera bola.

Eso es muy poco divertido... Puedes hacer click como loco para ver a las leyes
de la física actuar para divertirte.

Una vez estés en esa pantalla, puedes abrir el cuadro de diálogo de
configuración para cambiar la gravedad, o modificar los valores de la siguiente
bola que hagas aparecer.

También te permite, haciendo doble click en la fila, recuperar una partida
guardada anteriormente.

## Configuración avanzada

Cuando cierras la simulación, volverás a la pantalla principal. Desde ahí puedes
cerrar definitivamente la aplicación, o configurar otra partida más.

Habrás notado que también te ha aparecido la lista de partidas guardadas ahí,
por si te apetece cargar una anterior.

En esa pantalla puedes configurar una gran cantidad de cosas.

### Dimensiones de la simulación

Por defecto están las mínimas ($500\times500$). Siéntete libre de configurar
cualquier valor de ancho y alto por encima.

### Gravedad

Supongo que necesita poca descripción.

### Objetos

Cada objeto es una pelota. Puedes tener un número infinito de pelotas, cada una
con unos valores diferentes.

#### Velocidad

La velocidad inicial de la pelota.

#### Posición inicial

La posición inicial de la pelota. Nótese que **la coordenada $(0, 0)$ es la superior
izquierda**.

#### Factor de rebote

Este es un multiplicador que se usa para simular rozamiento. Cuando un objeto
rebota con otro o con una pared, la velocidad resultante será multiplicada por
ese factor. Por defecto está a uno, aunque puedes disminuirlo a tu gusto,
o aumentarlo (con cuidado, las bolas acabarán a una velocidad enorme).

#### Radio

Poco hay que explicar acerca de este valor.

#### Masa

La masa de una pelota no afecta a su velocidad de caída, pero si a sus choques.
Sigue las leyes de la física, así que guíate por tu conocimiento para
configurarla: Ya sabes lo que va a pasar si pones una pelota de masa 1 a chocar
con una de masa 500.

## Objetivo

Diviértete :P
