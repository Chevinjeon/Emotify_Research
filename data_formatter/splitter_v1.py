import os, json
import numpy as np
import pandas as pd
import random
import pickle

# filename example: 
# fear_10_exhuma.csv
# happy_2_friends.csv

formatted_v1_folder = '../formatted_v1'
eeg_folder = 'eeg'
train_test_split = [0.8, 0.2]


# generate train/val/test split
def generate_split():
    trainset, testset = [], []

    for idx in range(len(os.listdir(os.path.join(formatted_v1_folder, 'eeg')))):
        category = random.choices(['train', 'test'], train_test_split)[0]
        
        if category == 'train':
            trainset.append(idx)
        else:
            testset.append(idx)

    with open(os.path.join(formatted_v1_folder, 'dataset_split.json'), 'w') as split_file:
        split = {
            'train': trainset,
            'test': testset
        }
        json.dump(split, split_file)


if __name__ == '__main__':
    generate_split()