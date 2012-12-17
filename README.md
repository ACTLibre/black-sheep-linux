Acerca de
=========

Black Sheep Linux es un pequeño script que adapta una distribución estándar de
Ubuntu a las necesidades de la carrera de Ingeniería en Computación del
Instituto Tecnológico de Costa Rica.

![Black Sheep Logo](https://raw.github.com/carlos-jenkins/black-sheep-linux/master/images/logo_small.png "Black Sheep Logo")


Como usar
=========

Descargar el repositorio:

```shell
sudo apt-get install git
git clone git://github.com/carlos-jenkins/black-sheep-linux.git
cd black-sheep-linux
```

Verificar la disponibilidad de los paquetes:

```shell
./black_sheep.sh check
```

Instalar la meta-distribución (paquetes y personalización):

```shell
./black_sheep.sh install
```

Ejecutar funciones del script manualmente:

```shell
./black_sheep.sh manual [función]
```


Licencia
========

Copyright (C) 2012 Carlos Jenkins <carlos@jenkins.co.cr>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
