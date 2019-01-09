
#  Updates of Version 2.0  -----------------------------------------------
#  Junhong Bai 2018/11/15
#  1. Appended all R scripts of npmc package since it was removed from CRAN
#  2. Redirect all calls to "FromKruskaiCoin" function to "FromKruskai" since TERR 4.5.0 does not support coin package. *kruskal_test is a function of coin.
#  3. Added TableToDouble function to avoid bug of fisher.test of TERR 4.5.0


###################################
#
#	Required CRAN Packages
#
###################################
library(multcomp)  
#depending packages
#codetools;mvtnorm;lattice;MASS;zoo;sandwich;Matrix;survival;TH.data


# npmc functions ----------------------------------------------------------
"npmc" <-
  function(dataset, control=NULL, df=2, alpha=0.05)
  {
    mvtnorm <- require(mvtnorm, quietly=TRUE);
    if (!mvtnorm)
    {
      msg <- paste("npmc requires the mvtnorm-package to calculate",
                   "p-values for the test-statistics. This package is not",
                   "available on your system, so these values and the",
                   "confidence-limits will be missing values in the output!\n",
                   sep="\n");
      warning(msg);
    }
    
    if (any(df==0:2)) 
      dfm <- c(3,2,1)[df+1]
    else
    {
      warning("Wrong value for df\nUsing Satterthwaite t-approximation\n");
      dfm <- 1;
    }
    
    if (alpha<=0 || alpha>=1)
      stop("alpha must be a value between 0 and 1");
    
    
    name <- attr(dataset, "name");
    desc <- attr(dataset, "description");
    
    
    ##=== Function definitions ===================================================
    
    
    ##
    ## ssq:
    ## ----
    ## Calculates a vector's sum of squares
    ##
    ssq <- function(x) sum(x*x);
    
    ##
    ## force.ps: 
    ## ---------
    ## Forces a matrix to be positive semidefinite by replacing 
    ## all negative eigenvalues by zero.
    ## 
    force.ps <- function(M.in)
    {
      eig <- eigen(M.in, symmetric=TRUE);
      spec <- eig$values;
      if (adjusted <- any(spec<0))
      {
        spec[spec<0] <- 0;
        M <- eig$vectors %*% diag(spec) %*% t(eig$vectors);
        ginv <- diag(1/sqrt(diag(M)));
        M.out <- ginv %*% M %*% ginv;
        ##if ((msg <- all.equal(M.in,M.out))!=TRUE) attr(M.out, "msg") <- msg;
      }
      else
      {
        M.out <- M.in;
      }
      attr(M.out,"adjusted") <- adjusted; 
      return (M.out);
    }
    
    
    ##
    ## z.dist:
    ## -------
    ## Calculates the p-values for the teststatistics using the mvtnorm-package.
    ## The 'sides' parameter determines whether the p-values for the one-
    ## or two-sided test are calculated.
    ## The statistic is supposed to follow a multivariate t-statistic with
    ## correlation-matrix 'corr' and 'df' degrees of freedom. If df=0, the
    ## multivariate normal-distribution is used.
    ## We use the mvtnorm-package by Frank Bretz (www.bioinf.uni-hannover.de) 
    ## to calculate the corresponding p-values. These algorithms originally 
    ## calculate the value P(X<=stat) for the mentioned multivariate distributions, 
    ## i.e. the 1-sided p-value. In order to gain the 2-sided p-value as well, 
    ## we used the algorithms on the absolute value of the teststatistic in 
    ## combination with the inflated correlation-matrix
    ##   kronecker(matrix(c(1,-1,-1,1),ncol=2), corr)
    ##
    z.dist <- function(stat, corr, df=0, sides=2)
    {
      if (!mvtnorm) return (NA);
      
      if (sides==2)
      {
        corr <- kronecker(matrix(c(1,-1,-1,1),ncol=2), corr);
        stat <- abs(stat);
      }
      n <- ncol(corr);
      sapply(stat, function(arg) 
      {
        mvtnorm::: mvt(
          lower=rep(-Inf, n), 
          upper=rep(arg, n), 
          df=df, 
          corr=corr, 
          delta=rep(0,n)
        )$value;
      });     
    } 
    
    
    ##
    ## z.quantile:
    ## -----------
    ## Calculates the corresponding quantiles of z.dist p-values
    ## (used for the confidence-intervals)
    ##
    z.quantile <- function(p=0.95, start=0, corr, df=0, sides=2)
    {
      if (!mvtnorm) return (NA);
      
      if (z.dist(start,corr=corr,df=df,sides=sides) < p)
      {
        lower <- start;
        upper <- lower+1;
        while(z.dist(upper,corr=corr,df=df,sides=sides) < p)
          upper <- upper+1;
      }
      else
      {
        upper <- start;
        lower <- upper-1;
        while(z.dist(lower,corr=corr,df=df,sides=sides) > p)
          lower <- lower-1;
      }
      ur <- uniroot(f=function(arg) p-z.dist(arg,corr=corr,df=df,sides=sides),
                    upper=upper, lower=lower
      );
      ur$root;
    }
    
    
    ##=== Calculations ===========================================================
    
    ## sort the dataset by factor
    dataset$class <- factor(dataset$class);
    datord <- order(dataset$class);
    attrs <- attributes(dataset);
    dataset <- data.frame(lapply(dataset, "[", datord));
    attributes(dataset) <- attrs;
    
    ## general data characteristics
    attach(dataset);
    fl <- levels(class);             # factor-levels
    a <- nlevels(class);             # number of factor-levels
    samples <- split(var, class);    # split the data in separate sample-vectors
    n <- sapply(samples, length);    # sample sizes
    detach(dataset);
    
    if (is.null(control))
    {
      ## create indexing vectors for the all-pairs situation
      tmp <- expand.grid(1:a, 1:a);
      ind <- tmp[[1]] > tmp[[2]];
      vi <- tmp[[2]][ind];
      vj <- tmp[[1]][ind];
    }
    else
    {
      ## create indexing vectors for the many-to-one situation
      if (!any(fl==control))
      {
        msg <- paste("Wrong control-group specification\n",
                     "The data does not contain a group with factor-level ",
                     control,
                     sep="");
        stop(msg, FALSE);
      }
      cg <- which(fl==control);
      vi <- which((1:a)!=cg);
      vj <- rep(cg, a-1);
    }
    
    ## number of comparisons ( a*(a-1)/2 for all-pairs, (a-1) for many-to-one )
    nc <- length(vi);              
    
    ## labels describing the compared groups 
    cmpid <- paste(vi, "-", vj, sep="");
    
    ## pairwise pooled sample-sizes
    gn <- n[vi]+n[vj];
    
    ## internal rankings
    intRanks <- lapply(samples, rank);
    
    ## pairwise rankings
    pairRanks <- lapply(1:nc, function(arg) 
    {
      rank(c(samples[[vi[arg]]], samples[[vj[arg]]]));  
    });
    
    ## estimators for the relative effects
    pd <- sapply(1:nc, function(arg)
    {
      i <- vi[arg]; 
      j <- vj[arg];
      (sum(pairRanks[[arg]][(n[i]+1):gn[arg]])/n[j]-(n[j]+1)/2)/n[i];  
    });
    
    ## Calculations for the BF-test ###################################
    ##
    dij <- dji <- list(0);
    
    sqij <- sapply(1:nc, function(arg) 
    {
      i <- vi[arg]; 
      j <- vj[arg];
      pr <- pairRanks[[arg]][(n[i]+1):gn[arg]];
      dij[[arg]] <<- pr - sum(pr)/n[j] - intRanks[[j]] + (n[j]+1)/2;
      ssq(dij[[arg]])/(n[i]*n[i]*(n[j]-1));
    });
    
    sqji <- sapply(1:nc, function(arg)
    {
      i <- vi[arg];  
      j <- vj[arg];
      pr <- pairRanks[[arg]][1:n[i]];
      dji[[arg]] <<- pr - sum(pr)/n[i] - intRanks[[i]] + (n[i]+1)/2;
      ssq(dji[[arg]])/(n[j]*n[j]*(n[i]-1));
    });
    
    ## diagonal elements of the covariance-matrix
    vd.bf <- gn*(sqij/n[vj] + sqji/n[vi]);
    
    ## mark and correct zero variances for further calculations
    singular.bf <- (vd.bf==0);
    vd.bf[singular.bf] <- 0.00000001;
    
    ## standard-deviation
    std.bf <- sqrt(vd.bf/gn);
    
    ## teststatistic
    t.bf <- (pd-0.5)*sqrt(gn/vd.bf);
    
    ## Satterthwaite approxiamtion for the degrees of freedom
    df.sw <- (n[vi]*sqij + n[vj]*sqji)^2 / 
      ((n[vi]*sqij)^2/(n[vj]-1) + (n[vj]*sqji)^2/(n[vi]-1));
    df.sw[is.nan(df.sw)] <- Inf;
    
    ## choose degrees of freedom 
    df <- if (dfm<3) max(1, if (dfm==2) min(gn-2) else min(df.sw)) else 0;
    
    
    ## Calculations for the Steel-test ################################
    ##
    ## the Steel-type correlation factors
    lambda <- sqrt(n[vi]/(gn+1));
    
    ## diagonal elements of the covariance-matrix
    vd.st <- sapply(1:nc, function(arg) ssq(pairRanks[[arg]]-(gn[arg]+1)/2)) / 
      (n[vi]*n[vj]*(gn-1));
    
    ## mark and correct zero variances for further calculations
    singular.st <- (vd.st==0);
    vd.st[singular.st] <- 0.00000001;
    
    ## standard-deviation
    std.st <- sqrt(vd.st/gn);
    
    ## teststatistic
    t.st <- (pd-0.5)*sqrt(gn/vd.st);
    
    
    ## Calculate the correlation-matrices (for both, BF and Steel) ####
    ##    
    rho.bf <- rho.st <- diag(nc);
    for (x in 1:(nc-1))
    {
      for (y in (x+1):nc)
      {
        i <- vi[x]; j <- vj[x];
        v <- vi[y]; w <- vj[y];
        p <- c(i==v, j==w, i==w, j==v);
        if (sum(p)==1) 
        {      
          cl <- list(
            function()  (t(dji[[x]]) %*% dji[[y]]) / (n[j]*n[w]*n[i]*(n[i]-1)),
            function()  (t(dij[[x]]) %*% dij[[y]]) / (n[i]*n[v]*n[j]*(n[j]-1)),
            function() -(t(dji[[x]]) %*% dij[[y]]) / (n[i]*n[w]*n[i]*(n[i]-1)),
            function() -(t(dij[[x]]) %*% dji[[y]]) / (n[j]*n[v]*n[j]*(n[j]-1))
          );
          case <- (1:4)[p];
          rho.bf[x,y] <- rho.bf[y,x] <- 
            sqrt(gn[x]*gn[y]) / sqrt(vd.bf[x]*vd.bf[y]) * cl[[case]]()
          ;
          rho.st[x,y] <- rho.st[y,x] <- 
          {if (case>2) -1 else 1}*lambda[x]*lambda[y]
          ;
        }
      }
    }
    rho.bf <- force.ps(rho.bf);
    rho.st <- force.ps(rho.st);
    
    
    ## Calculate the p-values     (BF and Steel) ######################
    ##
    p1s.bf <- 1 - z.dist(t.bf, corr=rho.bf, df=df, sides=1);
    p2s.bf <- 1 - z.dist(t.bf, corr=rho.bf, df=df, sides=2);
    
    p1s.st <- 1 - z.dist(t.st, corr=rho.st, sides=1);
    p2s.st <- 1 - z.dist(t.st, corr=rho.st, sides=2);
    
    
    ## Calculate the confidence-limits (BF and Steel) #################
    ##
    z.bf <- z.quantile(1-alpha, corr=rho.bf, df=df, sides=2);
    lcl.bf <- pd - std.bf*z.bf;
    ucl.bf <- pd + std.bf*z.bf;
    
    z.st <- z.quantile(1-alpha, corr=rho.st, sides=2);
    lcl.st <- pd - std.st*z.st;
    ucl.st <- pd + std.st*z.st;
    
    
    ##=== Output ==================================================================
    
    ## Create the result-datastructures ###############################
    ##    
    dataStructure <- data.frame("group index"=1:a, 
                                "class level"=fl, 
                                "nobs"=n
    );
    
    test.bf <- data.frame("cmp"=cmpid, 
                          "gn"=gn, 
                          "effect"=pd,
                          "lower.cl"=lcl.bf,
                          "upper.cl"=ucl.bf,
                          "variance"=vd.bf, 
                          "std"=std.bf, 
                          "statistic"=t.bf, 
                          "p-value 1s"=p1s.bf, 
                          "p-value 2s"=p2s.bf, 
                          "zero"=singular.bf
    ); 
    
    test.st <- data.frame("cmp"=cmpid, 
                          "gn"=gn, 
                          "effect"=pd, 
                          "lower.cl"=lcl.st,
                          "upper.cl"=ucl.st,
                          "variance"=vd.st, 
                          "std"=std.st, 
                          "statistic"=t.st, 
                          "p-value 1s"=p1s.st, 
                          "p-value 2s"=p2s.st, 
                          "zero"=singular.st
    ); 
    
    result <- list("data"=dataset,
                   "info"=dataStructure, 
                   "corr"=list("BF"=rho.bf, "Steel"=rho.st),
                   "test"=list("BF"=test.bf, "Steel"=test.st),
                   "control"=control,
                   "df.method"=dfm,
                   "df"=df,
                   "alpha"=alpha
    );
    
    class(result) <- "npmc";
    
    return (result);
    
  }

