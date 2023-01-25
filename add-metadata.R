library(tidyverse)
library(readxl)

manifest <- read_delim("manifest")

excel_meta <- read_excel("../18S_AV_Metadata.xlsx", sheet = 1) 

manifest_meta <- manifest %>% left_join(excel_meta, by = c("sample-id" = "SampleName"))

#manifest_meta_rev <- manifest_meta %>% select('sample-id' = 'sample.id', 'forward-absolute-filepath' = 'forward.absolute.filepath', 'reverse-absolute-filepath' = 'reverse.absolute.filepath', everything())
#write.table(manifest_meta_rev, "manifest22.tsv",quote=FALSE,col.names=TRUE,row.names=FALSE,sep="\t") 

write.table(manifest_meta, "manifest22.tsv",quote=FALSE,col.names=TRUE,row.names=FALSE,sep="\t")  
