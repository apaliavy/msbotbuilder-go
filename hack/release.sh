#!/bin/bash
# Copyright (c) 2020 InfraCloud Technologies
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


set -o errexit
set -e

version=$(cut -d'=' -f2- .release)
if [[ -z ${version} ]]; then
    echo "Invalid version set in .release"
    exit 1
fi


if [[ -z ${GITHUB_TOKEN} ]]; then
    echo "GITHUB_TOKEN not set. Usage: GITHUB_TOKEN=<TOKEN> ./hack/release.sh"
    exit 1
fi

echo "Publishing release ${version}"

generate_changelog() {
    local version=$1

    # generate changelog from github
    github_changelog_generator -u apaliavy -p msbotbuilder-go -t ${GITHUB_TOKEN} --future-release ${version} -o CHANGELOG.md
    sed -i '$d' CHANGELOG.md
}

publish_release() {
    local version=$1

    # create gh release
    gothub release \
	   --user apaliavy \
	   --repo msbotbuilder-go \
	   --tag $version \
	   --name "$version" \
	   --description "$version"
}

make_release() {
    local version=$1

    # tag release
    git add .release CHANGELOG.md
    git commit -m "Release $version" ;
    git tag $version ;
    git push --tags origin develop;
    echo 'Git tag pushed successfully' ;
}

generate_changelog $version
make_release $version
publish_release $version

echo "=========================== Done ============================="
echo "Congratulations!! Release ${version} published."
echo "Don't forget to add changelog in the release description."
echo "=============================================================="