"summary.npmc" <-
  function(object, type="both", info=TRUE, short=TRUE, corr=FALSE, ...)
  {
    x <- object;
    if (info)
    {
      name <- attr(data, "name");
      desc <- attr(data, "desc");
      df <- x$df;
      df.method <- x$df.method;
      alpha <- x$alpha;
      
      apm <- c(paste("Satterthwaite t-approximation (df=",df,")",sep=""),
               paste("simple t-approximation (df=",df,")",sep=""),
               "standard normal approximation"
      );
      msg <- c(paste("npmc executed", if (!is.null(name)) paste("on", name)),
               if (is.null(desc)) "" else c("","Description:",desc,""),
               "NOTE:",
               paste("-Used", apm[df.method]),
               paste("-Calculated simultaneous (1-", alpha, ") confidence intervals",sep=""),
               "-The one-sided tests 'a-b' reject if group 'a' tends to",
               " smaller values than group 'b'"
      );
      report(msg, style=2, char="/");
      report();
    }
    
    if (short)
    {
      bf <- st <- c("cmp","effect","lower.cl","upper.cl","p.value.1s","p.value.2s");
    }
    else
    {
      bf  <- names(x$test$BF);
      st <- names(x$test$Steel);
    }
    
    
    content <- list();
    if (info)
      content <- c(content, list("Data-structure"=x$info));
    if (corr && type!="Steel")
      content <- c(content, list("Behrens-Fisher type correlation-matrix"=x$corr$BF));
    if (corr && type!="BF")
      content <- c(content, list("Steel type correlation-matrix"=x$corr$Steel));
    if (type!="Steel")
      content <- c(content, list("Results of the multiple Behrens-Fisher-Test"=x$test$BF[bf]));
    if (type!="BF")
      content <- c(content, list("Results of the multiple Steel-Test"=x$test$Steel[st]));
    
    ##h <- (list("Data-structure"=x$info, 
    ##           "Behrens-Fisher type correlation-matrix"=x$corr$BF, 
    ##           "Steel type correlation-matrix"=x$corr$Steel,
    ##           "Results of the multiple Behrens-Fisher-Test"=x$test$BF[bf], 
    ##           "Results of the multiple Steel-Test"=x$test$Steel[st]
    ##           ));
    
    print(content);
  }

