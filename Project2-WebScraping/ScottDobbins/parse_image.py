# @author Scott Dobbins
# @version 0.7
# @date 2017-05-07 23:30


### import useful packages ###
from skimage import io
from datetime import datetime
from scipy import stats
import numpy as np
import pandas as pd
import os
import re
#import matplotlib#***


### flags for the developer ###
debug_mode_on = False
# image_type = "salesRank"

counter_max = 4


### useful constants ###

column_names = ["ASIN",
				"date_time",
				"title",
				"link",
				"group",
				"category",
				"manufacturer",
				"price_Amazon",
				"price_new",
				"price_used",
				"Amazon_mean",
				"Amazon_median",
				"Amazon_mode",
				"Amazon_std",
				"new_mean",
				"new_median",
				"new_mode",
				"new_std",
				"used_mean",
				"used_median",
				"used_mode",
				"used_std",
				"new_med1",
				"new_med2",
				"new_med3",
				"new_med_drop1",
				"new_med_drop2",
				"new_med_drop3",
				"new_med_rel_drop1",
				"new_med_rel_drop2",
				"new_med_rel_drop3"]


### class defs and such ###

class Product(object):

	def __init__(self, line_of_csv, image_directory):
		data = re.split(",(?=[^\s])", line_of_csv)
		# test if data is reasonable
		self.ASIN = data[0]
		self.date_time = datetime.strptime(data[1], "%Y-%m-%d %H:%M:%S.%f")
		self.title = data[2]
		self.link = data[3]
		self.group = data[4]
		self.category = data[5]
		self.manufacturer = data[6]
		self.price_Amazon = float(data[7])
		self.price_new = float(data[8])
		self.price_used = float(data[9])
		# test if image_directory exists and has the three images in it
		self.price_history_Amazon = self.parse_image(image_directory, "Amazon", np.float64)
		self.price_history_new = self.parse_image(image_directory, "new", np.float64)
		self.price_history_used = self.parse_image(image_directory, "used", np.float64)
		# self.salesRank_history = np.empty([8046], dtype = np.uint32)
		self.stats = {}
		if(self.price_history_Amazon[-1] == np.nan):
			self.stats['Amazon_mean'] = np.nan
			self.stats['Amazon_median'] = np.nan
			self.stats['Amazon_mode'] = np.nan
			self.stats['Amazon_std'] = np.nan
		else:
			self.stats['Amazon_mean'] = np.nanmean(self.price_history_Amazon, dtype = np.float64)
			self.stats['Amazon_median'] = np.nanmedian(self.price_history_Amazon)
			self.stats['Amazon_mode'] = stats.mode(self.price_history_Amazon, nan_policy = 'omit').mode[0]
			self.stats['Amazon_std'] = np.nanstd(self.price_history_Amazon, dtype = np.float64)
		if(self.price_history_new[-1] == np.nan):
			self.stats['new_mean'] = np.nan
			self.stats['new_median'] = np.nan
			self.stats['new_mode'] = np.nan
			self.stats['new_std'] = np.nan
			self.stats['new_med1'] = np.nan
			self.stats['new_med2'] = np.nan
			self.stats['new_med3'] = np.nan
			self.stats['new_med_drop1'] = np.nan
			self.stats['new_med_drop2'] = np.nan
			self.stats['new_med_drop3'] = np.nan
			self.stats['new_med_rel_drop1'] = np.nan
			self.stats['new_med_rel_drop2'] = np.nan
			self.stats['new_med_rel_drop3'] = np.nan
		else:
			self.stats['new_mean'] = np.nanmean(self.price_history_new, dtype = np.float64)
			self.stats['new_median'] = np.nanmedian(self.price_history_new)
			self.stats['new_mode'] = stats.mode(self.price_history_new, nan_policy = 'omit').mode[0]
			self.stats['new_std'] = np.nanstd(self.price_history_new, dtype = np.float64)
			len_new = len(self.price_history_new)
			third1 = len_new / 3
			third2 = 2*third1
			self.stats['new_med1'] = np.nanmedian(self.price_history_new[0:third1])
			self.stats['new_med2'] = np.nanmedian(self.price_history_new[third1:third2])
			self.stats['new_med3'] = np.nanmedian(self.price_history_new[third2:])
			self.stats['new_med_drop1'] = self.stats['new_med1'] - self.stats['new_med2']
			self.stats['new_med_drop2'] = self.stats['new_med2'] - self.stats['new_med3']
			self.stats['new_med_drop3'] = self.stats['new_med1'] - self.stats['new_med3']
			self.stats['new_med_rel_drop1'] = self.stats['new_med_drop1'] / self.stats['new_med1']
			self.stats['new_med_rel_drop2'] = self.stats['new_med_drop2'] / self.stats['new_med2']
			self.stats['new_med_rel_drop3'] = self.stats['new_med_drop3'] / self.stats['new_med1']
		if(self.price_history_used[-1] == np.nan):
			self.stats['used_mean'] = np.nan
			self.stats['used_median'] = np.nan
			self.stats['used_mode'] = np.nan
			self.stats['used_std'] = np.nan
		else:
			self.stats['used_mean'] = np.nanmean(self.price_history_used, dtype = np.float64)
			self.stats['used_median'] = np.nanmedian(self.price_history_used)
			self.stats['used_mode'] = stats.mode(self.price_history_used, nan_policy = 'omit').mode[0]
			self.stats['used_std'] = np.nanstd(self.price_history_used, dtype = np.float64)

	def data_to_file(self, output_dir):
		len_Amazon = len(self.price_history_Amazon)
		len_new = len(self.price_history_new)
		len_used = len(self.price_history_used)
		len_max = max(len_Amazon, len_new, len_used)
		if(len_Amazon == len_max):
			new_len_diff = len_max - len_new
			used_len_diff = len_max - len_used
			np.savetxt(fname = os.path.expanduser(output_dir + self.ASIN + ".csv"),
					   X = np.column_stack((self.price_history_Amazon, np.append(self.price_history_new, np.repeat(np.nan, new_len_diff)), np.append(self.price_history_used, np.repeat(np.nan, used_len_diff)))),
					   fmt = ['%s', '%s', '%s'],
					   delimiter = ',',
					   newline = '\n',
					   header = "price_history_Amazon,price_history_new,price_history_used")
		elif(len_new == len_max):
			Amazon_len_diff = len_max - len_Amazon
			used_len_diff = len_max - len_used
			np.savetxt(fname = os.path.expanduser(output_dir + self.ASIN + ".csv"),
					   X = np.column_stack((np.append(self.price_history_Amazon, np.repeat(np.nan, Amazon_len_diff)), self.price_history_new, np.append(self.price_history_used, np.repeat(np.nan, used_len_diff)))),
					   fmt = ['%s', '%s', '%s'],
					   delimiter = ',',
					   newline = '\n',
					   header = "price_history_Amazon,price_history_new,price_history_used")
		else:
			Amazon_len_diff = len_max - len_Amazon
			new_len_diff = len_max - len_new
			np.savetxt(fname = os.path.expanduser(output_dir + self.ASIN + ".csv"),
					   X = np.column_stack((np.append(self.price_history_Amazon, np.repeat(np.nan, Amazon_len_diff)), np.append(self.price_history_new, np.repeat(np.nan, new_len_diff)), self.price_history_used)),
					   fmt = ['%s', '%s', '%s'],
					   delimiter = ',',
					   newline = '\n',
					   header = "price_history_Amazon,price_history_new,price_history_used")



	def data_to_list_of_strings(self):
		return([self.ASIN,
				str(self.date_time),
				self.title,
				self.link,
				self.group,
				self.category,
				self.manufacturer,
				str(self.price_Amazon),
				str(self.price_new),
				str(self.price_used),
				str(self.stats['Amazon_mean']),
				str(self.stats['Amazon_median']),
				str(self.stats['Amazon_mode']),
				str(self.stats['Amazon_std']),
				str(self.stats['new_mean']),
				str(self.stats['new_median']),
				str(self.stats['new_mode']),
				str(self.stats['new_std']),
				str(self.stats['used_mean']),
				str(self.stats['used_median']),
				str(self.stats['used_mode']),
				str(self.stats['used_std']),
				str(self.stats['new_med1']),
				str(self.stats['new_med2']),
				str(self.stats['new_med3']),
				str(self.stats['new_med_drop1']),
				str(self.stats['new_med_drop2']),
				str(self.stats['new_med_drop3']),
				str(self.stats['new_med_rel_drop1']),
				str(self.stats['new_med_rel_drop2']),
				str(self.stats['new_med_rel_drop3'])])

	def data_to_csv_string(self):
		return(','.join(self.data_to_list_of_strings()))

	def parse_image(self, directory, image_type, data_type):
		# make sure directory and type are reasonable and that ASIN exists

		### read image and threshold ###

		if(image_type == "Amazon"):
			file_name = self.ASIN + "_Amazon.png"
			img = io.imread(os.path.expanduser(directory + file_name))
			green_max_red = 102
			green_min_green = 165
			green_max_blue = 102
			is_graph_line = (img[:,:,0] <= green_max_red) & (img[:,:,1] >= green_min_green) & (img[:,:,2] <= green_max_blue)
			starting_price = self.price_Amazon
		elif(image_type == "new"):
			file_name = self.ASIN + "_new.png"
			img = io.imread(os.path.expanduser(directory + file_name))
			blue_max_red = 204
			blue_max_green = 51
			blue_min_blue = 191
			is_graph_line = ((img[:,:,0] <= blue_max_red) | (img[:,:,1] <= blue_max_green)) & (img[:,:,2] >= blue_min_blue)
			starting_price = self.price_new
		elif(image_type == "used"):
			file_name = self.ASIN + "_used.png"
			img = io.imread(os.path.expanduser(directory + file_name))
			red_min_red = 204
			red_max_green = 51
			red_max_blue = 0
			is_graph_line = (img[:,:,0] >= red_min_red) & (img[:,:,1] <= red_max_green) & (img[:,:,2] <= red_max_blue)
			starting_price = self.price_used
		else:
			pass # raise error

		img_height = img.shape[0]
		img_width = img.shape[1]


		### find graph borders ###

		border_threshold = 215

		# find right border
		y_pos = img_height/2
		x_pos = img_width-1
		while(all(img[y_pos, x_pos, ] > border_threshold) and x_pos > img_width*0.9):
			x_pos -= 1
		if(x_pos <= img_width*0.9):
			if(debug_mode_on): print("bad first attempt at right border")
			right_border = img_width-1
		else:
			if(all(img[y_pos, x_pos-1, ] < border_threshold)):
				right_border = x_pos - 1
			else:
				if(debug_mode_on): print("maybe bug")
				right_border = x_pos

		y_pos += 10
		x_pos = img_width-1
		while(all(img[y_pos, x_pos, ] > border_threshold) and x_pos > img_width*0.9):
			x_pos -= 1
		if(x_pos <= img_width*0.9):
			if(debug_mode_on): print("bad second attempt at right border")
			if(right_border == img_width-1):
				right_border = x_pos
		else:
			if(all(img[y_pos, x_pos-1, ] < border_threshold)):
				if(right_border == x_pos - 1):
					if(debug_mode_on): print("right borders matched")
				elif(right_border < x_pos - 1):
					if(debug_mode_on): print("first attempt at right border better")
				else:
					if(debug_mode_on): print("second attempt at right border better")
					right_border = x_pos - 1
			else:
				if(debug_mode_on): print("maybe bug")
				right_border = x_pos

		# find left border
		y_pos = img_height/2
		x_pos = 0
		while(all(img[y_pos, x_pos, ] > border_threshold) and x_pos < img_width*0.1):
			x_pos += 1
		if(x_pos >= img_width*0.1):
			if(debug_mode_on): print("bad first attempt at left border")
			left_border = 0
		else:
			if(all(img[y_pos, x_pos+1, ] < border_threshold)):
				left_border = x_pos + 1
			else:
				if(debug_mode_on): print("maybe bug")
				left_border = x_pos

		y_pos += 10
		x_pos = 1
		while(all(img[y_pos, x_pos, ] > border_threshold) and x_pos < img_width*0.1):
			x_pos += 1
		if(x_pos >= img_width*0.1):
			if(debug_mode_on): print("bad second attempt at left border")
			if(left_border == 0):
				left_border = x_pos
		else:
			if(all(img[y_pos, x_pos+1, ] < border_threshold)):
				if(left_border == x_pos + 1):
					if(debug_mode_on): print("left borders matched")
				elif(left_border > x_pos + 1):
					if(debug_mode_on): print("first attempt at left border better")
				else:
					if(debug_mode_on): print("second attempt at left border better")
					left_border = x_pos + 1
			else:
				if(debug_mode_on): print("maybe bug")
				left_border = x_pos

		# find top border
		y_pos = 0
		x_pos = img_width/2
		while(all(img[y_pos, x_pos, ] > border_threshold) and y_pos < img_height*0.1):
			y_pos += 1
		if(y_pos >= img_height*0.1):
			if(debug_mode_on): print("bad first attempt at top border")
			top_border = 0
		else:
			if(all(img[y_pos+1, x_pos, ] < border_threshold)):
				top_border = y_pos + 1
			else:
				if(debug_mode_on): print("maybe bug")
				top_border = y_pos

		y_pos = 1
		x_pos += 10
		while(all(img[y_pos, x_pos, ] > border_threshold) and y_pos < img_height*0.1):
			y_pos += 1
		if(y_pos >= img_height*0.1):
			if(debug_mode_on): print("bad second attempt at top border")
			if(top_border == 0):
				top_border = y_pos
		else:
			if(all(img[y_pos+1, x_pos, ] < border_threshold)):
				if(top_border == y_pos + 1):
					if(debug_mode_on): print("top borders matched")
				elif(top_border > y_pos + 1):
					if(debug_mode_on): print("first attempt at top border better")
				else:
					if(debug_mode_on): print("second attempt at top border better")
					top_border = y_pos + 1
			else:
				if(debug_mode_on): print("maybe bug")
				top_border = y_pos

		# find bottom border
		y_pos = img_height-1

		x_pos = img_width/2
		while(all(img[y_pos, x_pos, ] > border_threshold) and y_pos > img_height*0.9):
			y_pos -= 1
		if(y_pos <= img_height*0.9):
			if(debug_mode_on): print("bad first attempt at bottom border")
			bottom_border = img_height-1
		else:
			if(all(img[y_pos, x_pos-1, ] < border_threshold)):
				bottom_border = y_pos - 1
			else:
				if(debug_mode_on): print("maybe bug")
				bottom_border = y_pos

		y_pos = img_height-1
		x_pos += 10
		while(all(img[y_pos, x_pos, ] > border_threshold) and y_pos > img_height*0.9):
			y_pos -= 1
		if(y_pos <= img_height*0.9):
			if(debug_mode_on): print("bad second attempt at bottom border")
			if(bottom_border == img_height-1):
				bottom_border = y_pos
		else:
			if(all(img[y_pos, x_pos-1, ] < border_threshold)):
				if(bottom_border == y_pos - 1):
					if(debug_mode_on): print("right borders matched")
				elif(bottom_border < y_pos - 1):
					if(debug_mode_on): print("first attempt at right border better")
				else:
					if(debug_mode_on): print("second attempt at right border better")
					bottom_border = y_pos - 1
			else:
				if(debug_mode_on): print("maybe bug")
				bottom_border = y_pos

		if(debug_mode_on): print(top_border, left_border, bottom_border, right_border)
		### find graph line on right side ###
		value = np.zeros(shape = [img_width], dtype = np.uint16)

		y_pos = bottom_border-2
		x_pos = right_border-1
		while(not(is_graph_line[y_pos, x_pos]) and y_pos >= top_border):
			y_pos -= 1
		if(y_pos < top_border):
			if(debug_mode_on): print("gave up")
			return(np.repeat(np.nan, (right_border - left_border - 1)))# can't parse; give up
		else:

			value[x_pos] = y_pos

			just_inched = False

			while(x_pos > left_border):
				if(is_graph_line[y_pos, x_pos-1]):
					if(debug_mode_on): print("easy")
					x_pos -= 1
					value[x_pos] = y_pos
					just_inched = False
				elif(is_graph_line[y_pos-1, x_pos] and is_graph_line[y_pos-2, x_pos]):
					while(is_graph_line[y_pos, x_pos]):
						y_pos -= 1
					y_pos += 1
					if(is_graph_line[y_pos, x_pos-1]):
						if(debug_mode_on): print("went up")
						x_pos -= 1
						value[x_pos] = y_pos
					else:
						if(is_graph_line[y_pos-2, x_pos] and is_graph_line[y_pos-2, x_pos-1]):
							if(debug_mode_on): print("dotted line overlap going up")
							y_pos -= 2
							x_pos -= 1
							value[x_pos] = y_pos
						else:
							if(debug_mode_on): print("error up and then down")
							break
					just_inched = False
				elif(is_graph_line[y_pos+1, x_pos] and is_graph_line[y_pos+2, x_pos]):
					while(is_graph_line[y_pos, x_pos]):
						y_pos += 1
					y_pos -= 1
					if(is_graph_line[y_pos, x_pos-1]):
						if(debug_mode_on): print("went down")
						x_pos -= 1
						value[x_pos] = y_pos
					else:
						if(is_graph_line[y_pos+2, x_pos] and is_graph_line[y_pos+2, x_pos-1]):
							y_pos += 2
							x_pos -= 1
							value[x_pos] = y_pos
						else:
							if(debug_mode_on): print("error down and then up")
							break
					just_inched = False
				else:
					starting_x_pos = x_pos
					x_pos -= 1
					counter = 0
					while(not(is_graph_line[y_pos, x_pos]) and counter < counter_max):
						x_pos -= 1
						counter += 1
					if(counter == counter_max):
						x_pos = starting_x_pos
						if(is_graph_line[y_pos+2, x_pos]):#} and is_graph_line[y_pos+3, x_pos]) {
							y_pos += 2
							while(is_graph_line[y_pos, x_pos]):
								y_pos += 1
							y_pos -= 1
							if(is_graph_line[y_pos, x_pos-1]):
								if(debug_mode_on): print("went down after dotted line overlap")
								x_pos -= 1
								value[x_pos] = y_pos
							else:
								if(debug_mode_on): print("fail")
								break
							just_inched = False
						elif(is_graph_line[y_pos-2, x_pos]):#} and is_graph_line[y_pos-3, x_pos]) {
							y_pos -= 2
							while(is_graph_line[y_pos, x_pos]):
								y_pos -= 1
							y_pos += 1
							if(is_graph_line[y_pos, x_pos-1]):
								if(debug_mode_on): print("went up after dotted line overlap")
								x_pos -= 1
								value[x_pos] = y_pos
							else:
								if(debug_mode_on): print("fail")
								break
							just_inched = False
						else:
							if(just_inched):
								if(debug_mode_on): print("stuck at dead end")
								break
							else:
								if(is_graph_line[y_pos-1, x_pos]):
									if(debug_mode_on): print("inched up")
									y_pos -= 1
									value[x_pos] = y_pos
									just_inched = True
								elif(is_graph_line[y_pos+1, x_pos]):
									if(debug_mode_on): print("inched down")
									y_pos += 1
									value[x_pos] = y_pos
									just_inched = True
								else:
									if(debug_mode_on): print("error jumping")
									break
					else:
						if(debug_mode_on): print("jumped")
						value[x_pos:starting_x_pos] = y_pos
						just_inched = False


			### calculate desired quantity ###
			value = value[left_border:right_border]

			min_value = min(value)
			max_value = max(value)
			value_scale = max_value - min_value

			if(image_type == "salesRank"):
				# rank_scale = min_rank - max_rank
				# rank = max_rank + (rank_scale / float(value_scale) * (value - min_value))
				rank = np.array(((value - top_border) / float(value[-1] - top_border)) * (starting_rank-1), dtype = data_type)
				return(rank)
			else:
				# price_scale = max_price - min_price
				# price = min_price + (price_scale / float(value_scale) * (max_value - value))
				price = np.array(((bottom_border - value) / float(bottom_border - value[-1])) * starting_price, dtype = data_type)
				return(price)


### get useful values ###
#project_directory_string = "~/Documents/School/NYC Data Science Academy/projects/web scraping/"
#project_directory = re.sub(' ', ' ', project_directory_string)
project_directory = "~/Documents/School/NYC Data Science Academy/projects/web scraping/"
images_directory = project_directory + "images_camera/"
products_directory = project_directory + "csv_camera/"
output_directory = project_directory + "output/"
image_data_directory = project_directory + "image data/"

products_file = products_directory + "products.csv"
output_file = output_directory + "output.csv"

images_filepath = os.path.expanduser(images_directory)
products_filepath = os.path.expanduser(products_file)
output_filepath = os.path.expanduser(output_file)

products_input = open(products_filepath, 'r')
products_output = open(output_filepath, 'wb')

col_names = products_input.readline()#throw away basically
products_text = products_input.readlines()

products_output.write((','.join(column_names) + "\n"))

counter = 0
counter_limit = 100
# do unique calculation based on ASIN only
for product_text in products_text:
	counter += 1
	if(counter > counter_limit):
		break
	print("parsing image #: " + str(counter))
	item = Product(product_text, images_directory)
	item.data_to_file(image_data_directory)
	products_output.write((item.data_to_csv_string() + "\n"))
