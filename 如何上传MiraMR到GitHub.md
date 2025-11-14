# 如何上传 MiraMR 到 GitHub

## 您的代码位置

- **完整目录**: `/home/user/MiraMR/`
- **压缩包**: `/home/user/MiraMR_complete_package.tar.gz` (1.6MB)
- **备份压缩包**: `/home/user/fastMR/MiraMR_complete_package.tar.gz`

---

## 方法1：一键推送脚本（最快）⚡

**如果您能访问本地终端并有GitHub权限**：

```bash
cd /home/user/MiraMR
bash PUSH_NOW.sh
```

这会自动推送到 `https://github.com/mtmmu88/MiraMR`

---

## 方法2：手动命令行推送

```bash
cd /home/user/MiraMR

# 推送到 main 分支
git push -u origin main
```

**如果要求密码**，使用 Personal Access Token:
1. 访问: https://github.com/settings/tokens
2. Generate new token (classic)
3. 勾选 `repo` 权限
4. 复制 token
5. 推送时用 token 作为密码

---

## 方法3：浏览器上传（最简单，不需要命令行）

### 步骤1：解压文件

```bash
cd /home/user
tar -xzf MiraMR_complete_package.tar.gz
```

### 步骤2：访问您的仓库

https://github.com/mtmmu88/MiraMR

### 步骤3：上传文件

1. 点击 **"uploading an existing file"** 或 **"Add file" → "Upload files"**
2. 拖拽 `/home/user/MiraMR/` 目录中的所有文件
   - ❌ 不要上传 `.git` 文件夹
   - ❌ 不要上传 `admin_license_generator.R`（已在.gitignore中）
   - ✅ 上传其他所有文件
3. Commit message: `Initial commit: MiraMR v1.0.0 - For Mira`
4. 点击 **"Commit changes"**

---

## 文件清单（您有这些文件）

### 📁 R代码文件 (12个)
- mira_uvmr.R - UVMR分析
- mira_mvmr.R - MVMR分析
- mira_prep.R - 数据预处理
- mira_advanced.R - 高级分析
- mira_gut.R - 肠道微生物
- mira_ieu.R - IEU数据库
- mira_utils.R - 工具函数
- mira_help.R - 帮助系统
- mira_ldsc.R - LDSC分析 🆕
- mira_chr_to_rsid.R - CHR:BP转rsID 🆕
- mira_license.R - License系统 🆕
- zzz.R - 包加载钩子

### 📁 数据文件 (3个)
- hg18genelist.RData
- hg19genelist.RData
- hg38genelist.RData

### 📄 文档文件
- README.md - 包介绍（致敬Mira和Candice）
- LICENSE - GPL-3许可证
- DESCRIPTION - 包描述
- NAMESPACE - 命名空间
- LICENSE_SYSTEM_README.md - License使用指南
- QUICK_START_GUIDE.md - 快速开始
- FUNCTION_MAPPING.md - 函数对照表
- USAGE_COMPARISON.md - 使用对比
- SET_PRIVATE_GUIDE.md - Private仓库设置

### 🔧 配置文件
- .gitignore - Git忽略规则
- PUSH_NOW.sh - 一键推送脚本

---

## ⚠️ 上传后立即操作

### 1. 设置为 Private（重要！）

1. 访问: https://github.com/mtmmu88/MiraMR/settings
2. 滚动到 **"Danger Zone"**
3. 点击 **"Change repository visibility"**
4. 选择 **"Make private"**
5. 输入 `mtmmu88/MiraMR` 确认

### 2. 验证上传成功

访问: https://github.com/mtmmu88/MiraMR

应该看到:
- ✅ README显示完整内容
- ✅ R/ 目录有12个文件
- ✅ data/ 目录有3个文件
- ✅ 所有文档文件

### 3. 测试安装

```r
# 先设置为 Private 并邀请自己为协作者
# 然后测试安装
devtools::install_github("mtmmu88/MiraMR")
library(MiraMR)
```

---

## 🆘 常见问题

**Q: 为什么 Claude 不能直接推送？**

A: Claude 运行的环境没有您的 GitHub 登录凭证，所以无法代替您推送。需要在您有 GitHub 权限的地方执行。

**Q: 我看不到 `/home/user/` 目录怎么办？**

A: 使用压缩包文件：
- 在当前目录: `MiraMR_complete_package.tar.gz`
- 解压: `tar -xzf MiraMR_complete_package.tar.gz`
- 然后使用方法3上传

**Q: 推送失败提示404或403？**

A:
1. 确认仓库已创建: https://github.com/mtmmu88/MiraMR
2. 确认您有权限（是仓库owner）
3. 使用 Personal Access Token 而不是密码

---

## ✅ 完成检查清单

- [ ] 代码已上传到 GitHub
- [ ] 访问 https://github.com/mtmmu88/MiraMR 能看到文件
- [ ] 仓库已设置为 Private
- [ ] 测试安装成功
- [ ] README 正确显示（包含致敬Mira和Candice）

---

**需要帮助？** 告诉我您用的是哪个方法，遇到了什么问题！
