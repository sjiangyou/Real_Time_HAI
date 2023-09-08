import h5py
import os
import numpy as np
import pandas as pd
import sys

filename, gis_id, category, latitude, longitude = sys.argv[:5]
date, time = filename[23:30], filename[32:34]

os.chdir('H5')
f = h5py.File(filename, 'r')
grid = f['Grid']

longitude_values = np.repeat(list(grid['lon']), 1800)
latitude_values = list(grid['lat'])*3600
precipitation_values = np.array(list(grid['precipitationCal'])).flatten()

dataset = pd.DataFrame({"lon": longitude_values, "lat": latitude_values, "precipitation": precipitation_values})
dataset.columns = [grid['lon'].attrs['standard_name'].decode() + " (" + grid['lon'].attrs['units'].decode() + ")",
                   grid['lat'].attrs['standard_name'].decode() + " (" + grid['lat'].attrs['units'].decode() + ")",
                   "Precipitation (" + grid['precipitationCal'].attrs['units'].decode() + ")",]

dataset = dataset[dataset['longitude (degrees_east)'] <= (longitude + 6.0)]
dataset = dataset[dataset['longitude (degrees_east)'] >= (longitude - 6.1)]
dataset = dataset[dataset['latitude (degrees_north)'] <= (latitude + 6.1)]
dataset = dataset[dataset['latitude (degrees_north)'] >= (latitude - 6.0)]

image = dataset.pivot(index='latitude (degrees_north)', columns='longitude (degrees_east)', values='Precipitation (mm/hr)')
image = image.T
image.to_csv(f'{gis_id}_{category}_{date}{time}.csv', index=False, header = False)