"report" <-
  function(msg=NULL, style=0, char="-")
  {
    if (is.null(msg)) msg <- "";
    
    if (is.vector(msg))
      msg <- unlist(msg)
    else
      stop("msg must be of type vector");
    
    char <- substr(char, 1, 1);
    
    underlined <- function (arg)
    {
      c(arg, paste(rep(char, max(nchar(msg))), collapse=""));
    }
    
    border <- function(arg) 
    {
      n <- length(msg);
      ml <- max(nchar(msg));
      space <- paste(rep(" ", ml), collapse="");
      line <- paste(rep(char, ml+4), collapse="");
      msg <- paste(msg, substr(rep(space, n), rep(1, n), ml-nchar(msg)), sep=""); 
      c(line, paste(char, msg, char), line);          
    }
    
    sfun <- list(underlined = underlined,
                 border = border
    );
    
    if (is.numeric(style) && length(style)==1 && any(style==1:length(sfun)))
      msg <- sfun[[style]](msg)
    else if (is.character(style) && length(style)==1 && !is.null(sfun[[style]]))
      msg <- sfun[[style]](msg)
    
    m <- matrix(msg, ncol=1);
    colnames(m) <- "";
    rownames(m) <- rep("", length(msg));
    print.noquote(m); 
  }


"print.npmc" <-
  function(x, ...)
  {
    print(x$test, ...)
  }




