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

FROM gcr.io/fuzzbench/base-image

RUN apt update && \
    apt install -y wget && \
    wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc && \
    echo -e "deb http://apt.llvm.org/focal/ llvm-toolchain-focal-12 main \
    \\ndeb-src http://apt.llvm.org/focal/ llvm-toolchain-focal-12 main \
    \\n\\ndeb http://apt.llvm.org/focal/ llvm-toolchain-focal-15 main \
    \ndeb-src http://apt.llvm.org/focal/ llvm-toolchain-focal-15 main \
    \n\ndeb http://apt.llvm.org/focal/ llvm-toolchain-focal-17 main \
    \ndeb-src http://apt.llvm.org/focal/ llvm-toolchain-focal-17 main" |tee /etc/apt/sources.list.d/llvm.list && \
    apt update && \
    apt install -y clang-12 clang-15 clang-17 && \
    apt install -y libc++-12-dev && \ 
    apt install -y libc++-15-dev && \
    apt install -y libc++-17-dev

RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install torch torchvision torchaudio
COPY requireements.txt /
RUN python3 -m pip install -r /requirements.txt

ENV PATH="${PATH}:/usr/lib/llvm-12/bin"
ENV LD_LIBRARY_PATH="/usr/lib/llvm-12/lib:${LD_LIBRARY_PATH}"