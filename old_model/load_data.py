import os, json
import numpy as np
import pandas as pd
import random
import pickle

# filename example: 
# fear_10_exhuma.csv
# happy_2_friends.csv

raw_data_folder = 'raw_data'
formatted_data_folder = 'formatted_data'
sample_rate = 250
sample_length = 250 * 10 # 10 seconds
train_val_test_split = [0.8, 0.1, 0.1]


# generate train/val/test split
def generate_split(num_samples):
    trainset, valset, testset = [], [], []

    for idx in range(num_samples):
        category = random.choices(['train', 'val', 'test'], train_val_test_split)[0]
        
        if category == 'train':
            trainset.append(idx)
        elif category == 'val':
            valset.append(idx)
        else:
            testset.append(idx)

    with open('dataset_split.json', 'w') as split_file:
        split = {
            'train': trainset,
            'val': valset,
            'test': testset
        }
        json.dump(split, split_file)

    


def format_data():

    os.makedirs(os.path.join(formatted_data_folder, 'eeg'))
    with open(os.path.join(formatted_data_folder, 'label.csv'), 'a') as label_file:
        label_file.write('index,filename,mood\n')

    curr_idx = 0

    for file in os.listdir(raw_data_folder):
        df = pd.read_csv(os.path.join(raw_data_folder, file))
        total_rows = len(df)

        curr_row = 1
        while curr_row + sample_length <= len(df):
            sample_chunk = df.iloc[curr_row:curr_row + sample_length, :8]
            sample_array = sample_chunk.to_numpy()

            np.save(os.path.join(formatted_data_folder, 'eeg', f'{curr_idx}.npy'), sample_array)

            with open(os.path.join(formatted_data_folder, 'label.csv'), 'a') as label_file:
                label = file.split('_')[0]
                label_file.write(f'{curr_idx},{file},{label}\n')

            curr_row += sample_length
            curr_idx += 1
        

    generate_split(curr_idx)


format_data()