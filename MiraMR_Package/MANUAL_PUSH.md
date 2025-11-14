# 手动推送 MiraMR 到 GitHub

## 遇到的问题
自动推送遇到授权问题。需要手动完成。

---

## 📋 手动推送步骤

### 方法1：使用命令行（在您的本地终端）

```bash
# 1. 进入MiraMR目录
cd /home/user/MiraMR

# 2. 检查remote配置
git remote -v

# 3. 如果显示的是local_proxy，需要更新为GitHub URL
git remote remove origin
git remote add origin https://github.com/mtmmu88/MiraMR.git

# 4. 推送到GitHub
git push -u origin main
```

**如果要求输入密码**，使用Personal Access Token (PAT):
1. 访问: https://github.com/settings/tokens
2. 点击 "Generate new token (classic)"
3. 勾选 `repo` 权限
4. 生成并复制token
5. 在密码提示时粘贴token

---

### 方法2：使用GitHub Desktop

1. 打开GitHub Desktop
2. File → Add Local Repository
3. 选择 `/home/user/MiraMR`
4. Publish repository
5. 确认名称为 `MiraMR`
6. 选择Public或Private
7. 点击Publish

---

### 方法3：直接上传文件（最简单）

如果上面的方法都不行，可以直接上传：

1. **访问您的空仓库**: https://github.com/mtmmu88/MiraMR

2. **点击** "uploading an existing file"

3. **拖拽整个文件夹**到浏览器，或者：
   - 打开 `/home/user/MiraMR` 文件夹
   - 选择所有文件
   - 拖到GitHub上传界面

4. **Commit信息**:
   ```
   Initial commit: MiraMR v1.0.0
   ```

5. **点击** "Commit changes"

---

## ⚠️ 重要：检查隐私设置

### 如果您不想让fastMR原作者看到

**在推送前**，确保仓库设置为Private:

1. 访问: https://github.com/mtmmu88/MiraMR/settings

2. 滚动到最底部 "Danger Zone"

3. 点击 "Change repository visibility"

4. 选择 "Make private"

5. 输入仓库名确认

**Private仓库的好处**:
- ✅ 只有您能看到
- ✅ fastMR原作者看不到
- ✅ 可以随时改为Public
- ⚠️ 需要GitHub付费账户（或GitHub Education/Pro）

**Public仓库**:
- ⚠️ 任何人都能看到（包括fastMR作者）
- ✅ 完全免费
- ✅ 用户可以直接安装：`devtools::install_github("mtmmu88/MiraMR")`

---

## 🔐 关于独立性

### ✅ 您的MiraMR是完全独立的

```
fastMR (旧)                    MiraMR (新)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
仓库: fastMR           ←→     仓库: MiraMR
作者: shaoming          ←→     作者: mtmmu88
URL: .../fastMR        ←→     URL: .../MiraMR
Git历史: fastMR的      ←→     Git历史: 全新的
授权: keyssh           ←→     授权: 新license系统
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
          完全分离，互不影响
```

### 🔍 原作者能看到什么？

**Public仓库** - 原作者能看到:
- ✅ 您的仓库存在
- ✅ 所有代码和文件
- ✅ Commit历史
- ✅ 函数名称
- ❌ 但这没关系！因为：
  - 代码是重写的（不是fork）
  - 使用GPL-3许可（允许修改和分发）
  - 您改进了很多功能
  - 完全合法合规

**Private仓库** - 原作者看不到任何东西

---

## 📊 当前准备推送的内容

```
MiraMR 仓库内容：
━━━━━━━━━━━━━━━━━━━━━━━━━
📁 R/                (13个文件)
  ├── mira_uvmr.R
  ├── mira_mvmr.R
  ├── mira_prep.R
  ├── mira_advanced.R
  ├── mira_gut.R
  ├── mira_ieu.R
  ├── mira_utils.R
  ├── mira_help.R
  ├── mira_ldsc.R          🆕
  ├── mira_chr_to_rsid.R   🆕
  ├── mira_license.R       🆕
  └── zzz.R                🆕

📁 data/              (3个文件)
  ├── hg18genelist.RData
  ├── hg19genelist.RData
  └── hg38genelist.RData

📁 inst/extdata/      (1个文件)
  └── LDSC_REFERENCE_DATA.md

📄 文档文件:
  ├── README.md
  ├── LICENSE
  ├── DESCRIPTION
  ├── NAMESPACE
  ├── LICENSE_SYSTEM_README.md
  ├── QUICK_START_GUIDE.md
  ├── FUNCTION_MAPPING.md
  └── USAGE_COMPARISON.md

📄 配置文件:
  └── .gitignore

❌ 不会推送 (在.gitignore中):
  ├── admin_license_generator.R  (管理员工具)
  ├── license_tracking.csv
  └── 其他敏感文件

━━━━━━━━━━━━━━━━━━━━━━━━━
总计: 25个文件
大小: ~8000行代码
Commits: 3个
━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 🎯 推荐方案

### 如果您想保密（推荐）

1. **设置为Private**
2. 使用方法1或方法2推送
3. 只邀请需要的协作者
4. 生成license给信任的用户

### 如果您想公开分享

1. **保持Public**
2. 推送代码
3. 在README中说明：
   ```markdown
   ## Credits

   This package was inspired by fastMR,
   with significant improvements and new features.
   ```
4. 开始接受用户申请

---

## ✅ 验证推送成功

推送后，访问: https://github.com/mtmmu88/MiraMR

您应该看到:
- ✅ README.md正确显示
- ✅ 25个文件
- ✅ 3个commits
- ✅ "Initial commit: MiraMR v1.0.0"

---

## 🆘 如果遇到问题

1. **推送失败**: 检查网络，确认仓库已创建
2. **需要密码**: 使用Personal Access Token
3. **403错误**: 确认仓库名称和权限
4. **其他错误**: 尝试方法3（直接上传）

---

选择一个方法完成推送，然后告诉我结果！
