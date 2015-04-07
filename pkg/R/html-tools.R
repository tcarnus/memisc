
show_html <- function(x,output=NULL,...){
  
  ht <- format_html(x,...)
  
  if(interactive()){
    # Test whether running under RStudio 
    isRStudio <- Sys.getenv("RSTUDIO") == "1"
    if(isRStudio)
      deflt.output <- "file-show"
    else
      deflt.output <- "browser"
  }
  else
    deflt.output <- "console"
  
  if(!missing(output))
    output <- match.arg(output,c("console","browser","file-show"))
  else
    output <- getOption("show_html.output",deflt.output)
  
  if(output=="console") cat(ht)
  else {
    
    tf <- tempfile()
    tf <- paste0(tf,".html")
    cat(ht,file=tf)
    
    if(output=="file-show")
      file.show(tf,title=deparse(substitute(x)))
    else
      browseURL(tf)
  }
  
}

write_html <- function(x,file,...)
  cat(format_html(x,...),file=file)

format_html <- function(x,...)
  UseMethod("format_html")

mk_elem <- function(x,type,extra="",attribs=list(),...,linebreaks=FALSE,indent=0){
  start_tag <- paste0("<",type)
  if(nzchar(extra))
    start_tag <- paste(start_tag,extra)
  end_tag <- paste0("</",type,">")
  
  if(!missing(x)) 
    start_tag <- rep(start_tag,length(x))
  
  attribs <- c(attribs,list(...))
  if(length(attribs)){
    for(n in names(attribs)){
      attrib <- character(length(start_tag))
      attrib[] <- paste0("\"",attribs[[n]],"\"")
      use <- nzchar(attrib)
      start_tag[use] <- paste0(start_tag[use]," ",n,"=",attrib[use])
    }
  }
  start_tag <- paste0(start_tag,">")
  
  if(linebreaks && indent>0)
    indent <- paste0(rep(" ",indent),collapse="")
  else indent <- ""  
  
  if(!missing(x)){
    if(linebreaks){
      x <- paste0(indent,"   ",x,"\n")
      start_tag <- paste0(indent,start_tag,"\n")
      end_tag <- paste0(indent,end_tag,"\n")
    }
    res <- paste0(start_tag,x,end_tag)
  }
  else {
    res <- start_tag
    if(linebreaks)
      res <- paste0(indent,res,"\n")
  }
  
  return(res)
}

mk_td <- function(x,...)mk_elem(x,type="td",...,linebreaks=FALSE)
mk_th <- function(x,...)mk_elem(x,type="th",...,linebreaks=FALSE)
mk_tr <- function(x,...) mk_elem(x,type="tr",...,linebreaks=FALSE)

spltDec <- function(x,at="."){
  y <- strsplit(x,at,fixed=TRUE)
  y1 <- sapply(y,"[",1)
  y3 <- sapply(y,"[",2)
  y1[is.na(y1)] <- ""
  y3[is.na(y3)] <- ""
  y2 <- ifelse(grepl("[[:digit:]]+",y3),at,"")
  y <- rbind(y1,y2,y3)
  as.vector(y)
}

mk_td_spltDec <- function(x,style=""){
  
  if(!is.matrix(x))
    x <- t(as.matrix(x))
  
  tmp <- as.vector(t(x))
  
  stl <- c("text-align: right; margin-right: 0px; padding-right: 0px; padding-left: 0.3em;",
           "text-align: center; margin-left: 0px; padding-left: 0px; margin-right: 0px; padding-right: 0px; width: 1px;",
           "text-align: left; margin-left: 0px; padding-left: 0px; padding-right: 0.3em;")
  if(nzchar(style))
    style <- paste(style,stl)
  else
    style <- stl
  
  tmp <- mk_td(tmp,
               style=style)
  matrix(tmp,
         nrow=nrow(x),
         ncol=ncol(x),
         byrow=TRUE)
}