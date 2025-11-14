#' @title 更新MiraMR包
#' @description 从GitHub更新MiraMR包到最新版本
#' @param repo GitHub仓库地址，格式为 "username/repo"
#' @export
update_MiraMR <- function(repo = NULL){
  if(is.null(repo)){
    cat("========================================\n")
    cat("  MiraMR 包更新说明\n")
    cat("========================================\n\n")
    cat("如需更新MiraMR包，请使用以下命令:\n\n")
    cat("方法1: 从GitHub安装 (如果有仓库)\n")
    cat('  devtools::install_github("your_username/MiraMR")\n\n')
    cat("方法2: 从本地源码安装\n")
    cat('  devtools::install("/path/to/MiraMR")\n\n')
    cat("方法3: 使用此函数指定仓库\n")
    cat('  update_MiraMR(repo = "your_username/MiraMR")\n\n')
    cat("注意: 更新前会自动卸载当前版本\n")
    cat("========================================\n")
  } else {
    if(!require("devtools", quietly = TRUE)){
      install.packages("devtools")
    }
    x <- try(detach("package:MiraMR", unload = TRUE))
    if(class(x) != "try-error"){
      remove.packages("MiraMR")
      devtools::install_github(repo)
      message("MiraMR已经更新到最新版本")
    } else {
      remove.packages("MiraMR")
      devtools::install_github(repo)
      message("MiraMR已经更新到最新版本")
    }
  }
}
