#!/bin/bash
set -e
BRANCH="$2"
if [ -z "$1" ] || [ -z "$BRANCH" ]; then
echo "Uso:"
echo "  sh claude.sh --start claude/nombre-de-rama"
echo "  sh claude.sh --finish claude/nombre-de-rama"
exit 1
fi
case "$1" in
--start)
echo "Obteniendo rama $BRANCH..."
git fetch origin "$BRANCH"
git checkout "$BRANCH"
echo "Listo. Estás en $BRANCH"
    ;;
--finish)
echo "Mergeando $BRANCH en main..."
git checkout main
git pull origin main
git merge "$BRANCH"
git push origin main
echo "Eliminando rama $BRANCH..."
git branch -d "$BRANCH"
git push origin --delete "$BRANCH"
echo "Listo. Rama $BRANCH mergeada y eliminada."
    ;;
*)
echo "Opción no reconocida: $1"
echo "Usa --start o --finish"
exit 1
    ;;
esac
