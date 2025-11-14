# 设置MiraMR为私有仓库指南

## 🔐 设置为Private

### 步骤1：访问设置页面
https://github.com/mtmmu88/MiraMR/settings

### 步骤2：更改可见性
1. 滚动到页面底部 **"Danger Zone"**
2. 找到 **"Change repository visibility"**
3. 点击 **"Change visibility"**
4. 选择 **"Make private"**
5. 输入 `mtmmu88/MiraMR` 确认
6. 点击确认按钮

✅ 完成！现在仓库是私有的。

---

## 👥 添加授权用户（协作者）

### 每次有新用户申请license时：

#### 步骤1：访问访问控制页面
https://github.com/mtmmu88/MiraMR/settings/access

#### 步骤2：邀请协作者
1. 点击 **"Invite a collaborator"** 绿色按钮
2. 输入用户的：
   - GitHub用户名，或
   - GitHub注册邮箱
3. 点击 **"Add [username] to this repository"**
4. 选择权限：**Read**（只读，足够安装）

#### 步骤3：发送邀请邮件给用户

邮件模板：
```
主题: MiraMR License 激活 - GitHub访问邀请

您好 [用户名]，

您的MiraMR访问申请已批准！

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 安装和激活步骤：
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. 接受GitHub协作者邀请
   - 检查您的GitHub账号关联的邮箱
   - 或访问：https://github.com/mtmmu88/MiraMR/invitations
   - 点击 "Accept invitation"

2. 安装MiraMR包
   在R中运行：

   devtools::install_github("mtmmu88/MiraMR")

3. 激活您的license

   MiraMR::mira_activate("[用户的license_key]")

4. 开始使用

   library(MiraMR)
   mira_help()

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 License信息：
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

用户: [姓名]
邮箱: [邮箱]
有效期: [到期日期]
机器ID: [前16位]...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

如有问题，请回复此邮件。

祝使用愉快！
mtmmu88
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 🔄 完整授权流程

### 用户端：

```
1. 发送申请邮件
   ↓
2. 收到两封邮件：
   - GitHub协作者邀请
   - 您的license激活邮件
   ↓
3. 接受GitHub邀请
   ↓
4. 安装包：devtools::install_github("mtmmu88/MiraMR")
   ↓
5. 激活license：MiraMR::mira_activate("key")
   ↓
6. 使用：library(MiraMR)
```

### 管理员端（您）：

```
1. 收到申请
   ↓
2. 生成license key
   source("admin_license_generator.R")
   或
   library(MiraMR)
   license <- mira_generate_license(...)
   ↓
3. 添加为GitHub协作者
   GitHub → Settings → Manage Access → Invite
   ↓
4. 发送邮件（包含license key和安装说明）
   ↓
5. 记录到tracking表
   (可选，便于管理)
```

---

## 📊 协作者管理

### 查看当前协作者
https://github.com/mtmmu88/MiraMR/settings/access

### 移除协作者（如果需要）
1. 访问上面的链接
2. 找到用户
3. 点击 "Remove" 按钮
4. 确认移除

**注意**：移除后用户将无法：
- 访问仓库代码
- 更新包（无法重新安装）
- 但已安装的包仍能使用（如果license未过期）

---

## 🔍 权限级别说明

### Read（只读）- 推荐给用户
- ✅ 可以查看代码
- ✅ 可以安装包
- ✅ 可以克隆仓库
- ❌ 不能修改代码
- ❌ 不能push
- ❌ 不能修改设置

### Write（读写）- 不推荐
- ⚠️ 可以修改代码
- ⚠️ 可以push
- ⚠️ 风险较大

### Admin（管理员）- 只给信任的人
- ⚠️⚠️ 可以做任何事
- ⚠️⚠️ 包括删除仓库

**建议**：普通用户只给 **Read** 权限

---

## 🎯 批量管理（如果用户很多）

### 创建Team（推荐20+用户时）

1. 访问: https://github.com/orgs/[您的组织]/teams
   （如果没有组织，需要先创建）

2. 创建Team：
   - Team name: "MiraMR Users"
   - Description: "Authorized MiraMR users"
   - Visibility: Secret

3. 添加仓库到Team：
   - 权限：Read

4. 批量添加成员到Team

**优点**：
- 一次性管理多个用户
- 方便统一权限
- 易于添加/移除

---

## ⚠️ 重要提醒

### Private仓库限制

**GitHub Free账户**：
- ✅ 可以创建无限Private仓库
- ✅ 可以添加无限协作者
- ✅ 完全免费！

**GitHub Pro/Team/Enterprise**：
- 更多高级功能
- 但对于MiraMR，Free账户完全够用

### 用户需求

使用Private仓库安装，用户**必须有**：
- ✅ GitHub账户（免费）
- ✅ 接受协作者邀请
- ✅ 在R中配置GitHub认证（通常自动）

---

## 📝 用户常见问题

### Q: 安装时提示 "HTTP error 404"

**A**: 用户需要：
1. 确认已接受GitHub邀请
2. 重新登录GitHub
3. 可能需要设置PAT：
   ```r
   credentials::set_github_pat()
   ```

### Q: 能看到仓库但无法安装

**A**: 检查：
1. 用户权限是否为Read
2. 用户是否登录GitHub
3. R的devtools包是否最新

### Q: 更新包时失败

**A**:
```r
# 卸载旧版
remove.packages("MiraMR")

# 重新安装
devtools::install_github("mtmmu88/MiraMR")
```

---

## ✅ 检查清单

设置Private仓库后，确认：

- [ ] 仓库已设置为Private
- [ ] 可以看到🔒图标
- [ ] 访问 Settings → Manage Access 正常
- [ ] 测试邀请一个用户（可以用小号测试）
- [ ] 确认用户可以安装
- [ ] 确认非协作者无法访问

---

## 🎉 完成！

现在您有：
- 🔒 私有仓库（代码保密）
- 👥 授权用户可安装
- 🔐 License系统控制使用
- 📊 完整的访问控制

**双重保护**：
1. GitHub协作者 → 控制谁能安装
2. License系统 → 控制谁能使用

完美！🎯
