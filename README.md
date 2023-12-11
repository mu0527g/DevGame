## 环境编译

### 1. 安装
```bash
# 克隆项目
git clone https://github.com/mu0527g/DevGame.git

# 进入目录
cd DevGame

# 初始化子模块
git submodule update --init --recursive
```

### 2. 编译
```bash
# 进入目录
cd skynet

# 编译
make linux

# 进入目录
cd ../lsocket

# 编译
make
```

### 3. 运行
```bash
# 启动服务端
sh startup.sh

# 关闭服务端
sh stop.sh
```