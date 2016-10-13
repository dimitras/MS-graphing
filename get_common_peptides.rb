# USAGE:
# ruby get_common_peptides.rb data/peptides_mouse_liver.csv results/common_peptides_mouse_liver.xlsx
# ruby get_common_peptides.rb data/peptides_platelets.csv results/common_peptides_platelets.xlsx

# Create peptide lists with the common peptides between 3 conditions.

require 'rubygems'
require 'csv'
require 'axlsx'
require "rinruby" 

ifile = ARGV[0]
ofile = ARGV[1]

# read the list
counts123_list = Hash.new { |h,k| h[k] = [] }
counts12_list = Hash.new { |h,k| h[k] = [] }
counts13_list = Hash.new { |h,k| h[k] = [] }
counts23_list = Hash.new { |h,k| h[k] = [] }
counts1_list = Hash.new { |h,k| h[k] = [] }
counts2_list = Hash.new { |h,k| h[k] = [] }
counts3_list = Hash.new { |h,k| h[k] = [] }
prot_list = {}
CSV.foreach(ifile) do |row|
	if row[9] != "Sequence" && row[9] != "" 
		if row[20] == "1"
			counts1_list[row[9]] << 1
		end
		if row[21] == "1"
			counts2_list[row[9]] << 1
		end
		if row[22] == "1"
			counts3_list[row[9]] << 1
		end
		if row[20] == "1" && row[21] == "1" && row[22] == "1"
			counts123_list[row[9]] << 1
		end
		if row[20] == "1" && row[21] == "1"
			counts12_list[row[9]] << 1
		end
		if row[20] == "1" && row[22] == "1"
			counts13_list[row[9]] << 1
		end
		if row[21] == "1" && row[22] == "1"
			counts23_list[row[9]] << 1
		end
		prot_list[row[9]] = row[11]
	end
end

total_1 = 0
counts1_list.each do |pep, count|
	total_1 += counts1_list[pep].inject(0){|sum, i| sum + i}
end
total_2 = 0
counts2_list.each do |pep, count|
	total_2 += counts2_list[pep].inject(0){|sum, i| sum + i}
end
total_3 = 0
counts3_list.each do |pep, count|
	total_3 += counts3_list[pep].inject(0){|sum, i| sum + i}
end

# output
results_xlsx = Axlsx::Package.new
results_wb = results_xlsx.workbook
total_123 = 0
total_12 = 0
total_13 = 0
total_23 = 0

# create list with common peptides between 3 conditions
results_wb.add_worksheet(:name => "common peptides in 123") do |sheet|
	sheet.add_row ["prot_acc", "pep_seq", "commons", "count 1", "count 2", "count 3"]
	counts123_list.each do |peptide, count|
		sheet.add_row [prot_list[peptide], peptide, count.inject(0){|sum,i| sum + i}, counts1_list[peptide].inject(0){|sum,i| sum + i}, counts2_list[peptide].inject(0){|sum,i| sum + i}, counts3_list[peptide].inject(0){|sum,i| sum + i}]
		total_123 += count.inject(0){|sum,i| sum + i}
	end
	sheet.add_row ["", "", total_123, total_1, total_2, total_3]
end

# create list with common peptides between 1,2 conditions
results_wb.add_worksheet(:name => "common peptides in 12") do |sheet|
	sheet.add_row ["prot_acc", "pep_seq", "commons", "count 1", "count 2", "count 3"]
	counts12_list.each do |peptide, count|
		sheet.add_row [prot_list[peptide], peptide, count.inject(0){|sum,i| sum + i}, counts1_list[peptide].inject(0){|sum,i| sum + i}, counts2_list[peptide].inject(0){|sum,i| sum + i}, counts3_list[peptide].inject(0){|sum,i| sum + i}]
		total_12 += count.inject(0){|sum,i| sum + i}
	end
	sheet.add_row ["", "", total_12, total_1, total_2, total_3]
end

# create list with common peptides between 1,3 conditions
results_wb.add_worksheet(:name => "common peptides in 13") do |sheet|
	sheet.add_row ["prot_acc", "pep_seq", "commons", "count 1", "count 2", "count 3"]
	counts13_list.each do |peptide, count|
		sheet.add_row [prot_list[peptide], peptide, count.inject(0){|sum,i| sum + i}, counts1_list[peptide].inject(0){|sum,i| sum + i}, counts2_list[peptide].inject(0){|sum,i| sum + i}, counts3_list[peptide].inject(0){|sum,i| sum + i}]
		total_13 += count.inject(0){|sum,i| sum + i}
	end
	sheet.add_row ["", "", total_13, total_1, total_2, total_3]
end

# create list with common peptides between 2,3 conditions
results_wb.add_worksheet(:name => "common peptides in 23") do |sheet|
	sheet.add_row ["prot_acc", "pep_seq", "commons", "count 1", "count 2", "count 3"]
	counts23_list.each do |peptide, count|
		sheet.add_row [prot_list[peptide], peptide, count.inject(0){|sum,i| sum + i}, counts1_list[peptide].inject(0){|sum,i| sum + i}, counts2_list[peptide].inject(0){|sum,i| sum + i}, counts3_list[peptide].inject(0){|sum,i| sum + i}]
		total_23 += count.inject(0){|sum,i| sum + i}
	end
	sheet.add_row ["", "", total_23, total_1, total_2, total_3]
end

# create summary table
results_wb.add_worksheet(:name => "summary") do |sheet|
	sheet.add_row ["total 123", "total 12", "total 13", "total 23", "total 1", "total 2", "total 3"]
	sheet.add_row [total_123, total_12, total_13, total_23, total_1, total_2, total_3]
end

# write xlsx file
results_xlsx.serialize(ofile)

# create venn diagram
R.eval <<EOF
library(VennDiagram)
pdf('#{ofile}_venn.pdf')
draw.triple.venn(area1 = #{total_1}, area2 = #{total_2}, area3 = #{total_3}, n12 = #{total_12}, n23 = #{total_23}, n13 = #{total_13}, n123 = #{total_123}, category = c('Condition1', 'Condition2', 'Condition3'), lty = 'blank', fill = c('skyblue', 'pink1', 'mediumorchid'))
dev.off()
EOF