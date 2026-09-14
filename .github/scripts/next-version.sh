#!/usr/bin/env bash
# Versione del rilascio in corso, calcolata dai Conventional Commits (CN-13)
# successivi all'ultimo tag vMAJOR.MINOR.PATCH raggiungibile da HEAD:
#
#   - un commit che dichiari una rottura (`tipo!:` o `BREAKING CHANGE`)
#     incrementa la major;
#   - altrimenti un `feat` incrementa la minor;
#   - altrimenti si incrementa la patch.
#
# In assenza di tag vale la versione iniziale passata come argomento. Se HEAD
# coincide con l'ultimo tag (riesecuzione manuale del rilascio) la versione e'
# quella del tag, e il rilascio non ne crea una nuova.
#
# Richiede la storia completa del repository (checkout con fetch-depth: 0).
set -euo pipefail

initial_version="${1:?Uso: next-version.sh <versione-iniziale>}"

last_tag="$(git describe --tags --abbrev=0 --match 'v[0-9]*.[0-9]*.[0-9]*' 2>/dev/null || true)"
if [ -z "$last_tag" ]; then
  echo "$initial_version"
  exit 0
fi

IFS=. read -r major minor patch <<<"${last_tag#v}"

if [ -z "$(git rev-list "$last_tag"..HEAD)" ]; then
  echo "$major.$minor.$patch"
  exit 0
fi

messages="$(git log --format='%s%n%b' "$last_tag"..HEAD)"

if grep -qE '^[a-z]+(\([^)]*\))?!:|^BREAKING CHANGE' <<<"$messages"; then
  major=$((major + 1)); minor=0; patch=0
elif grep -qE '^feat(\([^)]*\))?:' <<<"$messages"; then
  minor=$((minor + 1)); patch=0
else
  patch=$((patch + 1))
fi

echo "$major.$minor.$patch"
