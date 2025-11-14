# MiraMR 使用对比：fastMR → MiraMR

## 快速对照表

### ✅ 好消息：使用方法基本不变！

唯一的区别是**函数名称**改了，但**参数和用法完全一样**。

---

## 🔄 使用对比示例

### 1. Univariable MR (UVMR)

#### fastMR (旧)
```r
library(fastMR)

result <- stand_UVMR_local_local(
  expgwas = exposure_data,
  outgwas = outcome_data,
  outputpath = "results",
  RegistID_dat = your_key  # 需要授权
)
```

#### MiraMR (新)
```r
library(MiraMR)  # 已经在加载时验证license，不需要额外参数

result <- mira_uvmr_local_local(
  exposure_gwas = exposure_data,    # 参数名更清晰
  outcome_gwas = outcome_data,
  output_dir = "results"
)
```

**改进**：
- ✅ 函数名更清晰：`mira_uvmr_local_local`
- ✅ 参数名更规范：`exposure_gwas` vs `expgwas`
- ✅ 不需要每次传 `RegistID_dat`
- ✅ 使用方法完全相同

---

### 2. 数据预处理

#### fastMR (旧)
```r
# 炎症因子预处理
data <- infla_factor_pre(
  inputdir = "raw_data",
  outputdir = "processed",
  asexp = TRUE,
  pthreshold = 5e-8,
  RegistID_dat = your_key
)

# 免疫细胞预处理
data <- inmm_cell_pre(
  inputdir = "raw_data",
  outputdir = "processed",
  asexp = TRUE,
  RegistID_dat = your_key
)
```

#### MiraMR (新)
```r
# 炎症因子预处理
data <- mira_prep_inflammatory(
  input_dir = "raw_data",
  output_dir = "processed",
  as_exposure = TRUE,
  p_threshold = 5e-8
)

# 免疫细胞预处理
data <- mira_prep_immune(
  input_dir = "raw_data",
  output_dir = "processed",
  as_exposure = TRUE
)
```

**改进**：
- ✅ 统一前缀：`mira_prep_*`
- ✅ 参数用下划线：`as_exposure` vs `asexp`
- ✅ 不需要授权参数

---

### 3. IEU数据转换

#### fastMR (旧)
```r
# 从IEU转换为本地格式
local_data <- IEU_0_to_local_2(
  IEUid = "ieu-a-2",
  IEUtype = "exposure",
  RegistID_dat = your_key
)
```

#### MiraMR (新)
```r
# 从IEU转换为本地格式
local_data <- mira_ieu_to_local_0_2(
  ieu_id = "ieu-a-2",
  ieu_type = "exposure"
)
```

**改进**：
- ✅ 函数名加前缀：`mira_ieu_to_local_0_2`
- ✅ 参数一致性：`ieu_id` vs `IEUid`

---

### 4. 肠道菌群分析

#### fastMR (旧)
```r
# 肠道菌群作为暴露
result <- Gut_IEU(
  IEUid = "ieu-a-7",
  outputpath = "results",
  RegistID_dat = your_key
)
```

#### MiraMR (新)
```r
# 肠道菌群作为暴露
result <- mira_gut_ieu(
  ieu_id = "ieu-a-7",
  output_dir = "results"
)
```

---

### 5. SMR分析

#### fastMR (旧)
```r
result <- SMR_qtl_GWAS(
  qtldata = qtl_data,
  gwasdata = gwas_data,
  outputpath = "results",
  RegistID_dat = your_key
)
```

#### MiraMR (新)
```r
result <- mira_smr_qtl(
  qtl_data = qtl_data,
  gwas_data = gwas_data,
  output_dir = "results"
)
```

---

### 6. 读取数据

#### fastMR (旧)
```r
# 读取GWAS数据
data <- read_data_h("data.txt")

# 读取FinnGen数据
data <- finn_read_data("finngen.txt")

# 读取GIANT数据
data <- giant_read_data("giant.txt")
```

#### MiraMR (新)
```r
# 读取GWAS数据
data <- mira_read_gwas("data.txt")

# 读取FinnGen数据
data <- mira_read_finn("finngen.txt")

# 读取GIANT数据
data <- mira_read_giant("giant.txt")
```

---

### 7. 工具函数

#### fastMR (旧)
```r
# 查找最近基因
genes <- Find_nearest_gene(
  data = snp_data,
  build = "hg19"
)

# EAF转换
data <- trans_to_eaf(data)

# Z分数转换
data <- trans_from_Z(data)
```

#### MiraMR (新)
```r
# 查找最近基因
genes <- mira_find_gene(
  data = snp_data,
  build = "hg19"
)

# EAF转换
data <- mira_trans_eaf(data)

# Z分数转换
data <- mira_trans_z(data)
```

---

## 📝 完整函数名对照表

### UVMR函数

