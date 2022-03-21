taskscheduler_create(taskname = "test_run", "C:/Users/Antonio/Desktop/Teste/caged_banco_de_dados.R",
                     schedule = "MINUTE", starttime = format(Sys.time() + 1, "%H:%M"))
taskscheduler_delete("test_run")


setwd("C:/Users/Antonio/Documents/conexis")


#------------------------------------------------------------------------------#
#                                                                              #
#                                CAGED                                         #
#                                                                              #
#------------------------------------------------------------------------------#


#----------------------------Libraries------------------------------------------#

# rm(list=ls()); gc()

if (!'dplyr' %in% rownames(installed.packages())){install.packages('dplyr')}
if (!'reshape2' %in% rownames(installed.packages())){install.packages('reshape2')}
if (!'xlsx' %in% rownames(installed.packages())){install.packages('xlsx')}
if (!'magrittr' %in% rownames(installed.packages())){install.packages('magrittr')}
if (!'zip' %in% rownames(installed.packages())){install.packages('zip')}
if (!'RCurl' %in% rownames(installed.packages())){install.packages('RCurl')}
if (!'data.table' %in% rownames(installed.packages())){install.packages('data.table')}
if (!'lubridate' %in% rownames(installed.packages())){install.packages('lubridate')}

if (!'dplyr' %in% (.packages())){library('dplyr')}
if (!'reshape2' %in% (.packages())){library('reshape2')}
if (!'xlsx' %in% (.packages())){library('xlsx')}
if (!'magrittr' %in% (.packages())){library('magrittr')}
if (!'RCurl' %in% (.packages())){library('RCurl')}

if (!'downloader' %in% (.packages())){library('downloader')}
if (!'installr' %in% (.packages())){library('installr')}
if (!'zip' %in% (.packages())){library('zip')}
if (!'data.table' %in% (.packages())){library('data.table')}

#------------------------------------------------------------------------------#
# To do: Check if 7z is installed
#install.7zip(page_with_download_url = "http://www.7-zip.org/download.html")

#------------------------------------------------------------------------------#
# To do: Parametrizar isso.

if(month(Sys.Date()) == 1 || month(Sys.Date()) == 2){
ano <- year(Sys.Date()) - 1} else {ano <- year(Sys.Date())}

# To do: temp <- strsplit(temp,"<DIR>")
url <- paste('ftp://ftp.mtps.gov.br/pdet/microdados/NOVO%20CAGED/Movimenta%E7%F5es/', ano, "/", sep = "")
# URLencode("Movimenta??es")

temp <- getURL(url) # , verbose=TRUE,dirlistonly = TRUE, ftp.use.epsv=TRUE

meses <- c('Janeiro', 'Fevereiro', 'Marco', 'Abril', 'Maio', 'Junho',
           'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro')

# Descobre o ?ltimo m?s com dado dispon?vel.
if(month(Sys.Date()) == 1){
  mes <- 'Novembro'
  a <- "11"}

if(month(Sys.Date()) == 2){
  mes <- 'Dezembro'
  a <- "12"
} else{
i <- 12
found <- FALSE
while (found == FALSE) {
  found <- grepl(meses[i], temp, fixed = TRUE)
  i <- i - 1
  print(paste(i, meses[i], found, sep = ' - '))
  # insert break condition!
}
i <- i + 1
if(i < 10) {a <- paste("0", as.character(i), sep = "")} else{
  a <- "10"
}
mes <- meses[i]
rm(meses, found)}
arquivo <- paste("CAGEDMOV2020", a, ".txt", sep = "")
url <- paste(url,  mes, '/', sep='')

# https://www.scrapingbee.com/blog/web-scraping-r/#access-web-data-using-r-over-ftp
if(url.exists(url) == TRUE && file.exists(arquivo) == FALSE){

files <- getURL(url, dirlistonly = TRUE)
files <- str_split(files, "\r\n")

fileroot <- substr(files[1], 4, regexpr('.7z', files[1])[1]-7)

folder <- paste0(getwd(), '/')

#------------------------------------------------------------------------------#

for (i in sprintf("%02d", c(1:i))) {
  
  filename <- paste(fileroot, ano, i, sep='')
  # Parametrizar nome dos arquivos com getURL.
  
  #----------------------------Download------------------------------------------#
  
  if (!file.exists(paste(folder, filename, '.7z', sep=''))){
    print(paste('Downloading file ', paste(filename, '.7z', sep=''), '...', sep = ''))
    download.file(
      paste(url, filename, '.7z', sep=''),
      paste(folder, filename, '.7z', sep=''),
      quiet = TRUE, mode = "wb")
  }
  
  #-----------------------------Unzip--------------------------------------------#
  
  if (!file.exists(paste(folder, filename, '.txt', sep=''))){
    print(paste('Extracting file ', paste(filename, '.7z', sep=''), '...', sep = ''))
    # https://info.nrao.edu/computing/guide/file-access-and-archiving/7zip/7z-7za-command-line-guide
    # https://stat.ethz.ch/R-manual/R-devel/library/base/html/system.html
    # https://www.r-bloggers.com/2020/01/working-with-windows-cmd-system-commands-in-r/
    
    # "C:\Program Files (x86)\7-Zip\7z.exe" x "P:\CAGEDMOV202001.7z" -o"P:\" -aoa
    # x extracts with full paths
    # -aoa overwrite existing files without prompting
    exefile <- "C:\\Program Files (x86)\\7-Zip\\7z.exe"     # Executable - pode ser chamado fora do loop
    zipfile <- gsub("/", "\\", paste(folder, filename, '.7z', sep=''), fixed = TRUE) # zipfile <- "P:\\CAGEDMOV202001.7z"
    txtfile <- gsub("/", "\\", getwd(), fixed = TRUE)   # txtfile <- "P:\\"
    cmd <- paste("\"", exefile, '"', ' x ', '"', zipfile,'"', ' -o', '"', txtfile, "\" -aoa", sep = '')
    system(cmd, wait = TRUE)
    
    rm(exefile, zipfile, txtfile, cmd)
  }  
} 
}
  #---------------------------Remove zip-----------------------------------------#
  
  if (!file.exists(paste(folder, filename, '.7z', sep=''))){
   print(paste('Removing file ', paste(filename, '.7z', sep=''), '...', sep = ''))
  file.remove(paste(folder, filename, '.7z', sep=''))
 }
#----------------------------Read txt-----------------------------------------#
