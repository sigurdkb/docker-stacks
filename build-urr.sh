REG=urr.uia.no
CUDA_10_0=nvidia_cuda_10.0-cudnn7-devel
CUDA_10_1=nvidia_cuda_10.1-cudnn7-devel


# Build base-notebook
cd ./base-notebook
docker build -t $REG/jupyter/base-notebook .
docker build -t $REG/jupyter/base-notebook:$CUDA_10_0 --build-arg BASE_CONTAINER=nvidia/cuda:10.0-cudnn7-devel .
docker build -t $REG/jupyter/base-notebook:$CUDA_10_1 --build-arg BASE_CONTAINER=nvidia/cuda:10.1-cudnn7-devel .
cd ..

# Build minimal-notebook
cd ./minimal-notebook
docker build -t $REG/jupyter/minimal-notebook --build-arg BASE_CONTAINER=$REG/jupyter/base-notebook .
docker build -t $REG/jupyter/minimal-notebook:$CUDA_10_0 --build-arg BASE_CONTAINER=$REG/jupyter/base-notebook:$CUDA_10_0 .
docker build -t $REG/jupyter/minimal-notebook:$CUDA_10_1 --build-arg BASE_CONTAINER=$REG/jupyter/base-notebook:$CUDA_10_1 .
cd ..

# Build scipy-notebook
cd ./scipy-notebook
docker build -t $REG/jupyter/scipy-notebook --build-arg BASE_CONTAINER=$REG/jupyter/minimal-notebook .
docker build -t $REG/jupyter/scipy-notebook:$CUDA_10_0 --build-arg BASE_CONTAINER=$REG/jupyter/minimal-notebook:$CUDA_10_0 .
docker build -t $REG/jupyter/scipy-notebook:$CUDA_10_1 --build-arg BASE_CONTAINER=$REG/jupyter/minimal-notebook:$CUDA_10_1 .
cd ..

# Build tensorflow-v1-notebook
cd ./tensorflow-v1-notebook
docker build -t $REG/jupyter/tensorflow-v1-notebook --build-arg BASE_CONTAINER=$REG/jupyter/scipy-notebook .
cd ..

# Build tensorflow-v2-notebook
cd ./tensorflow-v2-notebook
docker build -t $REG/jupyter/tensorflow-v2-notebook --build-arg BASE_CONTAINER=$REG/jupyter/scipy-notebook .
cd ..

# Build tensorflow-v1-gpu-notebook
cd ./tensorflow-v1-gpu-notebook
docker build -t $REG/jupyter/tensorflow-v1-gpu-notebook:$CUDA_10_0 --build-arg BASE_CONTAINER=$REG/jupyter/scipy-notebook:$CUDA_10_0 .
cd ..

# Build tensorflow-v2-gpu-notebook
cd ./tensorflow-v2-gpu-notebook
docker build -t $REG/jupyter/tensorflow-v2-gpu-notebook:$CUDA_10_1 --build-arg BASE_CONTAINER=$REG/jupyter/scipy-notebook:$CUDA_10_1 .
cd ..
