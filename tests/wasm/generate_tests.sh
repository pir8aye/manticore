#!/usr/bin/env bash

rm -rf */
touch __init__.py
wget -nv -O wabt.tgz -c https://github.com/WebAssembly/wabt/releases/download/1.0.11/wabt-1.0.11-linux.tar.gz
wget -nv -O spec.zip -c https://github.com/WebAssembly/spec/archive/ace189a8f906f4f0760656a2aa53b6dc7046e771.zip

yes | unzip -q -j spec.zip 'spec-*/test/core/*' -d .
rm run.py README.md spec.zip

tar --wildcards --strip=1 -xf wabt.tgz 'wabt-*/wast2json'
rm wabt.tgz

ls *.wast | sed 's/\.wast//g' > modules.txt
while read module; do
    echo "Preparing $module"
    mkdir _$module
    touch _$module/__init__.py
    ./wast2json --debug-names $module.wast -o _$module/$module.json
    mv $module.wast _$module/
    python json2mc.py _$module/$module.json > _$module/test_$module.py
done < modules.txt

exit 0