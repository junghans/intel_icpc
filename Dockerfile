ARG TAG=34
FROM registry.fedoraproject.org/fedora:${TAG}


RUN printf "[oneAPI]\nname=Intel oneAPI\nbaseurl=https://yum.repos.intel.com/oneapi\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://yum.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB" > /etc/yum.repos.d/intel-oneapi.repo && \
dnf -y update && \
dnf -y install intel-oneapi-compiler-dpcpp-cpp intel-oneapi-compiler-dpcpp-cpp-and-cpp-classic intel-oneapi-mkl-devel gcc-c++ git cmake flang && \
dnf clean all

RUN useradd -m -G wheel -u 1001 user
RUN echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER user
#ENV PATH=/opt/intel/oneapi/compiler/latest/linux/bin:/opt/intel/oneapi/compiler/latest/linux/bin/intel64${PATH:+:}${PATH}
#ENV LD_LIBRARY_PATH=/opt/intel/oneapi/compiler/latest/linux/compiler/lib/intel64:/opt/intel/oneapi/mkl/latest/lib/intel64${LD_LIBRARY_PATH:+:}${LD_LIBRARY_PATH}
#WORKDIR /home/user
#RUN printf "#include <vector>\nint main (){\n std::vector<int> foo (3,100);\n std::vector<int> bar;\n foo.swap(bar); return 0; }" > test.cpp
#RUN icpc -g -std=c++14 test.cpp

RUN git clone --branch develop https://github.com/kokkos/kokkos
WORKDIR kokkos
RUN cmake -S . -B build -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_Fortran_COMPILER=flang -DKokkos_ENABLE_TESTS=ON
RUN cmake --build build
