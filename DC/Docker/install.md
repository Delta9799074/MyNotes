# install

1. 安装win10 Docker & wsl2
2. docker换镜像源
    
    右上角settings —>docker engine —> 复制下面的代码到框里 —> apply & restart
    
    > {
    "features": {
    "buildkit": true
    },
    "experimental": true,
    "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "http://hub-mirror.c.163.com",
    "https://registry.docker-cn.com"
    ]
    }
    > 
3. move docker from C:\
    1. 创建目录D:\SoftwareData\wsl\docker-desktop-data
    2. windows powershell输入wsl -l -v，查看docker
    3. powershell：>wsl --shutdown >wsl --export docker-desktop-data D:\SoftwareData\wsl\docker-desktop-data\docker-desktop-data.tar > wsl --unregister docker-desktop-data > wsl --import docker-desktop-data D:\SoftwareData\wsl\docker-desktop-data\ D:\SoftwareData\wsl\docker-desktop-data\docker-desktop-data.tar --version 2
4. Check Docker正常工作
    
    powershell > docker run hello-world 
    
5. 拉取synopsys2016镜像
    
    powershell > docker pull phyzli/ubuntu18.04_xfce4_vnc4server_synopsys2016