###################################
#
#	Steel.Dwass
#	http://aoki2.si.gunma-u.ac.jp/R/Steel-Dwass.html
###################################
Steel.Dwass <- function(data,group)
{
        OK <- complete.cases(data, group)
        data <- data[OK]
        group <- group[OK]
        n.i <- table(group)
        ng <- length(n.i)
        t <- combn(ng, 2, function(ij) {
                i <- ij[1]
                j <- ij[2]
                r <- rank(c(data[group == i], data[group == j]))
                R <- sum(r[1:n.i[i]])
                N <- n.i[i]+n.i[j]
                E <- n.i[i]*(N+1)/2
                V <- n.i[i]*n.i[j]/(N*(N-1))*(sum(r^2)-N*(N+1)^2/4)
                return(abs(R-E)/sqrt(V))
        })
        p <- ptukey(t*sqrt(2), ng, Inf, lower.tail=FALSE)
        result <- cbind(t, p)
        rownames(result) <- combn(ng, 2, paste, collapse=':')
        return(result)
}

###################################
#
#	Steel_Dwass_coin
#	coin module
###################################
Steel_Dwass_coin <- function(data,group)
{
	Message <<- c(Message,'Run Steel_Dwass test.')
	myTestData <- data.frame(data, group)
	colnames(myTestData) <- c('value','category')
	NDWD <- oneway_test(value ~ category, data = myTestData,
		ytrafo = function(data) trafo(data, numeric_trafo = rank),
		xtrafo = function(data) trafo(data, factor_trafo = function(x)
		model.matrix(~x - 1) %*% t(contrMat(table(x), 'Tukey'))),
		teststat = 'max', distribution = approximate(B = 90000))
	
	pvalues <- pvalue(NDWD, method = 'single-step')
	outpvalues <- data.frame(pvalues)[,1]
	stars <- lapply(outpvalues,GetStar)
	stars <- as.data.frame(as.matrix(stars))
	
	rt <- data.frame(outpvalues, '','',stars, '', 'Steel-Dwass')
	rt <- data.frame(rownames(pvalues),rt,row.names=NULL)
	colnames(rt) <- c('categories','p-value','coefficients','t-stat','Signif-codes','alternative','Method')
	return(rt)
}

###################################
#
#	Steel
#	http://aoki2.si.gunma-u.ac.jp/R/Steel.html
###################################
Steel <- function(data,group)
{
        get.rho <- function(ni)
        {
                k <- length(ni)
                rho <- outer(ni, ni, function(x, y) { sqrt(x/(x+ni[1])*y/(y+ni[1])) })
                diag(rho) <- 0
                sum(rho[-1, -1])/(k-2)/(k-1)
        }

        OK <- complete.cases(data, group)
        data <- data[OK]
        group <- factor(group[OK])
        ni <- table(group)
        a <- length(ni)
        control <- data[group == 1]
        n1 <- length(control)
        t <- numeric(a)
        rho <- ifelse(sum(n1 == ni) == a, 0.5, get.rho(ni))
        for (i in 2:a) {
                r <- rank(c(control, data[group == i]))
                R <- sum(r[1:n1])  
                N <- n1+ni[i]   
                E <- n1*(N+1)/2  
                V <- n1*ni[i]/N/(N-1)*(sum(r^2)-N*(N+1)^2/4) 
                t[i] <- abs(R-E)/sqrt(V) 
        }
        result <- cbind(t, rho)[-1,]
        rownames(result) <- paste(1, 2:a, sep=':')
        return(result)
}

###################################
#
#	Steel npmc version
#	
###################################
Steel_npmc <- function(data,group)
{
	mydata <- data.frame(group,data)
	colnames(mydata) <- c('class','var')
	myresult <- summary(npmc(mydata,df=0,control=group[1],alpha=0.05), type='Steel')
	
	mylevel <- myresult$`Data-structure`
	mypvalues <- myresult$`Results of the multiple Steel-Test`
	
	# add divided cmp names to mypvalues
	tempresult <- strsplit(as.matrix(mypvalues[1]),'-')
	r <- tempresult[[1]]
	for (i in 2:length(tempresult))
	{
		r <- rbind(r,tempresult[[i]])
	}
	colnames(r) <- c('pre','post')
	rownames(r) <- 1:nrow(r)
	mypvalues <- data.frame(mypvalues,r)
	
	# add pre
	mypre <- mylevel[1:2]
	colnames(mypre) <- c('pre','pre-class')
	mypvalues <- merge(mypvalues, mypre)
	# add post
	mypost <- mylevel[1:2]
	colnames(mypost) <- c('post','post-class')
	mypvalues <- merge(mypvalues, mypost)
	# cal star
	pvalues <- subset(mypvalues,select=p.value.2s)
	outpvalues <- data.frame(pvalues)[,1]
	stars <- lapply(outpvalues,GetStar)
	stars <- as.data.frame(as.matrix(stars))
	# create result
	rt <- data.frame(
			mapply(paste,mypvalues[9],'-',mypvalues[10]),
			mypvalues[8],
			'',
			'',
			stars,
			'',
			'Steel'
		)
	colnames(rt) <- c('categories','p-value','coefficients','t-stat','Signif-codes','alternative','Method')
	return(rt)
}

###################################
#
#	HaveZeroOrMinus : check if there are some 0 or under 0 value in list(data)
#
###################################
HaveZeroOrMinus <- function(data)
{
	rt = TRUE
	if(length(which(data<=0)))
	{
		rt = TRUE
	}else{
		rt = FALSE
	}
	return(rt)
}

