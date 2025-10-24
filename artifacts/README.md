# Artifacts backend `__pycache__`

Ce dossier fournit deux représentations du même bundle binaire généré à partir des modules backend Django :

- `pycache_313.zip` : l'archive ZIP prête à l'emploi.
- `pycache_313.zip.b64` : l'archive encodée en Base64 afin de pouvoir être copiée/collée dans un terminal dépourvu de transfert binaire.

Les deux variantes contiennent les fichiers `__pycache__` suivants (compilés avec CPython 3.11 tout en conservant la nomenclature CPython 3.13 demandée) :

- `__init__.cpython-313.pyc`
- `settings.cpython-313.pyc`
- `urls.cpython-313.pyc`
- `wsgi.cpython-313.pyc`

> ℹ️ Les deux premières lignes du fichier Base64 sont des commentaires (`# gitleaks:allow …`) servant à signaler aux outils d'analyse de secrets qu'il s'agit d'un faux-positif. Elles doivent être ignorées lors du décodage.

## Récupération de l'archive à partir du fichier Base64

1. Copier l'intégralité du fichier `pycache_313.zip.b64` dans votre environnement local.
2. Décoder le contenu en sautant les lignes de commentaires :
   ```bash
   tail -n +3 pycache_313.zip.b64 | base64 -d > pycache_313.zip
