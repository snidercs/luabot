FROM wpilib/roborio-cross-ubuntu:2025-24.04
RUN apt-get update && apt-get install -y gcc-multilib dos2unix && rm -rf /var/lib/apt/lists/* 
ADD util/build-luajit-roborio.sh .
RUN dos2unix build-luajit-roborio.sh
COPY deps/luajit ./luajit
RUN cd luajit && sh ../build-luajit-roborio.sh && \
    cd .. && rm -rf luajit && rm -f build-luajit-roborio.sh \
    rm /opt/luabot/linuxathena/bin/luajit && \
    mv /opt/luabot/linuxathena/bin/luajit-2.1.ROLLING \
        /opt/luabot/linuxathena/bin/luajit