###################################
#
#	IsNumericData : is data numeric
#
###################################
IsNumericData <- function(data)
{
	for (i in 1:ncol(data))
	{
		if (!is.numeric(data[[i]]))
		{
			return(FALSE)
		}
	}
	return(TRUE)
}

###################################
#
#	Wilcoxon : Wilcoxon JUNNIWA-KENTEI
#
###################################
Wilcoxon <- function(groupA, groupB)
{
	Message <<- c(Message,'Run Wilcoxon tests.')
	rt <- '-'
	
	result <-  wilcox.test(groupA,groupB, paired = FALSE, alternative = 'two.sided')
	
	stars <- lapply(as.list(result$p.value),GetStar)
	rt <- data.frame(result$p.value, '','',stars, result$alternative, result$method)
	colnames(rt) <- c('p-value', 'coefficients','t-stat','Signif-codes', 'alternative', 'Method')
	return(rt)
}

###################################
#
#	TTest : T-KENETI
#
###################################
TTest <- function(groupA, groupB, isWelch)
# return *, ** or others depend on p-value
{
	rt <- '-'
	if(isWelch){
		Message <<- c(Message,'Run Welch.')
		result <- t.test(groupA, groupB, var.equal=F)
	}else{
		Message <<- c(Message,'Run t-test.')
		result <- t.test(groupA, groupB, var.equal=T)
	}
	pvalue <- result$p.value
	stars <- lapply(as.list(pvalue),GetStar)
	rt <- data.frame(pvalue,'', '', stars, result$alternative, result$method)
	colnames(rt) <- c('p-value', 'coefficients','t-stat','Signif-codes', 'alternative', 'Method')
	
	return(rt)
}

###################################
#
#	VarTest : KENTEI for TOUBUNSAN: F-KENTEI
#
###################################
# return TRUE if TOUBUNSAN, FALSE if FUTOUBUNSAN
VarTest <- function(groupA, groupB)
{
	Message <<- c(Message,'Run var test.')
	result <- var.test(groupA, groupB)
	Message <<- c(Message,paste('p-value is',result$p.value))
	if (result$p.value >= 0.01)
	{
		return(TRUE)
	}else{
		return(FALSE)
	}
}

###################################
#
#	VarTestBartlett * KENTEI for TOUBUNSAN : Bartlett KENTEI
#
###################################
# return TRUE for TOUBUNSAN, FALSE for FUTOU-BUNSAN
VarTestBartlett <- function(data, category)
{
	Message <<- c(Message,'Run Bartlett test.')
	result <- bartlett.test(data, category)
	Message <<- c(Message,paste('p-value is',result$p.value))
	if (result$p.value >= 0.01)
	{
		return(TRUE)
	}else{
		return(FALSE)
	}
}

###################################
#
#	Bunsan BUNSAN-KENTEI
#
###################################
Bunsan <- function(inData)
{
	Message <<- c(Message,'Run variance analysis (anova).')
	result <- anova(lm(value ~ cat, inData))

	pValue <- result$Pr[1]
	Message <<- c(Message,paste('p-value is',pValue))
	if (pValue< 0.05)
	{
		return(TRUE)
	}else{
		return(FALSE)
	}
}

###################################
#
#	Williams : Williams TAJUUHIKAKU
#
###################################
Williams <- function(   data,                           # data vector
                        group,                          # GUN vector
                        method=c('up', 'down'))         # select methods
{
		Message <<- c(Message,'Run Williams multiple comparison.')
        OK <- complete.cases(data, group)               # select case for no-KEKKANCHI
        data <- data[OK]
        group <- group[OK]
        method <- match.arg(method)                     # HIKISUU NO HOKAN
        func <- if (method == 'down') min else max      # select min/max depend on HIKISUU
        n.i <- tapply(data, group, length)              # KAKUGUNN NO REISUU
        sum.i <- tapply(data, group, sum)               # KAKUGUNN GOTONO SOUWA
        mean.i <- tapply(data, group, mean)             # GUNN GOTONO KEIKINTI
        v.i <- tapply(data, group, var)                 # GUNN GOTONO FUTOUBUNSAN
        a <- length(n.i)                                # GUNN NO KAZU
        phi.e <- sum(n.i)-a                             # GUSABUNSAN NO JIYUUDO
        v.e <- sum((n.i-1)*v.i)/phi.e                   # GOSA BUNSAN
        t <- sapply(a:2,                                # calculate t-value
                    function(p) (func(cumsum(rev(sum.i[2:p]))/cumsum(rev(n.i[2:p]))) - mean.i[1])/sqrt(v.e*(1/n.i[1]+1/n.i[p])))
        names(t) <- c(a:2)                              # add name
        return(list(phi.e=phi.e, t=if (method == 'down') -t else t))
}

###################################
#
#	Kruskal-Wallis:Kruskal-Wallis NO JUNIKENTEI
#
###################################
Kruskal_Wallis <- function(
		data,
		group)
{
	Message <<- c(Message,'Run Kruskal-Wallis sign test.')
	result <- kruskal.test(data, group)
	Message <<- c(Message,paste('p-value is',result$p.value))
	if (result$p.value >= 0.05)
	{
		return(FALSE)
	}else{
		return(TRUE)
	}
}

###################################
#
#	Glht
#
###################################
Glht <- function(data,					# data vetor
                 method)         			# method
{
	colnames(data) <- c('value', 'cat')
	#Message <<- c(Message,'In Glht function.')
	#attach(data)
	myAllData <- na.omit(data)
	
	#print(myAllData)
	
	r1 <- aov(value~cat,data=myAllData)
	#Message <<- c(Message,'aov in end.')
	r2 <- glht(r1,linfct = mcp(cat =method))
	temp <- confint(r2,level=0.95)
	r3 <- summary(r2)
	
	stars <- lapply(as.list(r3$test$pvalues),GetStar)
	stars <- as.data.frame(as.matrix(stars))
	
	rt <- data.frame(r3$test$pvalues, r3$test$coefficients,r3$test$tstat,stars,'',method)
	rt <- data.frame(rownames(rt),rt,row.names=NULL)
	colnames(rt) <- c('categories','p-value','coefficients','t-stat','Signif-codes','alternative','Method')
	return(rt)
}

