#!/bin/bash
set -e

# 引数に -b が指定された時だけビルドする運用にする
BUILD_FLAG=""
if [ "$1" == "-b" ]; then
  BUILD_FLAG="--build"
fi

echo "--- Starting Services ---"

# バックグラウンドで並列実行させることで待ち時間を短縮
(cd backend && ./vendor/bin/sail up -d $BUILD_FLAG) &
(cd frontend && docker compose up -d $BUILD_FLAG) &

# 両方のプロセスが終わるのを待つ
wait

echo "--- All Done! ---"
