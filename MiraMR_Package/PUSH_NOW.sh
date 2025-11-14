#!/bin/bash
# MiraMR 一键推送脚本
# 在您的本地终端运行这个脚本

cd /home/user/MiraMR

echo "正在推送 MiraMR 到 GitHub..."
echo "仓库: https://github.com/mtmmu88/MiraMR"
echo ""

# 推送到 main 分支
git push -u origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 推送成功！"
    echo "访问: https://github.com/mtmmu88/MiraMR"
    echo ""
    echo "下一步："
    echo "1. 设置为 Private: https://github.com/mtmmu88/MiraMR/settings"
    echo "2. 在 Danger Zone 点击 'Change repository visibility'"
    echo "3. 选择 'Make private'"
else
    echo ""
    echo "❌ 推送失败"
    echo "可能需要 GitHub Personal Access Token"
    echo "访问: https://github.com/settings/tokens"
fi
