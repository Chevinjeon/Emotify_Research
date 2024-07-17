import pandas as pd
import numpy as np

import os
from tqdm import tqdm

raw_folder = '../eeg_data'
formatted_folder = '../formatted_eeg_data/eeg_data'
label_file = '../formatted_eeg_data/label.csv'

sample_rate = 256
sample_offset = sample_rate * 3
sample_length = sample_rate * 6



def format_eeg(eeg, idx, label):

    eeg = eeg.to_numpy()
    np.save(os.path.join(formatted_folder, f'{idx}.npy'), eeg)

    with open(label_file, 'a') as f:
        f.write(str(idx) + ',' + label + '\n')
    

def split_eeg():

    with open(label_file, 'w') as f:
        f.write('id,label\n')

    current_idx = 0
    # Subject3_Boredom_1_ds_filt
    for data_file in tqdm(os.listdir(raw_folder)):
        temp = data_file.split("_")

        if temp[1] == "Boredom" or temp[1] == "Interest":
            df = pd.read_csv(os.path.join(raw_folder, data_file))
            total_ts = len(df)

            current_ts = 0
            while current_ts + sample_length <= total_ts:
                eeg_chunk = df.iloc[current_ts : current_ts + sample_length, :]
                format_eeg(eeg_chunk, current_idx, temp[1].lower())
                
                current_ts += sample_offset
                current_idx += 1



if __name__ == "__main__":
    split_eeg()