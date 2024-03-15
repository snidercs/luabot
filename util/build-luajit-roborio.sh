cd luajit
export PATH="$HOME/wpilib/2024/roborio/bin:$PATH"
make clean
make amalg HOST_CC="gcc -m32 -std=c99" \
    CROSS=arm-frc2024-linux-gnueabi- \
    BUILDMODE="static" PREFIX="/"
make install PREFIX="/" DESTDIR="$HOME/SDKs/botlib/roborio"
