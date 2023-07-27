#!/usr/bin/env sh

# 發生錯誤時終止
set -e

# 創造
npm run build

# 進入創造文件夾
cd dist

# 如果要用自定義網域名用這一條
# echo 'www.example.com' > CNAME

git init
git add -A
git commit -m 'deploy'

# 如果你要部署在 https://<USERNAME>.github.io
# git push -f git@github.com:<USERNAME>/<USERNAME>.github.io.git main
git push -f git@github.com:<rex-0902>/<rex-0902>.github.io.git main
# 如果你要部署在 https://<USERNAME>.github.io/<REPO>
# git push -f git@github.com:<USERNAME>/<REPO>.git master:gh-pages

cd -