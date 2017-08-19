FROM  ubuntu:16.04

RUN apt-get -qq update
#RUN apt-get install -y -qq --no-install-recommends curl python build-essential cmake
RUN apt-get install -y -qq curl python build-essential cmake

RUN mkdir -p /opt/emsdk \
  && cd /opt/emsdk \
  && curl -L 'https://s3.amazonaws.com/mozilla-games/emscripten/releases/emsdk-portable.tar.gz' | tar xvzf - \
  && cd emsdk-portable \
  && ./emsdk update \
  && ./emsdk install latest \
  && ./emsdk activate latest \
  && /bin/bash ./emsdk_env.sh
  
# Setting env
SHELL ["/bin/bash", "-c"]
RUN source /opt/emsdk/emsdk-portable/emsdk_env.sh \ 
  && echo "PATH=$PATH">>~/env.txt \
  && echo "EMSDK=$EMSDK">>~/env.txt \
  && echo "EM_CONFIG=$EM_CONFIG">>~/env.txt \
  && echo "EMSCRIPTEN=$EMSCRIPTEN">>~/env.txt
ENV BASH_ENV ~/env.txt

RUN cd /opt/emsdk/emsdk-portable/ \
  && rm -rf ./clang/tag-*/src \
  && rm -rf ./emscripten/tag-*/tests \
  && rm -rf ./emscripten/tag-*/site \
  && rm -rf ./emscripten/tag-*/docs \
  && rm -rf ./zips \
  && find . -name "*.o" -exec rm {} \; \
  && find . -name "*.a" -exec rm {} \; \
  && find . -name "*.tmp" -exec rm {} \; \
  && apt-get -y --purge remove curl \
  && apt-get -y autoremove \
  && apt-get clean

COPY entrypoint.sh /opt/entrypoint.sh

ENTRYPOINT ["/opt/entrypoint.sh"]
CMD /bin/bash

WORKDIR /src
