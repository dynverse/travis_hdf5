install_hdf5() {
  if [ -z "$HDF5_VERSION" ]; then
    echo "Error: variable HDF5_VERSION not found."
    exit 1
  fi
  if [ -z "$HDF5_DIR" ]; then
    echo "Error: variable HDF5_DIR not found."
    exit 1
  fi
  
  HDF5_VER=`echo $HDF5_VERSION | sed 's#\.[0-9]*$##'`
  
  pushd /tmp
  wget https://www.hdfgroup.org/ftp/HDF5/releases/hdf5-$HDF5_VER/hdf5-$HDF5_VERSION/src/hdf5-$HDF5_VERSION.tar.gz
  tar -xzvf hdf5-$HDF5_VERSION.tar.gz
  pushd hdf5-$HDF5_VERSION
  chmod u+x autogen.sh
  ./configure --prefix $HDF5_DIR
  make -j 2
  make install
  popd
  popd
}

git_config() {
  git config --global user.email "travis@travis-ci.org"
  git config --global user.name "Travis CI"
}

create_tar() {
  mkdir /tmp/build
  pushd /tmp/build

  tar -zcvf build.tar.gz $HDF5_DIR
}

git_push() {
  if [ -z "$GITHUB_PAT" ]; then
    echo "Error: variable GITHUB_PAT not found."
    exit 1
  fi

  git init

  git add build.tar.gz
  git commit --allow-empty -m "Travis build: $TRAVIS_BUILD_NUMBER [ci skip]"

  git remote add origin https://${GITHUB_PAT}@github.com/dynverse/travis_hdf5.git
  git push --force origin v$HDF5_VERSION
  popd
}
