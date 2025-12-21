FROM wpilib/roborio-cross-ubuntu:2025-24.04
RUN apt-get update && apt-get install -y gcc-multilib dos2unix git && rm -rf /var/lib/apt/lists/* 
ADD util/build-luajit-roborio.sh .
RUN dos2unix build-luajit-roborio.sh
RUN git clone --depth=1 https://github.com/LuaJIT/LuaJIT.git luajit && \
    cd luajit && \
    git checkout 7152e15489d2077cd299ee23e3d51a4c599ab14f && \
    sh ../build-luajit-roborio.sh && \
    cd .. && rm -rf luajit && rm -f build-luajit-roborio.sh \
    rm /opt/luabot/linuxathena/bin/luajit
