rm -rf paperiogps
git clone https://github.com/SzelesTamas/paperiogps
rm -rf ./api/node_modules
mv ./paperiogps/nodejsServerApi/* ~/api/ --force
pm2 restart mapconquest
pm2 logs mapconquest
