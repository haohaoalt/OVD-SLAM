#!/bin/bash

CLEAN_PREVIOUS_BUILD=false

# 获取当前路径
CURRENT_PATH=$(pwd)

# 处理参数
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -c|--clean)
            CLEAN_PREVIOUS_BUILD=true
            shift
            ;;
        *)
            echo "Unknown parameter: $1"
            exit 1
            ;;
    esac
done

# 清理之前的构建产物
if [ "$CLEAN_PREVIOUS_BUILD" = true ]; then
    echo "Cleaning previous build artifacts..."

    rm -rf Thirdparty/DBoW2/build
    rm -rf Thirdparty/g2o/build
    rm -rf Thirdparty/Sophus/build
    rm -rf Thirdparty/yolov5_tensorrtx/build
    rm -rf Examples/ROS/ORB_SLAM3/build
    rm -rf build
fi

echo "Configuring and building Thirdparty/DBoW2 ..."

cd Thirdparty/DBoW2
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j8

cd ../../g2o

echo "Configuring and building Thirdparty/g2o ..."

mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j8

cd ../../Sophus

echo "Configuring and building Thirdparty/Sophus ..."

mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j8

cd ../../yolov5_tensorrtx

echo "Configuring and building Thirdparty/yolov5_tensorrtx ..."

mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j8

cd ../../..

#echo "Uncompress vocabulary ..."

#cd Vocabulary
#tar -xf ORBvoc.txt.tar.gz
#cd ..

echo "Configuring and building ORB_SLAM3 ..."

mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j8

# 打印更新前的 ROS_PACKAGE_PATH
echo "ROS_PACKAGE_PATH: ${ROS_PACKAGE_PATH}"

# 函数用于判断软件包是否存在，并更新 ROS_PACKAGE_PATH
update_ros_package_path() {
    export ROS_PACKAGE_PATH=${ROS_PACKAGE_PATH}:${CURRENT_PATH}/Examples/ROS
    echo "Updated ROS_PACKAGE_PATH: ${ROS_PACKAGE_PATH}"
}

# 软件包名称
PACKAGE_NAME="ORB_SLAM3"

# 在报错时手动调用该函数
# 示例：假设在报错时调用 update_ros_package_path 函数
if [ ! -d "$(rospack find ${PACKAGE_NAME} 2>/dev/null)" ]; then
    echo "Error: Package '${PACKAGE_NAME}' not found. Manually updating ROS_PACKAGE_PATH..."
    update_ros_package_path
fi

# 清理之前的构建产物
if [ "$CLEAN_PREVIOUS_BUILD" = true ]; then
    echo "Cleaning previous build artifacts..."

    rm -rf Examples/ROS/ORB_SLAM3/build
fi


echo "Building ROS nodes"

cd ../Examples/ROS/ORB_SLAM3
mkdir build
cd build
cmake .. -DROS_BUILD_TYPE=Release
make -j16
