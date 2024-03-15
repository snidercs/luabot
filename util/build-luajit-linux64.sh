cd luajit
make clean
make amalg HOST_CC="gcc -m64 -std=c99" \
    BUILDMODE="static" \
    PREFIX="/"
make install PREFIX="/" DESTDIR="$HOME/SDKs/botlib/linux64"