###################################
#
#	GetStar
#
###################################
GetStar <- function(inPValue)
{
	rt = ' '
	if(inPValue <= 0.1)	{rt = '.'}
	if(inPValue <= 0.05)	{rt = '*'}
	if(inPValue <= 0.01)	{rt = '**'}
	if(inPValue <= 0.001)	{rt = '***'}
	
	return(rt)
}

###################################
#
#	DunnettTukey
#
###################################
DunnettTukey <- function(inData,inCategory)
{
	Message <<- c(Message,'Run Dunnett multiple comparison.')
	dunnettResult <- Glht(data.frame(inData,inCategory),'Dunnett')
	#Message <<- c(Message,'Run Tukey multiple comparison.')
	#tukeyResult <- Glht(data.frame(inData,inCategory),'Tukey')
	#return(rbind(dunnettResult,tukeyResult))
	return(dunnettResult)
}

###################################
#
#	FromKruskai Modified from FromKruskaiCoin  Junhong Bai 2018/11/15
#
###################################
FromKruskai <- function(inData,inCategory)
{
  Message <<- c(Message,'Run Kruskal_Wallis test.')
  myTestData <- data.frame(inData, inCategory)
  colnames(myTestData) <- c('value','category')
  kw <- kruskal.test(value ~ category, data = myTestData) 
  #kruskal_test is a function of coin package
  pvalue <- kw$p.value  #Junhong Bai
  Message <<- c(Message,paste('p-value is',pvalue))
  if(pvalue <= 0.05)	# 
  {
    Message <<- c(Message,'Data was significant different.')
    #		Message <<- c(Message,'Steel-Dwass test (coin module) will started.')
    #		Steel_Dwass_coin_result <- Steel_Dwass_coin(inData,inCategory)
    Message <<- c(Message,'Steel test (nmpc module) will started.')
    Steel_npmc_result <- Steel_npmc(inData,inCategory)
    #		return(rbind(Steel_Dwass_coin_result, Steel_npmc_result))
    return(Steel_npmc_result)
  }
  else
  {
    Message <<- c(Message,'Data was not significant different.')
    Message <<- c(Message,paste('p-value is',pvalue))
    Message <<- c(Message,'No test will be done.')
    return(NULL)
  }
}

###################################
#
#	FromKruskaiCoin in coin module
#
###################################
FromKruskaiCoin <- function(inData,inCategory)
{
	Message <<- c(Message,'Run Kruskal_Wallis test.')
	myTestData <- data.frame(inData, inCategory)
	colnames(myTestData) <- c('value','category')
	kw <- kruskal_test(value ~ category, data = myTestData, distribution = approximate(B = 9999)) 
	#kruskal_test is a function of coin package
	pvalue <- kw$p.value  #Junhong Bai
	Message <<- c(Message,paste('p-value is',pvalue))
	if(pvalue <= 0.05)	# 
	{
		Message <<- c(Message,'Data was significant different.')
#		Message <<- c(Message,'Steel-Dwass test (coin module) will started.')
#		Steel_Dwass_coin_result <- Steel_Dwass_coin(inData,inCategory)
 		Message <<- c(Message,'Steel test (nmpc module) will started.')
 		Steel_npmc_result <- Steel_npmc(inData,inCategory)
#		return(rbind(Steel_Dwass_coin_result, Steel_npmc_result))
		 return(Steel_npmc_result)
	}
	else
	{
		Message <<- c(Message,'Data was not significant different.')
		Message <<- c(Message,paste('p-value is',pvalue))
		Message <<- c(Message,'No test will be done.')
		return(NULL)
	}
}

###################################
#
#	MultiFisherChisq
#
###################################
# Add below function to avoid TERR 4.5.0 bug  Junhong Bai
TableToDouble <- function(Table)
{
  storage.mode(Table) <- "double"
  Table
}


MultiFisherChisq <- function(inCrossTable, inType){
	rt <- NULL
	for (i in 1:(nrow(inCrossTable)-1))
	{
		for (j in (i+1):nrow(inCrossTable))
		{
			if (inType == 'fisher'){
			  
				myResult <- fisher.test(TableToDouble(inCrossTable[c(i,j),]))
		

			}else{
				myResult <- chisq.test(inCrossTable[c(i,j),])
			}
			mycategorynames <- rownames(inCrossTable[c(i,j),])
			mycategory <- paste(mycategorynames[1],'-',mycategorynames[2])
			if (inType == 'fisher'){
				fisherRt <- data.frame(mycategory, myResult$p.value, '','',lapply(as.list(myResult$p.value),GetStar), myResult$alternative, myResult$method)
			}else{
				fisherRt <-  data.frame(mycategory, myResult$p.value, '','',lapply(as.list(myResult$p.value),GetStar), '', myResult$method)
			}
			colnames(fisherRt) <- c('categories','p-value', 'coefficients','t-stat','Signif-codes', 'alternative', 'Method')
			if (is.null(rt))
			{
				rt <- fisherRt
			}else{
				rt <- rbind(rt,fisherRt)
			}
		}
	}
	return(rt) #Added by Junhong
}

