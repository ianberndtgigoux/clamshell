# clamshell

Mantiene un Mac despierto con la tapa cerrada — **con fecha de vencimiento**.

macOS tiene `pmset disablesleep 1`, que impide dormir aunque cierres la tapa. El problema
no es prenderlo: es que no hay nada que lo apague. Si te olvidás, el Mac se queda despierto
en la mochila hasta que la batería muere.

Eso me pasó en agosto de 2026. `clamshell` es la respuesta: lo mismo, pero con un watchdog
que lo revierte solo.

```bash
sudo clamshell on                    # 4 horas
sudo clamshell on 8                  # 8 horas
sudo clamshell on 12 --while 4821    # mientras viva ese proceso
sudo clamshell off
clamshell status
```

## El watchdog

Un `LaunchDaemon` corre `clamshell watchdog` cada 60 segundos y al arrancar el Mac. Apaga
`disablesleep` si pasa cualquiera de estas cosas:

| Condición | Por qué |
|---|---|
| Se venció el plazo | El caso normal. Nunca hay una sesión sin fin. |
| La batería bajó del 20% sin cargador | El modo preciso en que maté la batería. Configurable con `CLAMSHELL_MIN_BATT`. |
| Murió el PID de `--while` | Atás la sesión a un build, un render, una corrida larga. Termina el proceso, duerme el Mac. |
| No existe el archivo de estado | El estado vive en `/var/run`, que se borra en cada arranque. Si el Mac se reinició con `disablesleep=1` colgado, el watchdog lo limpia. A prueba de crash. |

El estado es un archivo de dos líneas en `/var/run/clamshell.state`. Si se pierde, se apaga.
El default seguro es dormir.

## Instalar

```bash
git clone https://github.com/ianberndtgigoux/clamshell
cd clamshell
sudo ./instalar.sh
```

Copia el script a `/usr/local/bin`, instala el daemon en `/Library/LaunchDaemons` y lo
carga. Para desinstalar: `sudo launchctl bootout system/cl.clamshell.watchdog` y borrá los
dos archivos.

## Detalles

- `on`, `off` y `watchdog` necesitan root porque `pmset -a` lo necesita. `status` no.
- Las horas se validan: entero, entre 1 y 24. No hay sesión infinita ni por error de tipeo.
- `--while` verifica que el PID exista antes de empezar.
- El watchdog deja rastro en `syslog` con tag `clamshell`, y los errores van a
  `/var/log/clamshell.log`.

MIT.
