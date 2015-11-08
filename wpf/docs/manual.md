---
title: Práctica final de interfaces (WPF)
subtitle: Manual del programador
author:
  - Emilio Cobos Álvarez (70912324) <emiliocobos@usal.es>
lang: spanish
babel-lang: spanish
polyglossia-lang:
  options: []
  name: spanish
---

# Diagrama de clases

Este es el diagrama de clases de la aplicación:

![Diagrama de clases](img/class-diagram.dia.png)

# Resumen de las clases y del funcionamiento de la práctica.

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
Se utiliza el [método de
Verlet](https://en.wikipedia.org/wiki/Verlet_integration#Velocity_Verlet) para
calcular la aceleración, ya que el método de Euler (el más obvio) introduce un
error sistemático en prácticamente todos los casos. Es recomendable leer [este
hilo de GameDev Stack
Exchange](http://gamedev.stackexchange.com/questions/15708/how-can-i-implement-gravity)
para obtener más información.

### Conservación del momento lineal en un choque rígido

$$m_1 \cdot v_{0_1} + m_2 \cdot v_{0_2} = m_1 \cdot v_{f_1} + m_2 \cdot v_{f_2}$$

Es la base para entender las fuerzas sumadas a los objetos cuando chocan. El
cálculo de la dirección es más complejo de lo que parece, y aunque en principio
llegué a un algoritmo medianamente sofisticado, me decanté por seguir el
algoritmo descrito
[aquí](http://ericleong.me/research/circle-circle/#dynamic-circle-circle-collision),
basado en la conservación del momento angular, usando la distancia de centro
a centro normalizada y la velocidad de cada círculo para calcular el choque.

Dicho algoritmo está ligeramente modificado porque las masas de los objetos
estaban confundidas en la ecuación original.

El choque con los bordes es relativamente fácil de simular, porque sólo tenemos
que invertir la dirección de la velocidad (multiplicada por el factor de rebote
del objeto).

## Dificultades pasadas

### Simulación del choque

Al principio se trató de simplificar no forzando la posición de los círculos al
chocar. Esto generaba que si dos círculos chocaban, y en el siguiente intervalo
de simulación estaban todavía chocando, se quedaban indefinidamente pegados (cada
frame se detectaba el choque en un sentido). Esto se ha solucionado moviendo los
círculos al punto medio entre los radios de los círculosr:

```csharp
Vector a = centerToCenter * (obj.Radius / centerToCenterLen);
Vector b = centerToCenter * (centerToCenterLen - other.Radius) / centerToCenterLen;
Vector middle = (a - b) / 2;

obj.Position -= middle;
other.Position += middle;
```

Igualmente, cuando un objeto choca contra uno de los bordes, se fuerza la
posición. Esto genera **pequeños errores de redondeo** que hace que el sistema
pierda algo de energía. Dichos errores se pueden mitigar escogiendo un intervalo
de simulación más corto, no obstante con los valores que están la simulación es
muy realista.

### Detecciones duplicadas de colisiones

Se puede apreciar que el bucle donde se detecta si un objeto choca con otro no
es un bucle `foreach` cualquiera, sino que existe un flag
(`detectingCollisions`).

Este flag se usa para sólo detectar colisiones con objetos que van después que
nosotros en la lista. No sólo es más eficiente así, sino que **previene detectar
la misma colisión múltiples veces**.

```csharp
if (ReferenceEquals(obj, other))
{
    detectingCollisions = true;
    continue;
}

if (!detectingCollisions)
  continue;
```

Obviamente, cuando se detecta una colisión, se suman determinadas fuerzas
a ambos objetos. Como la colisión no se detecta varias veces, tenemos un campo
`PrecalculatedDeltaF`, que hace justo lo que dice, almacena la fuerza
precalculada de colisiones anteriores.

```csharp
Vector f = obj.PrecalculatedDeltaF;

// ...

other.PrecalculatedDeltaF += obj.Speed * obj.Mass;
other.PrecalculatedDeltaF -= other.Speed * other.Mass;
```

XXX TODO introducir propiedad `PreviousAcceleration`, el código actual
(`World.cs:42`) es incorrecto (el valor se sobreescribe en `World.cs:49`).