###################################
#
#	FisherAndChisq
#
###################################
FisherAndChisq <- function(inData)
{
	Message <<- c(Message,'Fisher and Chisq test will be started.')
	# data preparation
	colnames(inData) <- c('cat', 'value')
	crosstable <- table(inData)
	
	# fisher, chesq
	#fisherResult <- fisher.test(crosstable)
	#chisqResult <- chisq.test(crosstable)

	#fisherRt <- data.frame(fisherResult$p.value, '','',lapply(as.list(fisherResult$p.value),GetStar), fisherResult$alternative, fisherResult$method)
	#Message <<- c(Message,'Fisher test was finished.')
	#colnames(fisherRt) <- c('p-value', 'coefficients','t-stat','Signif-codes', 'alternative', 'Method')
	#chisqRt <-  data.frame(chisqResult$p.value, '','',lapply(as.list(chisqResult$p.value),GetStar), '', chisqResult$method)
	#Message <<- c(Message,'Chisq test was finished.')
	#colnames(chisqRt) <- c('p-value', 'coefficients','t-stat','Signif-codes', 'alternative', 'Method')
	
	fisherRt <- MultiFisherChisq(crosstable,'fisher')
	chisqRt <- MultiFisherChisq(crosstable,'chisq')
	
	rt <- rbind(fisherRt,chisqRt)
	
	#colnames(rt) <- c('p-value', 'coefficients','t-stat','Signif-codes', 'alternative', 'Method')
	return(rt)
}

###################################
#
#	FromBunsan
#
###################################
FromBunsan <- function(inData,inCategory)
{
	isSignificantDifference <-  Bunsan(data.frame(inData,inCategory))
	if(isSignificantDifference == TRUE)
	{
		# YUUISA ARI -> FUSUKUU NO TAJUUHIKAKU HE
		Message <<- c(Message,'Data was significant different.')
		#Message <<- c(Message,'Dunnett and Tukey test will be started.')
		Message <<- c(Message,'Dunnett test will be started.')
		return(DunnettTukey(inData,inCategory))
	}else{
		# YUUISA NASHI -> Williams NO TAJUUHIKAKU NIHA IKAZU, SONOMAMA give-up, end
		Message <<- c(Message,'Data was not significant different.')
		Message <<- c(Message,'No test will be done.')
		return(NULL)
	}
}

###################################
#
#	Parametric
#
###################################
Parametric <- function(inData, inCategory)
{
	# check is data numeric
	if (!IsNumericData(inData))
	{
		Message <<- c(Message,'Error in data. There are some unnumeric data.')
		return(NULL)
	}
	
	catNo <- length(unique(inCategory[,1]))
	isTwoGroup = FALSE		# 2 groups
	if(catNo == 0){
		Message <<- c(Message,'Error in grouping.')
		return
	}else if (catNo==2){
		Message <<- c(Message,'Grouping is two.')
		isTwoGroup = TRUE
	}else{
		Message <<- c(Message,'Grouping is multi.')
		isTwoGroup = FALSE
	}

	allDataSet <- data.frame(inData,inCategory)

	returnResult <- NULL
	resultDataFrame <- NULL
	if(isTwoGroup == TRUE)
	{
		# 2GUN KENTEI
		Message <<- c(Message,'Two group test.')
		catA <- levels(unique(inCategory[,1]))[1]
		catB <- levels(unique(inCategory[,1]))[2]
		dataA <- subset(allDataSet,inCategory==catA)[['value']]
		dataB <- subset(allDataSet,inCategory==catB)[['value']]
		
		# F-test
		isEqualVariance <- VarTest(dataA, dataB)
		if(isEqualVariance == TRUE)
		{
			# TOUBUNSAN -> T-KENTEI
			Message <<- c(Message,'Data was homoscedastic.')
			Message <<- c(Message,'T-test will be started.')
			returnResult <- TTest(dataA,dataB, FALSE)
		}else{
			# FUTOUBUNSAN -> go next
			Message <<- c(Message,'Data was not homoscedastic.')
			if(HaveZeroOrMinus(dataA) || HaveZeroOrMinus(dataB))
			{
				# go Wilcoxon using raw data
				Message <<- c(Message,'Data had some zero or minus values.')
				Message <<- c(Message,'Wilcoxon test will be started.')
				returnResult <- Wilcoxon(dataA,dataB)
			}else{
				Message <<- c(Message,'Data had no zero and no minus value.')
				# F-KENTEI with TAISUU
				isEqualVariance <- VarTest(log(dataA), log(dataB))
				if(isEqualVariance == TRUE)
				{
					# TOUBUNSAN -> T-KENTEI
					Message <<- c(Message,'Data was homoscedastic.')
					Message <<- c(Message,'T-test will be started.')
					returnResult <- TTest(dataA,dataB, FALSE)
				}else{
					# FUTOUBUNSAN -> Welch-KENTEI
					Message <<- c(Message,'Data was not homoscedastic.')
					Message <<- c(Message,'Welch test will be started.')
					returnResult <- TTest(dataA,dataB, TRUE)
				}
			}
		}
		return(returnResult)
	}else{
		# TAGUN-KENTEI
		Message <<- c(Message,'Multi group test.')
		datas <- inData[[1]]
		categories <- inCategory[[1]]
		isEqualVariance <- VarTestBartlett(datas, categories)
		if(isEqualVariance == TRUE)
		{
			# TOUBUNSAN -> BUNSAN BUNSEKI
			Message <<- c(Message,'Data was homoscedastic.')
			returnResult <- FromBunsan(inData,inCategory)
		}else{
			# FUTOUBUNSAN -> TAISUU HENKAN
			Message <<- c(Message,'Data was not homoscedastic.')
			# check if TAISUU HENKAN able?
			if(HaveZeroOrMinus(inData))
			{
				# TAISUU HENKANN disable
				# Kruskal-Wallis KENTEI and below using raw data
				#returnResult <- FromKruskaiCoin(datas,categories)
			  returnResult <- FromKruskai(datas,categories)   #Switched calling to FromKruskai.  Junhong Bai 2018/11/15
			}else{
				# TAISUU HENKAN able
				# Bartlett TOUBUNSAN KENTEI
				isEqualVariance <- VarTestBartlett(log(datas), categories)
				if(isEqualVariance == TRUE)
				{
					Message <<- c(Message,'Data was homoscedastic .')
					# TOUBUNSAN -> BUNSAN BUNSEKI
					returnResult <- FromBunsan(log(inData), inCategory)
				}else{
					Message <<- c(Message,'Data was not homoscedastic .')
					# FUTOUBUNSAN -> Kruskai using raw data
					# returnResult <- FromKruskaiCoin(datas,categories)  
					returnResult <- FromKruskai(datas,categories)    #Switched calling to FromKruskai.  Junhong Bai 2018/11/15
				}
			}
		}
		return(returnResult)
	}
}

