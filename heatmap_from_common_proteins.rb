# USAGE:
# ruby heatmap_from_common_proteins.rb data/mouse_liver_all.csv results/abundances_for_common_proteins_mouse_liver.csv
# ruby heatmap_from_common_proteins.rb data/All_protein_platelets.csv results/abundances_for_common_proteins_platelets.csv

# Create heatmaps to heatmap the variation of the common proteins through 3 conditions.

require 'rubygems'
require 'csv'
require "rinruby" 
require 'descriptive-statistics'

ifile = ARGV[0]
ofile = ARGV[1]

# read the list
abundance1_list = Hash.new { |h,k| h[k] = [] }
abundance2_list = Hash.new { |h,k| h[k] = [] }
abundance3_list = Hash.new { |h,k| h[k] = [] }
CSV.foreach(ifile) do |row|
	if row[0] != "Accession" && row[0] != "" && row[2] != "0"
		if row[11] != "" && row[12] != "" && row[13] != ""
			abundance1_list[row[0]] << row[11].to_f
			abundance2_list[row[0]] << row[12].to_f
			abundance3_list[row[0]] << row[13].to_f
		end
	end
end

total_abundance1_list = {}
abundance1_list.each do |prot, abundance|
	total_abundance1_list[prot] = abundance.inject(0){|sum,i| sum + i}
end

total_abundance2_list = {}
abundance2_list.each do |prot, abundance|
	total_abundance2_list[prot] = abundance.inject(0){|sum,i| sum + i}
end

total_abundance3_list = {}
abundance3_list.each do |prot, abundance|
	total_abundance3_list[prot] = abundance.inject(0){|sum,i| sum + i}
end

CSV.open(ofile, "wb") do |csv|
	csv << ["prot_acc", "Condition1", "Condition2", "Condition3", "cv"]
	total_abundance1_list.each do |prot, abundance|
		stats = DescriptiveStatistics::Stats.new([abundance, total_abundance2_list[prot], total_abundance3_list[prot]])
		cv = (stats.standard_deviation / stats.mean) * 100
		csv << [prot, abundance, total_abundance2_list[prot], total_abundance3_list[prot], cv]
	end
end

# create heatmap
R.eval <<EOF
library(gplots)
# library(raster)
# library(Matrix)

msdata <- read.csv("#{ofile}", sep=",")
sorted_bycv_data <- msdata[order(msdata$cv),]
rnames <- sorted_bycv_data[,1]
msmatrix <- data.matrix(sorted_bycv_data[,2:ncol(sorted_bycv_data)])
rownames(msmatrix) <- rnames

# sorted_bycv_data[2,1:5]
# msmatrix[2,1:4]
# length(msmatrix[,4])

pdf('#{ofile}_heatmap.pdf')
heatmap(msmatrix, Rowv=NA, Colv=NA, col = heat.colors(256), margins=c(12,1), labRow = FALSE)
dev.off()

# pdf('#{ofile}_cv.pdf')
# image(msmatrix[2:length(msmatrix[,4]),4], col = heat.colors(256)) #zlim = c(msmatrix[2,4],msmatrix[length(msmatrix[,4]),4]),
# dev.off()

EOF
