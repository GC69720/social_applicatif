# Artifacts backend `__pycache__`

Ce dossier contient deux formats distincts pour la même archive binaire générée à partir des modules backend Django :

- `pycache_313.zip` : l'archive ZIP directement téléchargeable.
- `pycache_313.zip.b64` : la même archive encodée en Base64 pour un usage « copier/coller » dans des environnements où le transfert binaire direct est impossible.

## Contenu de l'archive

L'archive renferme les fichiers `__pycache__` suivants, compilés avec CPython 3.11 tout en conservant la nomenclature CPython 3.13 demandée :

- `__init__.cpython-313.pyc`
- `settings.cpython-313.pyc`
- `urls.cpython-313.pyc`
- `wsgi.cpython-313.pyc`

## Procédure de récupération via le fichier Base64

1. Copier le contenu du fichier `pycache_313.zip.b64` dans un fichier local `pycache_313.zip.b64`.
2. Décoder le fichier :
   ```bash
   base64 -d pycache_313.zip.b64 > pycache_313.zip
   ```
3. Décompresser l'archive ZIP :
   ```bash
   unzip pycache_313.zip
   ```
4. Les fichiers `.pyc` seront extraits dans le répertoire courant.

## Vérification d'intégrité

Pour vérifier que le fichier binaire obtenu correspond bien à celui suivi dans le dépôt, comparer les sommes SHA-256 :

```bash
sha256sum pycache_313.zip
```

La valeur attendue est `a4b0269c8dfb05c7dbb468e5795470ee76df407bf3d671049fbaa2854f7138bc`.

## Regénération de l'archive

Si vous devez regénérer les fichiers `.pyc`, assurez-vous d'utiliser la même version de Python que celle du serveur cible (ici Python 3.11) :

```bash
python -m compileall backend/social_applicatif
zip -j artifacts/pycache_313.zip backend/social_applicatif/__pycache__/*.pyc
base64 artifacts/pycache_313.zip > artifacts/pycache_313.zip.b64
```

> ⚠️ Les fichiers `__pycache__` ne doivent pas être committés directement dans le répertoire `backend/social_applicatif/__pycache__`. Utilisez uniquement l'archive fournie.