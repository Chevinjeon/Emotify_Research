import pyedflib

def get_sampling_rate(file_path):
    f = pyedflib.EdfReader(file_path)
    sampling_rate = f.getSampleFrequency(0)  # Assuming all channels have the same sampling rate
    f.close()
    return sampling_rate

file_path = 'Matlab_scripts/444931.bdf'
sampling_rate = get_sampling_rate(file_path)
print(f"Sampling Rate: {sampling_rate} Hz")
