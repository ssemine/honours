# read_orm.R
#
# Implements ReadORMBin function, adapted from ReadGRMBin (https://yanglab.westlake.edu.cn/software/gcta/#MakingaGRM)

ReadORMBin=function(prefix, AllN=F, size=4){
  sum_i=function(i){
    return(sum(1:i))
  }
  BinFileName=paste(prefix,".orm.bin",sep="")
  NFileName=paste(prefix,".orm.N.bin",sep="")
  IDFileName=paste(prefix,".orm.id",sep="")
  id = read.table(IDFileName)
  n=dim(id)[1]
  BinFile=file(BinFileName, "rb");
  orm=readBin(BinFile, n=n*(n+1)/2, what=numeric(0), size=size)
  NFile=file(NFileName, "rb");
  if(AllN==T){
    N=readBin(NFile, n=n*(n+1)/2, what=numeric(0), size=size)
  }
  else N=readBin(NFile, n=1, what=numeric(0), size=size)
  i=sapply(1:n, sum_i)
  return(list(diag=orm[i], off=orm[-i], id=id, N=N))
}