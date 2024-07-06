import numpy as np
import pandas as pd
import struct

def read_fdt_file(filename, num_columns):
    """
    Reads an .fdt file and returns the data as a numpy array.

    :param filename: Path to the .fdt file.
    :param num_columns: Number of columns in the data.
    :return: numpy array containing the data.
    """
    with open(filename, 'rb') as file:
        data = file.read()
        num_floats = len(data) // struct.calcsize('f')
        floats = struct.unpack('f' * num_floats, data)
        data_array = np.array(floats).reshape(-1, num_columns)
    return data_array

def convert_fdt_to_csv(fdt_filename, csv_filename, num_columns):
    """
    Converts an .fdt file to a .csv file.

    :param fdt_filename: Path to the .fdt file.
    :param csv_filename: Path to the output .csv file.
    :param num_columns: Number of columns in the data.
    """
    data_array = read_fdt_file(fdt_filename, num_columns)
    df = pd.DataFrame(data_array)
    df.to_csv(csv_filename, index=False)

# Usage example
fdt_filename = '465544_Interest_1_ds_filt.fdt'
csv_filename = '465544_Interest_1_ds_filt.csv'
num_columns = 10  # Change this to match the number of columns in your .fdt file

convert_fdt_to_csv(fdt_filename, csv_filename, num_columns)
