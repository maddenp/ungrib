set -eux

export DIR=$PWD/install

export CPPFLAGS="$CPPFLAGS -I$DIR/include"
export JASPERINC=$DIR/include
export JASPERLIB=$DIR/lib
export LDFLAGS="$LDFLAGS -L$DIR/lib"
export NETCDF=$DIR
export PATH=$DIR/bin:$PATH

(
  set -eux
  cd netcdf-c
  ./configure --prefix=$DIR --disable-dap --disable-netcdf-4 --disable-shared
  make -j
  make install
) 2>&1 | tee out.netcdf-c

(
  set -eux
  cd netcdf-f
  ./configure --prefix=$DIR --disable-shared
  make -j
  make install
) 2>&1 | tee out.netcdf-f

(
  set -eux
  cd zlib
  ./configure --prefix=$DIR
  make -j
  make install  
) 2>&1 | tee out.zlib

(
  set -eux
  cd libpng
  ./configure --prefix=$DIR
  make -j
  make install
) 2>&1 | tee out.libpng

(
  set -eux
  cd jasper/jasper-1.900.1
  ./configure --prefix=$DIR
  make -j
  make install
) 2>&1 | tee out.jasper

(
  set -eux
  cd WRF
  cp -v $RECIPE_DIR/configure.wrf .
  export FFLAGS="$FFLAGS -fallow-argument-mismatch -fallow-invalid-boz"
  ./compile em_real
) 2>&1 | tee out.wrf

(
  set -eux
  cd WPS
  cp -v $RECIPE_DIR/configure.wps .
  export FFLAGS="$FFLAGS -fallow-argument-mismatch"
  ./compile
) 2>&1 | tee out.wps

mkdir -pv $PREFIX/{bin,etc}
cp -Lv WPS/ungrib.exe $PREFIX/bin/ungrib
rsync -av $RECIPE_DIR/etc/ $PREFIX/etc/
