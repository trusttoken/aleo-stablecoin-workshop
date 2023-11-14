mkdir tmp

function copy_all() {
  rm -rf tmp

  mkdir tmp

  cp -rf src tmp/src
  cp -rf imports tmp/imports
  cp program.json tmp/program.json
}

# Build token
copy_all
mv tmp/imports/token.leo src/main.leo
echo '{
    "program": "token.aleo",
    "version": "0.0.0",
    "description": "",
    "license": "MIT"
}' > tmp/program.json
cd tmp && leo build && cd ..
cp -rf tmp/build/ build/
cp tmp/build/main.aleo build/imports/token.aleo

# Build new token
copy_all
cp placeholder/token.leo tmp/imports/token.leo
cd tmp && leo build && cd ..
cp tmp/build/main.aleo build/main.aleo

# Cleanup
rm -rf tmp
