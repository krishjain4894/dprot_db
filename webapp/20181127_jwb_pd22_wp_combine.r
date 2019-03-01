# Fischerlab
# ESF 2018-03-2018
# Analysis TMT datasets TMT 10plex whole proteome

setwd("/home/ch207814/proteomicsproject/")
wdpath <- getwd()
pre <- "temp_"

# ## Load dependencies:

library("stringr")
library("limma")
library("dplyr")
idmapping_sel <- read.csv(file = paste(wdpath, "/R-helper/id_mapping.csv", sep=""), stringsAsFactors = FALSE)

# Load names of proteins files and extract experiment numbers
infile.proteins <- dir(paste(wdpath, "/proteins", sep=""), full.names=T)
experiment.numbers <- paste("wp", str_sub(infile.proteins, str_locate(infile.proteins, "esf")[2]+4, str_locate(infile.proteins, "esf")[2]+6), sep="")

## Define variables
# Use data with minimal number of unique peptide counts
sc <- 1
# use intensities (1) or spectral counts (2) as weights for limma, etc.
w <- 1

print(length(infile.proteins))
# Compile master list of data from all experiments and compounds
all.compounds <- list()
for (j in 1:length(infile.proteins)) {
  infile <- infile.proteins[j]
  print(j)
  # Load TMT data
  D.exp <- read.delim(file = infile, header=TRUE, sep="\t", as.is=TRUE)
  nrow(D.exp) # check number of proteins
  colnames(D.exp) # check column headers
  
  # Remove protein contaminants
  sum(D.exp$Contaminant=="True")
  D.exp <- D.exp[!D.exp$Contaminant=="True",]
  print("Remove protein contaminants")

  # Identify and count reporter ion channels
  channels <- grep("^Abundance.F..(126|127|128|129|130|131)", colnames(D.exp), value=TRUE)
  if (length(channels)==0) {
    channels <- grep("^Abundance.F...(126|127|128|129|130|131)", colnames(D.exp), value=TRUE)
  }
  tmt <- length(channels)
  print("Identify and count reporter ion channels")

  # Identify contrasts
  channels
  temp <- vector(mode="character", length = length(channels))
  print("Length of Channels",length(channels))
  for (i in 1:length(channels)) {
    temp[i] <- substr(channels[i],
                      regexpr("Sample.", channels[i])[1] + nchar("Sample."), # character index of cpd name start
                      nchar(channels[i])) # character index of cpd name end
  }
  temp2 <- unique(temp)
  contrasts <- temp2[!grepl("DMSO", temp2)]
  rm(i, temp, temp2)
  contrasts
  print("Identify contrasts")
  
  # Subset data frame
  colnames(D.exp)
  sel1 <- grep("Accession", colnames(D.exp), value = TRUE)
  if (length(sel1)>1) {
    sel1 <- sel1[which(nchar(sel1)==min(nchar(sel1)))]
  }
  sel2 <- grep("^Gene.Symbol", colnames(D.exp), value = TRUE)
  if (length(sel2) == 0) {
    sel2 <- grep("^Gene.ID", colnames(D.exp), value = TRUE)
  }
  if (length(sel2) == 0) {
    D.exp$Accession.trimmed <- gsub(x = D.exp$Accession, pattern = "-1|-2|-3|-4|-5|-6|-7|-8|-9|-10|-11|-12|-13|-14|-15", replacement = "")
    D.exp <- left_join(x = D.exp, y = idmapping_sel, by = "Accession.trimmed")
    D.exp <- D.exp[,-grep("Accession.trimmed", x=colnames(D.exp))]
    sel2 <- grep("^Gene.Symbol", colnames(D.exp), value = TRUE)
  }
  sel3 <- grep("^Description", colnames(D.exp), value = TRUE)
  sel4 <- grep("^Number.of.Unique.Peptides", colnames(D.exp), value = TRUE)
  sel5 <- c(sel1, sel2, sel3, sel4, channels)
  sel5
  D <- D.exp[, sel5]
  rownames(D) <- D[,1]
  rm(sel1,sel2,sel3,sel4,sel5)
  print("Subset data frame")

  # Remove data with unique peptides below threshold
  sum(!D$Number.of.Unique.Peptides >= sc)
  D <- D[D$Number.of.Unique.Peptides >= sc,]
  print("Remove data with unique peptides below threshold")

  #remove data with NAs or low sum of reporter ion intensities
  sel <- as.matrix(rowSums(D[5:(5+tmt-1)])) >= 200
  summary(sel)
  D <- subset(D, sel)
  rm(sel)
  print("remove data with NAs or low sum of reporter ion intensities")
  
  # Normalize and scale data to create relative abundance matrix
  # calculate sum of intensities for each channel excluding top 20 and weakest 10% of data (code might be wrong)
  x <- colSums(D[c(20:(nrow(D)-(nrow(D)*0.1))),c(5:(5+tmt-1))])
  x <- x/max(x)
  y <- t(apply(D[,c(5:(5+tmt-1))],x, "/", x))
  Dn <- D
  Dn[,c(5:(5+tmt-1))] <- y
  rm(x); rm(y)
  print("Normalize")
  
  # Create matrix for abundance
  A <- as.matrix(Dn[,c(5:(5+tmt-1))])
  
  # Scale matrix for abundance to 100
  a <- log2((A/rowSums(A))*100)
  
  ### remove negative values
  sel <- apply(a,1,function(x)all(x>=0))
  summary(sel)
  a <- a[sel,]
  A <- A[sel,]
  D <- D[sel,]
  rm(sel)
  print("Scale matrix")
  
  # Create list to store all limma outputs
  tt.list <- list()
  
  ## Use limma to generate moderated t-statistic p-values ######
  # Run limma for all contrast with matrix reduced to DMSO + treatment conditions
  print(length(contrasts))
  for(i in 1:length(contrasts)){
    print(i)
    contrast <- contrasts[i] 
    sel1 <- grep("DMSO", colnames(a), value = T)
    sel2 <- grep(contrast, colnames(a), value = T)
    sel3 <- c(sel1, sel2)
    sel <- colnames(a) %in% sel3
    b <- a[,sel]
    treat <- factor(ifelse(grepl(contrast, colnames(b)),"DRUG","CTRL"), levels=c("CTRL","DRUG"))
    design <- model.matrix(~ treat) # define matrix
    rownames(design) <- colnames(b) # assign names
    design
    
    # run ebayes fit with limma
    if(w == 1){
      fit <- lmFit(b, design=design, weights=rowSums(A)) # with intensities as weight
    } else {
      fit <- lmFit(b, design=design, weights=D$Quantified.spectral.counts) # with spectral counts as weight
    }
    fit <- eBayes(fit)
    tt <- topTable(fit, coef="treatDRUG", genelist=rownames(b), number=nrow(b))
    options(width=160); head(tt, n=50)
    
    # Add gene names to tt for PD1 data
    combineBy <- "Accession"
    identifier <- D[,c(1,2)]
    tt2 <- tt
    colnames(tt2) <- c("Accession", "logFC", "AveExpr", "t", "P.Value", "adj.P.Val", "B")
    ids <- unique(c(tt2[,combineBy], identifier[,combineBy]))
    tt3 <- cbind(tt2[match(ids, tt2[,combineBy]),], identifier[match(ids, identifier[,combineBy]),])
    tt[,8] <- tt[,1]
    colnames(tt)[8] <- "Accession"
    tt[,1] <- tt3[,9]
    rm(tt2);rm(tt3)
    
    # sort tt and add to list
    temp <- tt[order(tt$ID),]
    tt.list[[i]] <- temp
  }
  names(tt.list) <- contrasts
  rm(i,contrast,sel1,sel2,sel3,sel,b,treat,design,fit,tt,combineBy,identifier,ids, temp)
  rm(D.exp, D, Dn, A, a)
  rm(infile, tmt, channels, contrasts)
  all.compounds[[j]] <- tt.list
  rm(tt.list)
}
print("here")
names(all.compounds) <- experiment.numbers
rm(j)

