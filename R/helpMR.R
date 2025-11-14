#' @title 获取MiraMR包的帮助信息
#' @description 显示MiraMR包的基本使用指南和主要函数说明
#' @export
helpMR <- function(){
  cat("========================================\n")
  cat("  MiraMR - 孟德尔随机化分析工具包\n")
  cat("========================================\n\n")
  cat("主要功能模块:\n\n")
  cat("1. 标准单变量MR分析:\n")
  cat("   - stand_UVMR_local_local: 暴露和结局均为本地数据\n")
  cat("   - stand_UVMR_local_IEU: 暴露为本地数据，结局为IEU数据\n")
  cat("   - stand_UVMR_IEU_local: 暴露为IEU数据，结局为本地数据\n")
  cat("   - stand_UVMR_IEU_IEU: 暴露和结局均为IEU数据\n\n")
  cat("2. 标准多变量MR分析:\n")
  cat("   - stand_MVMR_local_local: 暴露和结局均为本地数据\n")
  cat("   - stand_MVMR_local_IEU: 暴露为本地数据，结局为IEU数据\n")
  cat("   - stand_MVMR_IEU_local: 暴露为IEU数据，结局为本地数据\n")
  cat("   - stand_MVMR_IEU_IEU: 暴露和结局均为IEU数据\n\n")
  cat("3. 数据预处理函数:\n")
  cat("   - infla_factor_pre: 炎症因子数据预处理 (91个因子)\n")
  cat("   - inmm_cell_pre: 免疫细胞数据预处理 (731种细胞)\n")
  cat("   - metb_pre: 代谢组学数据预处理 (1400种代谢物)\n")
  cat("   - gut_pre: 肠道菌群数据预处理 (211个菌群)\n\n")
  cat("4. 其他分析:\n")
  cat("   - SMR_qtl_GWAS: SMR分析\n")
  cat("   - GWAS_meta: GWAS meta分析\n")
  cat("   - PLACO_trait: 多效性分析\n")
  cat("   - Omic_local / local_Omic: 组学数据MR分析\n\n")
  cat("使用说明:\n")
  cat("- 本包仅供学术研究和教育使用\n")
  cat("- 不得用于未经授权的商业用途\n")
  cat("- 更多信息请查看各函数的帮助文档: ?function_name\n\n")
  cat("联系方式: mtmmu88@gmail.com\n")
  cat("========================================\n")
}








