import h5py
import os
import numpy as np
import pandas as pd
os.chdir('H5')
f = h5py.File('3B-HHR-E.MS.MRG.3IMERG.20230907-S173000-E175959.1050.V06D.RT-H5', 'r')
grid = f['Grid']
longitude_values = np.repeat(list(grid['lon']), 1800)
latitude_values = list(grid['lat'])*3600
precipitation_values = np.array(list(grid['precipitationCal'])).flatten()
dataset = pd.DataFrame({"lon": longitude_values, "lat": latitude_values, "precipitation": precipitation_values})
dataset.columns = [grid['lon'].attrs['standard_name'].decode() + " (" + grid['lon'].attrs['units'].decode() + ")",
                   grid['lat'].attrs['standard_name'].decode() + " (" + grid['lat'].attrs['units'].decode() + ")",
                   "Precipitation (" + grid['precipitationCal'].attrs['units'].decode() + ")",]
dataset.head()
np.amax(dataset['latitude (degrees_north)'])
dataset.to_csv('IMERG_20230907_1800Z.csv', index=False)
dataset = dataset[dataset['longitude (degrees_east)'] <= -44.7]
dataset = dataset[dataset['longitude (degrees_east)'] >= -56.8]
dataset = dataset[dataset['latitude (degrees_north)'] <= 22.7]
dataset = dataset[dataset['latitude (degrees_north)'] >= 10.6]
print(dataset.shape)
dataset.head()
image = dataset.pivot(index='latitude (degrees_north)', columns='longitude (degrees_east)', values='Precipitation (mm/hr)')
image = image.T
image = image.iloc[:, :]
image.head()
image.to_csv('ATL_202313_C3_2023090718.csv', index=False, header = False)