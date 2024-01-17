# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# localhost:5000/alfuzz/builder:base
ARG parent_image
FROM $parent_image

ENV PATH="${PATH}:/usr/lib/llvm-12/bin"

RUN apt install build-essential libssl-dev
# RUN apt install clang-12 clang-15 clang-17 libc++-12-dev libc++-15-dev libc++-17-dev

# Download and compile ALFUZZ.
# Set AFL_NO_X86 to skip flaky tests.
RUN git clone \
    --depth 1 \
    --branch test \
    git@host.docker.internal:git-server/ALFUZZ.git /alfuzz && \
    cd /alfuzz/fuzzer && \
    CC=clang CFLAGS= CXXFLAGS= AFL_NO_X86=1 make && \
    CC=clang make -C /alfuzz/fuzzer/module/llvm_mode

# Use afl_driver.cpp from LLVM as our fuzzing library.
RUN apt-get update && \
    apt-get install wget -y && \
    wget https://raw.githubusercontent.com/llvm/llvm-project/5feb80e748924606531ba28c97fe65145c65372e/compiler-rt/lib/fuzzer/afl/afl_driver.cpp -O /alfuzz/fuzzer/afl_driver.cpp && \
    clang -Wno-pointer-sign -c /alfuzz/fuzzer/llvm_mode/afl-llvm-rt.o.c -I/alfuzz/fuzzer && \
    clang++ -stdlib=libc++ -std=c++11 -O2 -c /alfuzz/fuzzer/afl_driver.cpp && \
    ar r /libAFL.a *.o