| fastMR | MiraMR | 用法变化 |
|--------|--------|---------|
| `stand_UVMR_local_local()` | `mira_uvmr_local_local()` | 仅函数名 |
| `stand_UVMR_local_IEU()` | `mira_uvmr_local_ieu()` | 仅函数名 |
| `stand_UVMR_IEU_local()` | `mira_uvmr_ieu_local()` | 仅函数名 |
| `stand_UVMR_IEU_IEU()` | `mira_uvmr_ieu_ieu()` | 仅函数名 |

### MVMR函数

| fastMR | MiraMR | 用法变化 |
|--------|--------|---------|
| `stand_MVMR_local_local()` | `mira_mvmr_local_local()` | 仅函数名 |
| `stand_MVMR_local_IEU()` | `mira_mvmr_local_ieu()` | 仅函数名 |
| `stand_MVMR_IEU_local()` | `mira_mvmr_ieu_local()` | 仅函数名 |
| `stand_MVMR_IEU_IEU()` | `mira_mvmr_ieu_ieu()` | 仅函数名 |

### 数据预处理

| fastMR | MiraMR | 用法变化 |
|--------|--------|---------|
| `infla_factor_pre()` | `mira_prep_inflammatory()` | 仅函数名 |
| `inmm_cell_pre()` | `mira_prep_immune()` | 仅函数名 |
| `metb_pre()` | `mira_prep_metabolite()` | 仅函数名 |
| `gut_pre()` | `mira_prep_gut()` | 仅函数名 |
| `expsplit_gut()` | `mira_split_gut()` | 仅函数名 |

### 高级分析

| fastMR | MiraMR | 用法变化 |
|--------|--------|---------|
| `SMR_qtl_GWAS()` | `mira_smr_qtl()` | 仅函数名 |
| `SMR_plot()` | `mira_smr_plot()` | 仅函数名 |
| `GWAS_meta()` | `mira_gwas_meta()` | 仅函数名 |
| `PLACO_trait()` | `mira_placo()` | 仅函数名 |
| `Omic_local()` | `mira_omic_local()` | 仅函数名 |
| `omic_LOO()` | `mira_omic_loo()` | 仅函数名 |

### 肠道菌群

| fastMR | MiraMR | 用法变化 |
|--------|--------|---------|
| `Gut_IEU()` | `mira_gut_ieu()` | 仅函数名 |
| `Gut_local()` | `mira_gut_local()` | 仅函数名 |
| `IEU_Gut()` | `mira_ieu_gut()` | 仅函数名 |
| `Local_Gut()` | `mira_local_gut()` | 仅函数名 |

### 工具函数

| fastMR | MiraMR | 用法变化 |
|--------|--------|---------|
| `Find_nearest_gene()` | `mira_find_gene()` | 仅函数名 |
| `trans_to_eaf()` | `mira_trans_eaf()` | 仅函数名 |
| `trans_from_Z()` | `mira_trans_z()` | 仅函数名 |
| `read_data_h()` | `mira_read_gwas()` | 仅函数名 |
| `read_ref_data()` | `mira_read_ref()` | 仅函数名 |
| `finn_read_data()` | `mira_read_finn()` | 仅函数名 |
| `giant_read_data()` | `mira_read_giant()` | 仅函数名 |
| `yancao_read_data()` | `mira_read_yancao()` | 仅函数名 |

### 帮助函数

| fastMR | MiraMR | 用法变化 |
|--------|--------|---------|
| `helpMR()` | `mira_help()` | 仅函数名 |
| `updata_fastMR()` | `mira_update()` | 仅函数名 |

---

## 🆕 新增功能（fastMR没有）

### LDSC分析

```r
# 准备LDSC数据
mira_prep_ldsc(
  gwas_data = my_data,
  hm3_file = "~/ldsc_data/w_hm3.snplist",
  sample_size = 100000,
  trait_name = "MyTrait"
)

# 运行遗传相关分析
result <- mira_ldsc(
  trait1_file = "trait1.sumstats.gz",
  trait2_file = "trait2.sumstats.gz",
  ld_dir = "~/ldsc_data/eur_w_ld_chr/"
)

# 批量分析
results <- mira_ldsc_batch(
  reference_file = "ref.sumstats.gz",
  trait_files = c("t1.sumstats.gz", "t2.sumstats.gz"),
  ld_dir = "~/ldsc_data/eur_w_ld_chr/"
)

# 森林图
mira_ldsc_forest(results)
```

### CHR:BP转rsID

```r
# 单个文件转换
data_with_rsid <- mira_chr_to_rsid(
  data = gwas_data,
  chr_col = "CHR",
  bp_col = "BP",
  build = "GRCh37"
)

# 批量转换
results <- mira_chr_to_rsid_batch(
  file_dir = "gwas_files/",
  file_pattern = "*.txt",
  build = "GRCh37"
)
```

### SMR数据格式化

```r
# 格式化为SMR格式
mira_format_smr(
  input_file = "gwas.rds",
  output_file = "SMR_formatted.txt",
  data_format = "auto"
)
```

### License管理

```r
# 获取机器ID
mira_get_machine_id()

# 激活license
mira_activate("your_license_key")

# 检查状态
mira_license_status()

# 注销
mira_deactivate()
```

---

## 💡 迁移建议

