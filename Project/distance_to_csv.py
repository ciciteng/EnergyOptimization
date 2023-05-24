import numpy as np
import pandas as pd
import geopandas as gpd
import requests
from math import radians, sin, cos, sqrt, atan2


#read in the centroid data
file_path = "/Users/ccteng/Desktop/Energy_Optimization/Project/Centroid_data_28.txt"

dtype = [('country', '<U20'), ('lon', float), ('lat', float)]
centroid_df = np.genfromtxt(file_path, dtype=dtype, delimiter="")

#reading in the .txt file into arrays
country_name = []
lon = []
lat = []
rows = 0
for line_arr in centroid_df:
        country_name.append(line_arr[0])
        lon.append(line_arr[1])
        lat.append(line_arr[2])
        rows += 1

###Function from (https://catslovedata.cc/plotting-european-capitals-centroids-and-the-distance-between-them-using-geopandas)
def calculate_distance(lat1, long1, lat2, long2):
    # Convert coordinates to radians
    lat1_rad = radians(lat1)
    long1_rad = radians(long1)
    lat2_rad = radians(lat2)
    long2_rad = radians(long2)

    # Calculate differences in coordinates
    delta_lat = lat2_rad - lat1_rad
    delta_long = long2_rad - long1_rad

    # Apply Haversine formula
    a = sin(delta_lat/2)**2 + cos(lat1_rad) * cos(lat2_rad) * sin(delta_long/2)**2
    c = 2 * atan2(sqrt(a), sqrt(1-a))
    distance = 6371 * c  # Earth's mean radius in kilometers

    return distance


#creating the distance matrix
row = len(country_name)
col = len(country_name)

distance_arr = np.zeros((row,col))

for i in range(len(country_name)):
    for j in range(len(country_name)):
         distance_arr[i,j] = calculate_distance(lat[i],lon[i],lat[j],lon[j])

output_file = "/Users/ccteng/Desktop/Energy_Optimization/Project/distance_matrix_28.csv"
# np.savetxt(output_file, distance_arr, header = country_name, fmt='%d', rowfmt='%s')
op_df = pd.DataFrame(distance_arr, index=country_name, columns=country_name)
op_df.to_csv(output_file)