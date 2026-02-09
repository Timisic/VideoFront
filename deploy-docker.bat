@echo off
REM Docker 镜像本地构建并上传到服务器脚本 (Windows 版本)
REM 使用方法: deploy-docker.bat

echo ========================================
echo 开始构建并部署 Docker 镜像到服务器
echo ========================================

REM 配置 (请根据实际情况修改)
set SERVER=ubuntu@192.168.8.167
set IMAGE_NAME=psychological-assessment
set IMAGE_TAG=latest
set REMOTE_PATH=/home/ubuntu/hwj/

echo.
echo [1/5] 本地构建 Docker 镜像...
docker build -t %IMAGE_NAME%:%IMAGE_TAG% .
if %ERRORLEVEL% NEQ 0 (
    echo 错误: Docker 镜像构建失败
    pause
    exit /b 1
)

echo.
echo [2/5] 保存镜像为文件...
docker save %IMAGE_NAME%:%IMAGE_TAG% -o %IMAGE_NAME%.tar
if %ERRORLEVEL% NEQ 0 (
    echo 错误: 保存镜像失败
    pause
    exit /b 1
)

REM 显示文件大小
for %%A in (%IMAGE_NAME%.tar) do echo    镜像大小: %%~zA 字节

echo.
echo [3/5] 压缩镜像文件...
REM 使用 tar 命令压缩 (Windows 10+ 自带)
tar -czf %IMAGE_NAME%.tar.gz %IMAGE_NAME%.tar
if %ERRORLEVEL% NEQ 0 (
    echo 警告: tar 压缩失败,尝试不压缩直接上传
    goto :upload
)

REM 删除未压缩的 tar 文件
del %IMAGE_NAME%.tar

REM 显示压缩后大小
for %%A in (%IMAGE_NAME%.tar.gz) do echo    压缩后大小: %%~zA 字节

:upload
echo.
echo [4/5] 上传镜像到服务器...
echo 提示: 需要输入服务器密码

REM 检查是否有压缩文件
if exist %IMAGE_NAME%.tar.gz (
    scp %IMAGE_NAME%.tar.gz %SERVER%:%REMOTE_PATH%
    set UPLOAD_FILE=%IMAGE_NAME%.tar.gz
) else (
    scp %IMAGE_NAME%.tar %SERVER%:%REMOTE_PATH%
    set UPLOAD_FILE=%IMAGE_NAME%.tar
)

if %ERRORLEVEL% NEQ 0 (
    echo 错误: 上传失败,请检查网络连接和服务器地址
    pause
    exit /b 1
)

echo.
echo [5/5] 在服务器上部署...
echo 提示: 需要再次输入服务器密码

REM 创建临时脚本文件
echo cd %REMOTE_PATH% > deploy_commands.sh
echo if [ -f %IMAGE_NAME%.tar.gz ]; then >> deploy_commands.sh
echo   echo "解压镜像文件..." >> deploy_commands.sh
echo   gunzip -f %IMAGE_NAME%.tar.gz >> deploy_commands.sh
echo fi >> deploy_commands.sh
echo echo "加载 Docker 镜像..." >> deploy_commands.sh
echo docker load ^< %IMAGE_NAME%.tar >> deploy_commands.sh
echo echo "停止旧容器..." >> deploy_commands.sh
echo docker stop %IMAGE_NAME% 2^>^/dev/null ^|^| true >> deploy_commands.sh
echo docker rm %IMAGE_NAME% 2^>^/dev/null ^|^| true >> deploy_commands.sh
echo echo "启动新容器..." >> deploy_commands.sh
echo docker run -d --name %IMAGE_NAME% -p 20053:20053 --restart unless-stopped --add-host host.docker.internal:host-gateway %IMAGE_NAME%:%IMAGE_TAG% >> deploy_commands.sh
echo echo "清理临时文件..." >> deploy_commands.sh
echo rm %IMAGE_NAME%.tar >> deploy_commands.sh
echo echo "" >> deploy_commands.sh
echo echo "容器状态:" >> deploy_commands.sh
echo docker ps ^| grep %IMAGE_NAME% >> deploy_commands.sh
echo echo "" >> deploy_commands.sh
echo echo "查看日志 (最后 20 行):" >> deploy_commands.sh
echo docker logs %IMAGE_NAME% --tail 20 >> deploy_commands.sh

REM 上传脚本到服务器
scp deploy_commands.sh %SERVER%:%REMOTE_PATH%

REM 在服务器上执行脚本
ssh %SERVER% "bash %REMOTE_PATH%deploy_commands.sh && rm %REMOTE_PATH%deploy_commands.sh"

if %ERRORLEVEL% NEQ 0 (
    echo 错误: 服务器部署失败
    del deploy_commands.sh
    pause
    exit /b 1
)

echo.
echo [清理] 删除本地临时文件...
if exist %IMAGE_NAME%.tar.gz del %IMAGE_NAME%.tar.gz
if exist %IMAGE_NAME%.tar del %IMAGE_NAME%.tar
if exist deploy_commands.sh del deploy_commands.sh

echo.
echo ========================================
echo 部署完成!
echo ========================================
echo.
echo 访问地址: http://192.168.8.167:20053/
echo.
echo 常用命令:
echo   查看日志: ssh %SERVER% "docker logs -f %IMAGE_NAME%"
echo   重启容器: ssh %SERVER% "docker restart %IMAGE_NAME%"
echo   停止容器: ssh %SERVER% "docker stop %IMAGE_NAME%"
echo.
pause