CleanList <- function(inList)
{
	rt <- c()
	for (i in 1:length(inList))
	{
		rt <- c(rt,inList[[i]])
	}
	return(rt)
}

###################################
#
#	Non-parametric
#
###################################
NonParametric <- function(inData, inCategory)
{
	rt <- NULL
	# check is data numeric
	if (!IsNumericData(inData))
	{
		rt <- FisherAndChisq(data.frame(inCategory, inData))
	}else{
		catNo <- length(unique(inCategory[,1]))
		isTwoGroup = FALSE		# 2 groups
		if(catNo == 0){
			Message <<- c(Message,'Error in grouping.')
			return(NULL)
		}else if (catNo==2){
			Message <<- c(Message,'Grouping is two.')
			isTwoGroup = TRUE
		}else{
			Message <<- c(Message,'Grouping is multi.')
			isTwoGroup = FALSE
		}
		
		allDataSet <- data.frame(inData,inCategory)

		returnResult <- NULL
		resultDataFrame <- NULL
		if(isTwoGroup == TRUE)
		{
			# Go Wilcoxon
			Message <<- c(Message,'Two group test.')
			catA <- levels(unique(inCategory[,1]))[1]
			catB <- levels(unique(inCategory[,1]))[2]
			dataA <- subset(allDataSet,inCategory==catA)[['value']]
			dataB <- subset(allDataSet,inCategory==catB)[['value']]
			
			Message <<- c(Message,'Wilcoxon test will be started.')
			if (length(dataA) == length(dataB)){
				returnResult <- Wilcoxon(dataA,dataB)
			}else{
				returnResult <- Wilcoxon(dataA,dataB)
			}
			rt <- data.frame(c(paste(catA,catB)))
			colnames(rt) <- c('categories')
			rt <- cbind(rt,returnResult)
		}else{
			# Go Kruskal-Wallis
			datas <- inData[[1]]
			categories <- inCategory[[1]]
			#returnResult <- FromKruskaiCoin(datas,categories)
			returnResult <- FromKruskai(datas,categories)  #Switched to FromKruskai  Junhong Bai 2018/11/15
			#print('---------')
			#print(returnResult)
			rt <- returnResult
		}
	}
	return(rt)
}


###################################
#
#	Start
#
###################################


if (FALSE)	# for Debug
{
	Message <- c()
	Message <<- c(Message,is.numeric(Data_Columns[1,1]))

	resultAll <- Data_Columns

	returnMessage <- data.frame(Message)
	colnames(returnMessage) <- c('message')

}else
{
	my_data <- Data_Columns
	my_cat <- Category_Columns
	my_ParamKind <- Calculate_Kind

	# set my_cat to single column from multi column 
	cat_temp <- NULL
	for (i in 1:ncol(my_cat))
	{
		if(is.null(cat_temp))
		{
			cat_temp <- paste('[',my_cat[[i]])
			cat_temp <- paste(cat_temp,']')
		}else{
			cat_temp <- paste(cat_temp,'[')
			cat_temp <- paste(cat_temp,my_cat[[i]])
			cat_temp <- paste(cat_temp,']')
		}
	}
	my_cat <- data.frame(cat_temp)
	colnames(my_cat) <- 'cat'

	# loop in muti data column
	resultAll <- NULL		# Global Variable
	messageAll <- NULL		# Global Variable
	for (i in 1:ncol(my_data))			# loop for each data
	{
		Message <- c()
		result <- '-'
		
		Message <<- c(Message,paste('Start to check for ',colnames(my_data[i])))
		#print(i)
		temp_value <- my_data[i]
		colnames(temp_value) <- 'value'
		if (my_ParamKind == 'Parametric')
		{
			Message <<- c(Message,'User selected [Parametric] calculations.')
			result <- Parametric(temp_value, my_cat)
		}else{
			Message <<- c(Message,'User selected [Non-parametric] calculations.')
			result <- NonParametric(temp_value, my_cat)
		}
		#print(result)
		if(!is.null(result))
		{
			oldColNames <- colnames(result)
			result <- data.frame(colnames(my_data[i]), result)
			colnames(result) <- c('Value Name', oldColNames)
		}
		
		if(is.null(resultAll))
		{
			resultAll <- result
		}else{
			resultAll <- rbind(resultAll,result)
		}
		messageAll <- c(messageAll, Message)
		
		#print(resultAll)
	}
	
	# sum up messages
	returnMessage <- data.frame(1:length(messageAll),messageAll)
	colnames(returnMessage) <- c('step','message')
	
	# clean up return data.frame
	if(is.null(resultAll))
	{}else{
		for (i in 1:ncol(resultAll))
		{
			resultAll[,i] <- CleanList(as.vector(resultAll[,i]))
		}
	}
	for (i in 1:ncol(returnMessage))
	{
		returnMessage[,i] <- CleanList(as.vector(returnMessage[,i]))
	}

}
