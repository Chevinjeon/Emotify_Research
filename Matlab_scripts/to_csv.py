import pyedflib
import numpy as np
import pandas as pd

def read_bdf(filepath):
    # Open BDF file
    f = pyedflib.EdfReader(filepath)
    # Number of signals/channels in the file
    n = f.signalsin_file
    # Extract signal labels
    signal_labels = f.getSignalLabels()
    signal_data = []
    for i in range(n):
        signal_data.append(f.readSignal(i))
    f.close()
    return signal_labels, signal_data

def save_to_csv(signal_data, signal_labels, file_name='processed.csv'):
    # Convert signal data to a numpy array
    data_array = np.array(signal_data).T

    # Create DataFrame from the numpy array
    df = pd.DataFrame(data_array, columns=signal_labels)

    # Save the DataFrame to a CSV file
    df.to_csv(file_name, index=False)
    print(f'Data saved to {file_name}')

if __name__ == "__main__":
    file_path = 'processed_data.bdf'
    signal_labels, signal_data = read_bdf(file_path)
    save_to_csv(signal_data, signal_labels)