# USAGE:
# ruby get_common_proteins.rb data/mouse_liver_all.csv results/common_proteins_mouse_liver.xlsx
# ruby get_common_proteins.rb data/All_protein_platelets.csv results/common_proteins_platelets.xlsx

# Create protein lists with the common protein between 3 conditions.

require 'rubygems'
require 'csv'
require 'axlsx'

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
CSV.foreach(ifile) do |row|
	if row[0] != "Accession" && row[0] != "" 
		if row[11] != ""
			counts1_list[row[0]] << 1
		end
		if row[12] != ""
			counts2_list[row[0]] << 1
		end
		if row[13] != ""
			counts3_list[row[0]] << 1
		end
		if row[11] != "" && row[12] != "" && row[13] != ""
			counts123_list[row[0]] << 1
		end
		if row[11] != "" && row[12] != ""
			counts12_list[row[0]] << 1
		end
		if row[11] != "" && row[13] != ""
			counts13_list[row[0]] << 1
		end
		if row[12] != "" && row[13] != ""
			counts23_list[row[0]] << 1
		end
	end
end

total_1 = 0
counts1_list.each do |prot, count|
	total_1 += counts1_list[prot].inject(0){|sum, i| sum + i}
end
total_2 = 0
counts2_list.each do |prot, count|
	total_2 += counts2_list[prot].inject(0){|sum, i| sum + i}
end
total_3 = 0
counts3_list.each do |prot, count|
	total_3 += counts3_list[prot].inject(0){|sum, i| sum + i}
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
	sheet.add_row ["prot_acc", "commons", "count 1", "count 2", "count 3"]
	counts123_list.each do |protein, count|
		sheet.add_row [protein, count.inject(0){|sum,i| sum + i}, counts1_list[protein].inject(0){|sum,i| sum + i}, counts2_list[protein].inject(0){|sum,i| sum + i}, counts3_list[protein].inject(0){|sum,i| sum + i}]
		total_123 += count.inject(0){|sum,i| sum + i}
	end
	sheet.add_row ["", "", total_123, total_1, total_2, total_3]
end

# create list with common peptides between 1,2 conditions
results_wb.add_worksheet(:name => "common peptides in 12") do |sheet|
	sheet.add_row ["prot_acc", "commons", "count 1", "count 2"]
	counts12_list.each do |protein, count|
		sheet.add_row [protein, count.inject(0){|sum,i| sum + i}, counts1_list[protein].inject(0){|sum,i| sum + i}, counts2_list[protein].inject(0){|sum,i| sum + i}, counts3_list[protein].inject(0){|sum,i| sum + i}]
		total_12 += count.inject(0){|sum,i| sum + i}
	end
	sheet.add_row ["", "", total_12, total_1, total_2]
end

# create list with common peptides between 1,3 conditions
results_wb.add_worksheet(:name => "common peptides in 13") do |sheet|
	sheet.add_row ["prot_acc", "commons", "count 1", "count 3"]
	counts13_list.each do |protein, count|
		sheet.add_row [protein, count.inject(0){|sum,i| sum + i}, counts1_list[protein].inject(0){|sum,i| sum + i}, counts2_list[protein].inject(0){|sum,i| sum + i}, counts3_list[protein].inject(0){|sum,i| sum + i}]
		total_13 += count.inject(0){|sum,i| sum + i}
	end
	sheet.add_row ["", "", total_13, total_1, total_3]
end

# create list with common peptides between 2,3 conditions
results_wb.add_worksheet(:name => "common peptides in 23") do |sheet|
	sheet.add_row ["prot_acc", "commons", "count 2", "count 3"]
	counts23_list.each do |protein, count|
		sheet.add_row [protein, count.inject(0){|sum,i| sum + i}, counts1_list[protein].inject(0){|sum,i| sum + i}, counts2_list[protein].inject(0){|sum,i| sum + i}, counts3_list[protein].inject(0){|sum,i| sum + i}]
		total_23 += count.inject(0){|sum,i| sum + i}
	end
	sheet.add_row ["", "", total_23, total_2, total_3]
end

# create summary table
results_wb.add_worksheet(:name => "summary") do |sheet|
	sheet.add_row ["total 123", "total 12", "total 13", "total 23", "total 1", "total 2", "total 3"]
	sheet.add_row [total_123, total_12, total_13, total_23, total_1, total_2, total_3]
end

# write xlsx file
results_xlsx.serialize(ofile)