print(length(all.compounds))
# assemble master data frames for each experiment
all.experiments <- list()
for (j in 1:length(all.compounds)) {
  temp <- all.compounds[[j]]
  for (i in 1:length(temp)) {
    colnames(temp[[i]]) <- paste(names(all.compounds)[j],colnames(temp[[i]]),names(temp[i]),sep="|")
  }
  
  temp2 <- cbind(temp[[1]][,c(8,1,2,5)], deparse.level=0)
  for (i in 2:length(temp)) {
    temp2 <- cbind(temp2, temp[[i]][,c(2,5)], deparse.level=0)
  }
  names(temp2)[c(1,2)] <- c("Accession","ID")
  all.experiments[[j]] <- temp2
}
names(all.experiments) <- names(all.compounds)
rm(temp, temp2, j, i)

# create master data frame for all experiments
all.data <- all.experiments[[1]]
print(length(all.experiments))
for (i in 1:length(all.experiments)) {
  temp <- all.experiments[[i]]
  all.data <- full_join(all.data, temp, by="Accession")
}
rm(i,temp)
rownames(all.data) <- all.data$Accession
# recombine accession columns for most complete IDs
temp1 <- all.data[,grep("ID",colnames(all.data))]
temp1[temp1==""] <- NA
temp2 <- apply(temp1, 1, function(x) {
  unique(x[!is.na(x)][nchar(x[!is.na(x)])>0])
  })
IDs <- lapply(temp2, function(x){x[which.max(nchar(x))]})
# convert missing IDs to NA
for (i in 1:length(IDs)){
  if (length(IDs[[i]]) == 0) {
    IDs[[i]] <- as.character(NA)
  }
}
rm(temp1,temp2,i)
IDs <- unlist(IDs)
# add IDs back to master data frame and remove duplicate partial ID columns
all.data$ID.x <- IDs
all.data <- all.data[,c(1,grep("ID",colnames(all.data))[1],grep("ID",colnames(all.data), invert=T)[-1])]
colnames(all.data)[grep("ID",colnames(all.data))] <- "ID"

# write out all data to csv
write.csv(all.data, file=paste(wdpath, "/tables/", pre, "all_data.csv", sep=""), row.names=F)