### 方法1：查找替换（快速）

如果您有旧的fastMR代码，可以批量替换：

```r
# 旧代码
stand_UVMR_local_local(expgwas = ..., RegistID_dat = key)
infla_factor_pre(inputdir = ..., RegistID_dat = key)

# 新代码（查找替换）
# 1. 移除所有 RegistID_dat 参数
# 2. 替换函数名：
#    stand_UVMR → mira_uvmr
#    stand_MVMR → mira_mvmr
#    *_pre → mira_prep_*
# 3. 规范参数名：
#    expgwas → exposure_gwas
#    outgwas → outcome_gwas
#    inputdir → input_dir
#    outputdir → output_dir
```

### 方法2：逐步迁移（推荐）

1. 安装MiraMR但先不卸载fastMR
2. 新分析用MiraMR
3. 旧代码逐步更新
4. 确认无误后卸载fastMR

---

## 🔍 常见问题

### Q: 参数是否完全一样？

**A**: 核心参数一样，但有些参数名改进了：

| 旧参数 | 新参数 | 说明 |
|-------|-------|------|
| `expgwas` | `exposure_gwas` | 更清晰 |
| `outgwas` | `outcome_gwas` | 更清晰 |
| `inputdir` | `input_dir` | 规范化 |
| `outputdir` | `output_dir` | 规范化 |
| `outputpath` | `output_dir` | 统一命名 |
| `asexp` | `as_exposure` | 更清晰 |
| `pthreshold` | `p_threshold` | 规范化 |
| `RegistID_dat` | *移除* | 不需要了 |

### Q: 运行结果是否一样？

**A**: ✅ 完全一样！核心算法没有改变，只是：
- 移除了授权检查
- 改进了参数命名
- 增强了错误处理

### Q: 能同时安装fastMR和MiraMR吗？

**A**: ❌ 不建议。包名都是MiraMR，会冲突。建议：
1. 测试时：保留fastMR，用 `MiraMR::mira_*()` 调用新函数
2. 确认后：卸载fastMR，只用MiraMR

### Q: 旧的分析结果还能用吗？

**A**: ✅ 完全可以！输出格式完全兼容：
- MR.csv 格式相同
- 图片格式相同
- 所有结果文件都兼容

---

## 📚 完整示例：实际分析流程

### 旧代码（fastMR）

```r
library(fastMR)

# 需要授权
key <- readRDS("RegistID_dat.RData")

# 准备数据
exp_data <- infla_factor_pre(
  inputdir = "raw_data",
  outputdir = "processed",
  asexp = TRUE,
  RegistID_dat = key
)

# 读取结局数据
out_data <- read_data_h("outcome.txt")

# 运行MR分析
result <- stand_UVMR_local_local(
  expgwas = exp_data,
  outgwas = out_data,
  clumpp1 = 5e-8,
  clumpr2 = 0.001,
  useSteiger = TRUE,
  usefvalue = TRUE,
  usepresso = TRUE,
  createplot = TRUE,
  outputpath = "MR_results",
  RegistID_dat = key
)
```

### 新代码（MiraMR）

```r
library(MiraMR)  # 自动验证license，不需要key

# 准备数据（不需要RegistID_dat！）
exp_data <- mira_prep_inflammatory(
  input_dir = "raw_data",
  output_dir = "processed",
  as_exposure = TRUE
)

# 读取结局数据
out_data <- mira_read_gwas("outcome.txt")

# 运行MR分析
result <- mira_uvmr_local_local(
  exposure_gwas = exp_data,
  outcome_gwas = out_data,
  clump_p1 = 5e-8,
  clump_r2 = 0.001,
  use_steiger = TRUE,
  use_fvalue = TRUE,
  use_presso = TRUE,
  create_plots = TRUE,
  output_dir = "MR_results"
)
```

**改进点**：
- ✅ 不需要管理RegistID_dat
- ✅ 函数名更清晰
- ✅ 参数名更规范
- ✅ 代码更易读

---

## 🎯 总结

### 使用上的区别

| 方面 | fastMR | MiraMR | 难度 |
|-----|--------|--------|------|
| **函数名** | `stand_UVMR_*` | `mira_uvmr_*` | ⭐ 简单查找替换 |
| **授权** | 每次传`RegistID_dat` | 一次激活，永久使用 | ⭐ 更简单 |
| **参数名** | 混乱 | 统一规范 | ⭐ 更清晰 |
| **核心逻辑** | ✅ 相同 | ✅ 相同 | ✅ 无需学习 |
| **结果格式** | ✅ 相同 | ✅ 相同 | ✅ 完全兼容 |

### 迁移难度：⭐⭐☆☆☆ (非常简单)

**只需要**：
1. 首次激活license（2分钟）
2. 替换函数名（批量替换）
3. 规范参数名（可选，渐进式）

**不需要**：
- ❌ 重新学习MR方法
- ❌ 修改分析流程
- ❌ 改变数据格式
- ❌ 重跑旧分析

---

*MiraMR = 同样的功能 + 更好的体验！*
