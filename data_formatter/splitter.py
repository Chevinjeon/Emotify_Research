import os, json
import numpy as np
import pandas as pd
import random
import pickle

formatted_folder = "../formatted_eeg_data/eeg_data"
split_file = "../formatted_eeg_data/split.json"
train_test_split = [0.8, 0.1, 0.1]


# generate train/val/test split
def generate_split():
    trainset, valset, testset = [], [], []

    for idx in range(len(os.listdir(formatted_folder))):
        category = random.choices(['train', 'val', 'test'], train_test_split)[0]
        
        if category == 'train':
            trainset.append(idx)
        elif category == 'test':
            testset.append(idx)
        else:
            valset.append(idx)

    with open(split_file, 'w') as file:
        split = {
            'train': trainset,
            'val': valset,
            'test': testset
        }
        json.dump(split, file)


if __name__ == '__main__':
    generate_split()