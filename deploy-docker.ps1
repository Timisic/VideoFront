# Docker 镜像本地构建并上传到服务器脚本 (PowerShell 版本)
# 使用方法: .\deploy-docker.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "开始构建并部署 Docker 镜像到服务器" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 配置 (请根据实际情况修改)
$SERVER = "ubuntu@192.168.8.167"
$IMAGE_NAME = "psychological-assessment"
$IMAGE_TAG = "latest"
$REMOTE_PATH = "/home/ubuntu/hwj/"

# 1. 本地构建镜像
Write-Host "`n[1/5] 本地构建 Docker 镜像..." -ForegroundColor Yellow
docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" .
if ($LASTEXITCODE -ne 0) {
    Write-Host "错误: Docker 镜像构建失败" -ForegroundColor Red
    Read-Host "按任意键退出"
    exit 1
}

# 2. 保存镜像为文件
Write-Host "`n[2/5] 保存镜像为文件..." -ForegroundColor Yellow
docker save "${IMAGE_NAME}:${IMAGE_TAG}" -o "${IMAGE_NAME}.tar"
if ($LASTEXITCODE -ne 0) {
    Write-Host "错误: 保存镜像失败" -ForegroundColor Red
    Read-Host "按任意键退出"
    exit 1
}

$fileSize = (Get-Item "${IMAGE_NAME}.tar").Length
Write-Host "   镜像大小: $([math]::Round($fileSize/1MB, 2)) MB" -ForegroundColor Gray

# 3. 压缩镜像文件
Write-Host "`n[3/5] 压缩镜像文件..." -ForegroundColor Yellow
try {
    # 使用 tar 命令压缩 (Windows 10+ 自带)
    tar -czf "${IMAGE_NAME}.tar.gz" "${IMAGE_NAME}.tar"
    Remove-Item "${IMAGE_NAME}.tar"
    
    $compressedSize = (Get-Item "${IMAGE_NAME}.tar.gz").Length
    Write-Host "   压缩后大小: $([math]::Round($compressedSize/1MB, 2)) MB" -ForegroundColor Gray
    $uploadFile = "${IMAGE_NAME}.tar.gz"
} catch {
    Write-Host "   警告: 压缩失败,使用未压缩文件上传" -ForegroundColor Yellow
    $uploadFile = "${IMAGE_NAME}.tar"
}

# 4. 上传到服务器
Write-Host "`n[4/5] 上传镜像到服务器..." -ForegroundColor Yellow
Write-Host "提示: 需要输入服务器密码" -ForegroundColor Cyan

scp $uploadFile "${SERVER}:${REMOTE_PATH}"
if ($LASTEXITCODE -ne 0) {
    Write-Host "错误: 上传失败,请检查网络连接和服务器地址" -ForegroundColor Red
    Read-Host "按任意键退出"
    exit 1
}

# 5. 在服务器上部署
Write-Host "`n[5/5] 在服务器上部署..." -ForegroundColor Yellow
Write-Host "提示: 需要再次输入服务器密码" -ForegroundColor Cyan

# 创建部署命令
$deployCommands = @"
cd ${REMOTE_PATH}

if [ -f ${IMAGE_NAME}.tar.gz ]; then
  echo "解压镜像文件..."
  gunzip -f ${IMAGE_NAME}.tar.gz
fi

echo "加载 Docker 镜像..."
docker load < ${IMAGE_NAME}.tar

echo "停止旧容器..."
docker stop ${IMAGE_NAME} 2>/dev/null || true
docker rm ${IMAGE_NAME} 2>/dev/null || true

echo "启动新容器..."
docker run -d \
  --name ${IMAGE_NAME} \
  -p 20053:20053 \
  --restart unless-stopped \
  --add-host host.docker.internal:host-gateway \
  ${IMAGE_NAME}:${IMAGE_TAG}

echo "清理临时文件..."
rm ${IMAGE_NAME}.tar

echo ""
echo "容器状态:"
docker ps | grep ${IMAGE_NAME}

echo ""
echo "查看日志 (最后 20 行):"
docker logs ${IMAGE_NAME} --tail 20
"@

# 保存到临时文件
$deployCommands | Out-File -FilePath "deploy_commands.sh" -Encoding ASCII

# 上传脚本到服务器
scp deploy_commands.sh "${SERVER}:${REMOTE_PATH}"

# 在服务器上执行
ssh $SERVER "bash ${REMOTE_PATH}deploy_commands.sh && rm ${REMOTE_PATH}deploy_commands.sh"

if ($LASTEXITCODE -ne 0) {
    Write-Host "错误: 服务器部署失败" -ForegroundColor Red
    Remove-Item "deploy_commands.sh" -ErrorAction SilentlyContinue
    Read-Host "按任意键退出"
    exit 1
}

# 6. 清理本地文件
Write-Host "`n[清理] 删除本地临时文件..." -ForegroundColor Yellow
Remove-Item "${IMAGE_NAME}.tar.gz" -ErrorAction SilentlyContinue
Remove-Item "${IMAGE_NAME}.tar" -ErrorAction SilentlyContinue
Remove-Item "deploy_commands.sh" -ErrorAction SilentlyContinue

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "部署完成!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "`n访问地址: http://192.168.8.167:20053/" -ForegroundColor Cyan
Write-Host "`n常用命令:" -ForegroundColor Yellow
Write-Host "  查看日志: ssh ${SERVER} `"docker logs -f ${IMAGE_NAME}`"" -ForegroundColor Gray
Write-Host "  重启容器: ssh ${SERVER} `"docker restart ${IMAGE_NAME}`"" -ForegroundColor Gray
Write-Host "  停止容器: ssh ${SERVER} `"docker stop ${IMAGE_NAME}`"" -ForegroundColor Gray
Write-Host ""

Read-Host "按任意键退出"
