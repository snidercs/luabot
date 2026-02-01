# SPDX-FileCopyrightText: Michael Fisher @mfisher31
# SPDX-License-Identifier: MIT

FROM wpilib/roborio-cross-ubuntu:2026-22.04-py314
RUN apt-get update && apt-get install -y rsync gcc-multilib dos2unix git && rm -rf /var/lib/apt/lists/* 
ADD util/build-luajit-roborio.sh .
RUN dos2unix build-luajit-roborio.sh
RUN mkdir -p deps
RUN git clone https://github.com/LuaJIT/LuaJIT.git deps/luajit && \
    cd deps/luajit && \
    git reset --hard 707c12bf00dafdfd3899b1a6c36435dbbf6c7022 && \
    cd ../.. && \
    sh build-luajit-roborio.sh

# Build luabot-stub for linuxathena
ADD vendordep/stub.c /tmp/stub.c
RUN arm-frc2025-linux-gnueabi-gcc -c /tmp/stub.c -o /tmp/stub.o && \
    arm-frc2025-linux-gnueabi-ar rcs /tmp/libluabot-stub.a /tmp/stub.o

RUN mkdir -p /opt/luabot/linuxathena && \
    rsync -var --update 3rdparty/linuxathena/ /opt/luabot/linuxathena/ && \
    mkdir -p /opt/luabot/linuxathena/lib && \
    cp /tmp/libluabot-stub.a /opt/luabot/linuxathena/lib/
RUN rm -rf deps && rm -f build-luajit-roborio.sh && \
    rm /opt/luabot/linuxathena/bin/luajit
