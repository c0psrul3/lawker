gawk -F/ ' 
    { Seen[$NF]++
      Path[$NF]= Path[$NF] "  \n\t" Dir "/" $0 }
END { for(I in Seen)
        if (Seen[I] > 1) {
           Bad = 1
			print "Warning : " Seen[I] " repeats of " I  " at " Path[I]
	}
	if (Bad) exit -1
}'  Dir=$1 -
