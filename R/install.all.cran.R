install.all.cran <- function(repos="http://cran.cnr.berkeley.edu/", libpath="", writecsv=TRUE, Ncpus){
	
	if(missing(Ncpus)){
		Ncpus <- max(1, parallel::detectCores()-2);
	}

	#set ncpus
	options("Ncpus" = Ncpus);
	
	#set libpath
	.libPaths(libpath);
	
	#set mirror
	options(repos=repos)
	options(warn=1);
	today <- as.Date(Sys.time());
	
	#packages that were installed from Ubuntu. 
	ub.libs <- tail(.libPaths(),2);
	ub.pkgs <- row.names(installed.packages(ub.libs)); 
	
	#packages that were installed from CRAN
	cr.libs <- head(.libPaths(),1);
	cr.pkgs <- row.names(installed.packages(cr.libs));
	
	#available packages on the repository
	all.pkgs <- row.names(available.packages());
	old.matrix <- old.packages(cr.libs)
	old.pkgs <- row.names(old.matrix);
	
	#packages on cran that we don't have yet.
	#new.pkgs <- new.packages(c(ub.libs,cr.libs));
	new.pkgs <- new.packages(cr.libs);
	new.matrix <- available.packages()[new.pkgs,];
	
	#update cran packages
	update.packages(cr.libs, ask=FALSE, checkBuilt=TRUE);
	
	#install new cran packages
	install.packages(new.pkgs);
	
	#Checking updated packages
	new.old.pkgs <- row.names(old.packages(cr.libs));
	update.success <- !(old.pkgs %in% new.old.pkgs)
	old.matrix <- cbind(old.matrix, success=update.success);
	
	#Checking installed packages:
	# new.new.pkgs <- new.packages(c(ub.libs,cr.libs));
	new.new.pkgs <- new.packages(cr.libs);
	install.success <- !(new.pkgs %in% new.new.pkgs)
	new.matrix <- cbind(new.matrix, success=install.success);
	
	#dump csv
	if(writecsv){
		write.csv(old.matrix, paste(today,"_updates.csv", sep=""), row.names=F);		
		write.csv(new.matrix, paste(today,"_newpackages.csv", sep=""), row.names=F);
	}
	
	#return matrices
	return(list(updates=old.matrix, newpackages=new.matrix));
}	
