import torch
from torch import utils
import numpy as np
import pandas as pd

import os, json



label_path = 'formatted_data/label.csv'
eeg_path = 'formatted_data/eeg'

class_to_idx = {
    "excited": 0,
    "relaxed": 1,
    "stressed": 2,
    "angry": 3,
    "fear": 5
}

idx_to_class = {
    0: "excited",
    1: "relaxed",
    2: "stressed",
    3: "angry",
    4: "fear",
}

def fft_eeg(raw_eeg):
    processed_eeg = np.zeros_like(raw_eeg, dtype=np.float32)

    for i in range(len(raw_eeg)):
        for j in range(len(raw_eeg[0][0])):
            processed_eeg[i, :, j] = np.fft.fft(raw_eeg[i, :, j])
    return processed_eeg


def moving_average(input, window_size=5):
    kernel = np.ones(window_size) / window_size
    convolved = np.zeros(shape=(input.shape[0], input.shape[1] - window_size + 1, input.shape[2]))

    for example in range(input.shape[0]):
        for channel in range(input.shape[2]):
            convolved[example, :, channel] = np.convolve(input[example, :, channel], kernel, mode='valid')

    return convolved


def preproc_eeg(raw_eeg):

    processed_eeg = np.fft.fft(raw_eeg, axis=1)
    # processed_eeg = moving_average(processed_eeg)
    return processed_eeg


class EEGDataset(utils.data.Dataset):
    def __init__(self, test=False, val=False):

        self.label_path = label_path
        self.eeg_path = eeg_path

        self.num_classes = 5

        
        with open('dataset_split.json', 'r') as split_file:
            split = json.load(split_file)
            if test is True:
                self.indices = split['test']
            elif val is True:
                self.indices = split['val']
            else:
                self.indices = split['train']


        eegs, labels = [], []

        label_df = pd.read_csv(self.label_path)

        for idx in self.indices:
            eeg = np.load(os.path.join(self.eeg_path, str(idx) + '.npy'))
            eegs.append(eeg)

            label = class_to_idx[label_df.iloc[idx, 2]]
            labels.append(label)
        

        self.X = preproc_eeg(eegs) # shape: [num samples, seq length, num channels]
        self.X = torch.tensor(np.array(self.X))


        self.Y = torch.eye(self.num_classes)[labels]
    
    def __len__(self):
        return len(self.X)
    
    def __getitem__(self, index):
        X = self.X[index].type(torch.float32)
        Y = self.Y[index].type(torch.float32)
        return X, Y


                
        