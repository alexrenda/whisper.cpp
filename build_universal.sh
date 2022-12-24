#!/usr/bin/env bash

# cd to the directory of this script
cd "$(dirname "$0")"

function arm(){
    make clean
    cc  -I.              -O3 -std=c11   -fPIC -pthread -DGGML_USE_ACCELERATE   -c ggml.c -o ggml.o
    c++ -I. -I./examples -O3 -std=c++11 -fPIC -pthread -c whisper.cpp -o whisper.o
    c++ -I. -I./examples -O3 -std=c++11 -fPIC -pthread examples/stream/stream.cpp ggml.o whisper.o -o stream  -framework Accelerate -ISDL2.framework/Headers SDL2.framework/SDL2
    install_name_tool -change @rpath/SDL2.framework/Versions/A/SDL2 @executable_path/SDL2.framework/SDL2 stream
    mv stream stream_arm
}

function x86(){
    make clean
    cc -I. -O3 -std=c11 -fPIC -pthread -mfma -mf16c -mavx -mavx2 -DGGML_USE_ACCELERATE -c ggml.c -o ggml.o --target=x86_64-apple-darwin21.6.0
    c++ -I. -I./examples -O3 -std=c++11 -fPIC -pthread -c whisper.cpp -o whisper.o --target=x86_64-apple-darwin21.6.0
    c++ -I. -I./examples -O3 -std=c++11 -fPIC -pthread examples/stream/stream.cpp ggml.o whisper.o -o stream  -framework Accelerate -ISDL2.framework/Headers SDL2.framework/SDL2 --target=x86_64-apple-darwin21.6.0
    install_name_tool -change @rpath/SDL2.framework/Versions/A/SDL2 @executable_path/SDL2.framework/SDL2 stream
    mv stream stream_x86
}


arm
x86

lipo -create stream_arm stream_x86 -output stream
