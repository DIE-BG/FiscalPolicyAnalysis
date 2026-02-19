# FiscalPolicyAnalysis
Repositorio para el desarrollo del modelo para el análisis de interacciones de Políticas Fiscales y Monetarias.

# Estructura
Para mantener un orden en el desarrollo del modelo se propone la siguiente estructura de directorios. Se encuentra inspirada en la estructura utilizada en la herramienta de selección de modelos tipo SVAR.

FiscalPolicyAnalysis/             # Carpeta principal del proyecto
├─ datos/                         # Carpeta principal para almacenar datos
│  ├─ Modelo 1/                   # Datos del Modelo 1
│  └─ Estimación/                 # Datos utilizados en la estimación del Modelo 1
│  └─ Corrimiento/                # Condiciones iniciales para el corrimiento del Modelo 1
│
├─ LYX/                           # Archivos de Lyx
│
├─ Manuscritos/                   # Archivos con la estructura del modelo o con cambios al mismo
│
├─ Resultados/                    # Carpeta que almacena los resultados de cada modelo
│  └─ Modelo 1/                   # Resultados del Modelo 1
│      └─ Gráficas/               # Gráficas del Modelo 1
│      └─ csv o xlsx/             # Archivos csv o xlsx del Modelo 1
│
├─ scripts/                       # Scripts de estimación y corrimientos
│  ├─ Modelo 1/                   # Scripts del Modelo 1
│  └─ Estimación/                 # Archivos utilizados para la estimación del modelo (OLS, estimación bayesiana, etc)
│  └─ Corrimiento/                # Corrimiento Modelo 1
│
├─ src/                           # Código fuente (funciones/módulos)
├─ helpers/                       # Funciones o scripts auxiliares creadas para propósitos específicos
│
├─ README.md                      # Este archivo
├─ .gitignore                     # Ignora archivos no necesarios dentro del repositorio de github
└─ Changelog.md                   # Archivo que documenta las distintas versiones del modelo. Cada modificación debe documentarse.
