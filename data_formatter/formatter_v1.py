import pandas as pd
import numpy as np

import os

data_file = 'output2.csv'
formatted_folder = 'formatted_v1/'
label_file = os.path.join(formatted_folder, 'label.csv')

sample_rate = 2048
sample_offset = sample_rate * 5     # new sample every 5 sec
sample_length = sample_rate * 10     

boredom_start = 714164
boredom_end = 1191648
interest_start = 1239353
interest_end = 1757635


def format_data(eeg, idx, label):

    eeg = eeg.to_numpy()
    np.save(os.path.join(formatted_folder, 'eeg', f'{idx}.npy'), eeg)

    with open(label_file, 'a') as f:
        f.write(str(idx) + ',' + label + '\n')
    

def split_eeg():
    df = pd.read_csv(data_file)
    print(df.info)
    boredom_df = df.iloc[boredom_start : boredom_end, :32]      # to be replaced with useful columns
    interest_df = df.iloc[interest_start : interest_end, :32]

    boredom_ts = len(boredom_df)
    interest_ts = len(interest_df)
    current_idx = 0

    current_ts = 0

    while current_ts + sample_length <= boredom_ts:
        eeg_chunk = boredom_df.iloc[current_ts : current_ts + sample_length, :]
        format_data(eeg_chunk, current_idx, "boredom")

        current_ts += sample_offset
        current_idx += 1

    current_ts = 0
    while current_ts + sample_length <= interest_ts:
        eeg_chunk = interest_df.iloc[current_ts : current_ts + sample_length, :]
        format_data(eeg_chunk, current_idx, "interest")

        current_ts += sample_offset
        current_idx += 1


if __name__ == "__main__":
    split_eeg()